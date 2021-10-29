class 'Combat'

function Combat:init()
  self.id = CombatSystem:add(self)
  self.round = 1
  self.current_member = 1
  self.started = false
  self.finished = false
  self.members = {}
end

function Combat:start()
  self.started = true
  self:freeze_members()
  self:calculate_turn_order()

  self:turn(self:get_acting_member(), true)
end

function Combat:finish()
  self.finished = true
  self:notify_finish()
  timer.remove('combat_action_'..self.id)
  self:remove_members()

  CombatSystem:remove(self.id)
end

function Combat:calculate_turn_order()
  local order = self.members
  local initiator, victim = order[1], order[2]

  table.remove(order, 1)

  for k, v in pairs(order) do
    order[k] = {
      entity = v,
      initiative = CombatSystem:dice_initiative(v)
    }
  end

  table.sort(order, function(a, b)
    if a.initiative > b.initiative then
      return true
    elseif a.initiative == b.initiative then
      if a.entity:IsPlayer() and b.entity:IsNPC() then
        return true
      elseif a.entity:IsPlayer() and b.entity:IsPlayer() then
        local ref_a, ref_b = a.entity:get_attribute('reflexes'), b.entity:get_attribute('reflexes')

        if a > b then
          return true
        elseif a == b then
          return math.random(1, 2) == 1
        end
      end
    end
  end)

  table.insert(order, 1, { entity = initiator, initiative = 'notification.combat.initiator' })

  hook.run('AdjustCombatTurnOrder', order, initiator, victim)

  self.members = {}

  for k, v in pairs(order) do
    table.insert(self.members, v.entity)
  end

  self:message_initiative(order)
end

function Combat:message_initiative(order)
  Cable.send(self:get_players(), 'fl_combat_turn_order', order)
end

function Combat:get_players()
  local players = {}

  for k, v in pairs(self.members) do
    if IsValid(v) and v:IsPlayer() then
      table.insert(players, v)
    end
  end

  return players
end

function Combat:get_acting_member()
  return self.members[self.current_member]
end

function Combat:get_members()
  return self.members
end

function Combat:pop_member()
  local i = self.current_member

  i = i + 1

  if i > #self.members then
    i = 1

    self:round_end()
  end

  self.current_member = i

  return self.members[i]
end

function Combat:round_end()
  self.round = self.round + 1
end

function Combat:add_member(entity, position)
  if !IsValid(entity) or (!entity:IsNPC() and !entity:IsPlayer())
  or table.has_value(self.members, entity) then return end

  entity:set_nv('combat_id', self.id)
  position = position or #self.members + 1

  table.insert(self.members, position, entity)

  if self.started then
    self:send_message('notification.combat.enter', { player = entity })
    entity:freeze()
  end
end

function Combat:remove_member(id, all)
  local entity

  if isentity(id) then
    entity = id
    id = table.key_from_value(self.members, entity)
  elseif isnumber(id) then
    entity = self.members[id]
  end

  if IsValid(entity) then
    entity:set_nv('combat_id', false)
    entity:unfreeze()

    if entity:IsPlayer() then
      timer.remove('combat_turn_'..entity:SteamID())
      
      Cable.send(entity, 'fl_combat_end_turn')
    end
  end

  if !all then
    table.remove(self.members, id)

    if self.current_member == id then
      self.current_member = self.current_member - 1

      if self.current_member <= 0 then
        self.current_member = #self.members
      end
    end
  end
end

function Combat:remove_members()
  for k, v in pairs(self:get_members()) do
    if IsValid(v) then
      self:remove_member(k, true)
    end
  end

  self.members = nil
end

function Combat:freeze_members()
  for k, v in pairs(self:get_members()) do
    if IsValid(v) then
      v:freeze()
    end
  end
end

function Combat:check()
  if self.finished then return end

  if #self.members <= 1 then
    self:finish()

    return
  end

  for k, v in pairs(self.members) do
    if IsValid(v) then
      if v:IsPlayer() and !v:leaving_combat() then
        return
      elseif v:IsNPC() then
        for k1, v1 in pairs(self.members) do
          if IsValid(v1) and v != v1 and v:Disposition(v1) < D_LI then
            return
          end
        end
      end
    end
  end

  self:finish()
end

function Combat:turn(entity, first)
  if IsValid(entity) then
    local timer_name = 'combat_action_'..self.id
    entity:unfreeze()
    self:notify_turn()

    if entity:IsPlayer() then
      if entity:leaving_combat() then
        self:send_message('notification.combat.leave', { player = entity })
        self:remove_member(entity)
        entity.combat_leaving = false
        self:next_turn()
      else
        local last_pos = entity:GetPos()

        Cable.send(entity, 'fl_combat_start_turn', last_pos)

        entity:restore_turns()
        timer.create('combat_turn_'..entity:SteamID(), 60, 1, function()
          if !self.finished and self:get_acting_member() == entity then
            self:next_turn()
          end
        end)

        timer.create(timer_name, 1, 0, function()
          if !IsValid(entity) or self.finished then
            timer.remove(timer_name)

            return
          end

          if last_pos:Distance(entity:GetPos()) > entity:GetWalkSpeed() * 0.5 then
            if entity:get_turns(TURN_MOVE) <= 1 then
              timer.remove(timer_name)
            end

            last_pos = entity:GetPos()
            entity:take_turn(TURN_MOVE)
            Cable.send(entity, 'fl_combat_update_pos', last_pos)
          end
        end)
      end
    elseif entity:IsNPC() then
      if first or !IsValid(entity) then
        self:next_turn()
      else
        timer.create(timer_name, 4, 1, function()
          if !self.finished then
            self:next_turn()
          end
        end)
      end
    end
  end
end

function Combat:send_message(text, arguments)
  Cable.send(self:get_players(), 'fl_combat_message', text, arguments)
end

function Combat:notify_turn()
  Cable.send(self:get_players(), 'fl_combat_notify_turn', self:get_acting_member())
end

function Combat:notify_finish()
  Cable.send(self:get_players(), 'fl_combat_notify_finish')
end

function Combat:next_turn()
  if self.finished then return end

  local member = self:get_acting_member()

  if IsValid(member) then
    member:freeze()

    if member:IsPlayer() then
      timer.remove('combat_turn_'..member:SteamID())
      
      Cable.send(member, 'fl_combat_end_turn')
    end
  else
    self:remove_member(self.current_member)
  end

  member = self:pop_member()

  if IsValid(member) then
    self:turn(member)
  else
    self:remove_member(self.current_member)
  end

  self:check()
end
