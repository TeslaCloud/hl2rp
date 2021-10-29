if !CombatSystem then
  PLUGIN:set_global('CombatSystem')
end

local stored = CombatSystem.stored or {}
CombatSystem.stored = stored

function CombatSystem:add(combat)
  return table.insert(stored, combat)
end

function CombatSystem:remove(id)
  stored[id] = nil
end

function CombatSystem:find(id)
  return stored[id]
end

function CombatSystem:add_member(combat, member)
  combat:add_member(member)
end

function CombatSystem:add_entities_around(combat, member)
  local entities = ents.find_in_sphere(member:GetPos(), 500)
  local pos = member:EyePos()

  for k, v in pairs(entities) do
    if !util.vector_obstructed(pos, v:EyePos(), function(entity) return !isentity(entity) end) then
      combat:add_member(v)
    end
  end
end

function CombatSystem:start_combat(attacker, target)
  local combat = Combat.new()
  self:add_member(combat, attacker)
  self:add_member(combat, target)
  self:add_entities_around(combat, attacker)
  self:add_entities_around(combat, target)

  combat:start()

  return combat
end

local hitgroup_adjust = {
    [HITGROUP_GENERIC]    = 0,
    [HITGROUP_HEAD]       = -1,
    [HITGROUP_CHEST]      = 0,
    [HITGROUP_STOMACH]    = 0,
    [HITGROUP_LEFTARM]    = 1,
    [HITGROUP_RIGHTARM]   = 1,
    [HITGROUP_LEFTLEG]    = 1,
    [HITGROUP_RIGHTLEG]   = 1,
    [HITGROUP_GEAR]       = 0
  }

function CombatSystem:calculate_hit(attacker, target, damage_info)
  local random = Dice.fudge()
  local hitgroup = damage_info:get_hitgroup()
  local combat = attacker:get_combat() or target:get_combat()
  local adjust = 2

  if attacker:IsPlayer() then
    local weapon_item = attacker:get_active_weapon_item()

    if weapon_item then
      if weapon_item.effective_distance then
        local data = {
          attacker = attacker,
          target = target,
          distance = attacker:EyePos():Distance(damage_info:GetDamagePosition()),
          effective_distance = weapon_item.effective_distance or 0,
          distance_adjust = 0,
          combat = combat
        }

        hook.run('AdjustAttackDistance', data)

        if data.effective_distance > 0 then
          if data.distance > data.effective_distance then
            data.distance_adjust = -math.ceil((data.distance - data.effective_distance) / data.effective_distance)
          elseif data.distance < (5):m() then
            data.distance_adjust = 1
          end
        end

        adjust = adjust + data.distance_adjust
      end
    end

    if attacker.shots_done and attacker.shots_done > 0 and attacker:dice('strength') < 0 then
      adjust = adjust - attacker.shots_done
    end
  end

  adjust = adjust + hitgroup_adjust[hitgroup]

  attacker.shots_done = (attacker.shots_done or 0) + 1

  if random + adjust > 0 then
    if target:IsPlayer() and target.combat_leaving then
      target.combat_leaving = false
      target:notify('notification.combat.leave_interrupt')
    end

    combat:send_message('notification.combat.success', {
      attacker = attacker,
      target = target,
      limb = SCHEMA:get_hitgroup_name(hitgroup)
    })

    return false
  else
    combat:send_message('notification.combat.fail', {
      attacker = attacker,
      target = target,
      limb = SCHEMA:get_hitgroup_name(hitgroup)
    })

    return true
  end
end

function CombatSystem:dice_initiative(entity)
  local dice = Dice.fudge()

  if entity:IsPlayer() then
    dice = entity:dice('reflexes')
  end

  return dice
end
