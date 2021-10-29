local player_meta = FindMetaTable('Player')

function player_meta:leaving_combat()
  return self.combat_leaving
end

function player_meta:take_turn(turn_type, amount)
  amount = amount or 1

  local turns = self:get_nv('fl_combat_turns', {})
  self.turn_done = true
  turns[turn_type] = turns[turn_type] - amount
  self:set_nv('fl_combat_turns', turns)

  if turns[TURN_ATTACK] <= 0 then
    self:freeze_gun()
  end

  if turns[TURN_MOVE] <= 0 then
    self:freeze_move()
  end

  for k, v in pairs(turns) do
    if v > 0 then
      return
    end
  end

  self:get_combat():next_turn()
end

function player_meta:get_turns(turn_type)
  local turns = self:get_nv('fl_combat_turns', {})

  return turns and turns[turn_type] or 0
end

function player_meta:has_turn(turn_type)
  return self:get_turns(turn_type) > 0
end

function player_meta:restore_turns()
  local turns = {
    [TURN_ATTACK] = 1,
    [TURN_MOVE] = 2
  }

  local weapon_item = self:get_active_weapon_item()

  if weapon_item and weapon_item.turns then
    turns[TURN_ATTACK] = weapon_item.turns
  end

  hook.run('AdjustPlayerTurns', self, turns)

  self:set_nv('fl_combat_turns', turns)

  self.shots_done = 0
  self.turn_done = false
end

function player_meta:dice(attribute)
  local value = self:get_attribute(attribute)
  local roll = Dice.fudge(value)
  local adjust_data = {
    player = self,
    attribute = attribute,
    value = value,
    roll = roll
  }

  hook.run('AdjustDiceThrow', adjust_data)

  return adjust_data.value + adjust_data.roll
end
