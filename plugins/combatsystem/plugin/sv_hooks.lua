--- Removes a killed NPC from its combat and ends the combat if it is over.
-- @param npc [NPC killed NPC]
-- @param attacker [Entity entity that killed the NPC]
function CombatSystem:OnNPCKilled(npc, attacker)
  local combat = npc:get_combat() or attacker:get_combat()

  if combat then
    combat:remove_member(npc)
    combat:check()
  end
end

--- Removes a deleted entity from its combat and ends the combat if it is over.
-- @param entity [Entity removed entity]
function CombatSystem:EntityRemoved(entity)
  local combat = entity:get_combat()

  if combat then
    combat:remove_member(entity)
    combat:check()
  end
end

--- Removes a dead player from their combat and ends the combat if it is over.
-- @param target [Player player that died]
-- @param inflictor [Entity entity that dealt the damage]
-- @param attacker [Entity entity responsible for the death]
function CombatSystem:PlayerDeath(target, inflictor, attacker)
  local combat = target:get_combat() or attacker:get_combat()

  if combat then
    combat:remove_member(target)
    combat:check()
  end
end

--- Blocks weapon switching without an attack turn in combat, otherwise switching uses up all attack turns.
-- @param actor [Player player switching weapons]
-- @return [Boolean true to block the switch, nil otherwise]
function CombatSystem:PlayerSwitchWeapon(actor)
  if actor:in_combat() then
    if actor:is_frozen() or !actor:has_turn(TURN_ATTACK) then
      return true
    else
      actor:take_turn(TURN_ATTACK, actor:get_turns(TURN_ATTACK))
    end
  end
end

--- Uses up all of a player's attack turns when they reload during their combat turn.
-- @param actor [Player player playing the animation event]
-- @param event [Number PLAYERANIMEVENT_ enum]
function CombatSystem:DoAnimationEvent(actor, event)
  if event == PLAYERANIMEVENT_RELOAD and actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_ATTACK, actor:get_turns(TURN_ATTACK))
  end
end

--- Prevents players from raising their weapon in combat without an attack turn.
-- @param actor [Player player raising the weapon]
-- @return [Boolean false to prevent raising, nil otherwise]
function CombatSystem:CanPlayerRaiseWeapon(actor)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_ATTACK)) then
    return false
  end
end

--- Keeps weapons lowered in combat while the player has no attack turn.
-- @param actor [Player player holding the weapon]
-- @param weapon [Weapon held weapon]
-- @return [Boolean false to keep the weapon lowered, nil otherwise]
function CombatSystem:ShouldWeaponBeRaised(actor, weapon)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_ATTACK)) then
    return false
  end
end

--- Prevents players from using items in combat without a move turn.
-- @param actor [Player player using the item]
-- @param item_obj [Item item being used]
-- @param action [String action being performed]
-- @return [Boolean false to prevent the use, nil otherwise]
function CombatSystem:PlayerCanUseItem(actor, item_obj, action, ...)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_MOVE)) then
    return false
  end
end

--- Prevents players from moving inventory items in combat without a move turn.
-- @param actor [Player player moving the item]
-- @param item_obj [Item item being moved]
-- @param instance_ids [List<Number> instance IDs being moved]
-- @param inventory_id [Number ID of the target inventory]
-- @param x [Number target slot column]
-- @param y [Number target slot row]
-- @return [Boolean false to prevent the move, nil otherwise]
function CombatSystem:PlayerCanMoveItem(actor, item_obj, instance_ids, inventory_id, x, y)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_MOVE)) then
    return false
  end
end

--- Uses up a move turn when a player uses an item in combat.
-- @param actor [Player player that used the item]
-- @param item_obj [Item used item]
-- @param act [String action that was performed]
function CombatSystem:PlayerUsedItem(actor, item_obj, act, ...)
  if actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_MOVE)
  end
end

--- Uses up a move turn when a player moves an inventory item in combat.
-- @param actor [Player player that moved the item]
-- @param item_obj [Item moved item]
-- @param instance_ids [List<Number> moved instance IDs]
-- @param inventory_id [Number ID of the target inventory]
-- @param x [Number target slot column]
-- @param y [Number target slot row]
function CombatSystem:OnItemMoved(actor, item_obj, instance_ids, inventory_id, x, y)
  if actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_MOVE)
  end
end

--- Ends the player's combat turn. Players who have not acted yet also try to leave the combat.
-- @param actor [Player player that pressed the key]
function CombatSystem:ShowHelp(actor)
  if actor:in_combat() and !actor:is_frozen() then
    if !actor.turn_done then
      actor:notify('notification.combat.leave_try')
      actor.combat_leaving = true
    else
      actor:notify('notification.combat.skip')
    end

    actor:get_combat():next_turn()
  end
end

--- Starts or joins a combat when a player and an NPC or another player fight, then rolls whether the attack hits.
-- @param entity [Entity entity being damaged]
-- @param damage_info [CTakeDamageInfo damage being dealt]
-- @return [Boolean true to block the damage when the attack missed, nil if combat does not apply]
function CombatSystem:EntityTakeDamage(entity, damage_info)
  local attacker = damage_info:GetAttacker()

  if IsValid(attacker) and IsValid(entity)
  and ((attacker:IsPlayer() or attacker:IsNPC()) and (entity:IsPlayer() or entity:IsNPC()))
  and !(attacker:IsNPC() and entity:IsNPC()) then
    local attacker_combat = attacker:get_combat()
    local entity_combat = entity:get_combat()
    local combat = attacker_combat

    if attacker_combat and !entity_combat then
      combat = attacker_combat
      CombatSystem:add_member(attacker_combat, entity)
    elseif !attacker_combat and entity_combat then
      combat = entity_combat
      CombatSystem:add_member(entity_combat, attacker)
    elseif !attacker_combat and !entity_combat then
      combat = CombatSystem:start_combat(attacker, entity)
    end

    local success = CombatSystem:calculate_hit(attacker, entity, damage_info)

    if attacker:IsPlayer() then
      attacker:take_turn(TURN_ATTACK)
    end

    return success
  end
end

--- Prevents frozen players from auto walking.
-- @param actor [Player player trying to auto walk]
-- @return [Boolean false to prevent it, nil otherwise]
function CombatSystem:CanPlayerAutoWalk(actor)
  if actor:is_frozen() then
    return false
  end
end
