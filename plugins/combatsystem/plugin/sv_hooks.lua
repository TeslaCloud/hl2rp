function CombatSystem:OnNPCKilled(npc, attacker)
  local combat = npc:get_combat() or attacker:get_combat()

  if combat then
    combat:remove_member(npc)
    combat:check()
  end
end

function CombatSystem:EntityRemoved(entity)
  local combat = entity:get_combat()

  if combat then
    combat:remove_member(entity)
    combat:check()
  end
end

function CombatSystem:PlayerDeath(target, inflictor, attacker)
  local combat = target:get_combat() or attacker:get_combat()

  if combat then
    combat:remove_member(target)
    combat:check()
  end
end

function CombatSystem:PlayerSwitchWeapon(actor)
  if actor:in_combat() then
    if actor:is_frozen() or !actor:has_turn(TURN_ATTACK) then
      return true
    else
      actor:take_turn(TURN_ATTACK, actor:get_turns(TURN_ATTACK))
    end
  end
end
function CombatSystem:DoAnimationEvent(actor, event)
  if event == PLAYERANIMEVENT_RELOAD and actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_ATTACK, actor:get_turns(TURN_ATTACK))
  end
end

function CombatSystem:CanPlayerRaiseWeapon(actor)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_ATTACK)) then
    return false
  end
end

function CombatSystem:ShouldWeaponBeRaised(actor, weapon)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_ATTACK)) then
    return false
  end
end

function CombatSystem:PlayerCanUseItem(actor, item_obj, action, ...)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_MOVE)) then
    return false
  end
end

function CombatSystem:PlayerCanMoveItem(actor, item_obj, instance_ids, inventory_id, x, y)
  if actor:in_combat() and (actor:is_frozen() or !actor:has_turn(TURN_MOVE)) then
    return false
  end
end

function CombatSystem:PlayerUsedItem(actor, item_obj, act, ...)
  if actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_MOVE)
  end
end

function CombatSystem:OnItemMoved(actor, item_obj, instance_ids, inventory_id, x, y)
  if actor:in_combat() and !actor:is_frozen() then
    actor:take_turn(TURN_MOVE)
  end
end

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

function CombatSystem:CanPlayerAutoWalk(actor)
  if actor:is_frozen() then
    return false
  end
end
