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

function CombatSystem:PlayerSwitchWeapon(player)
  if player:in_combat() then
    if player:is_frozen() or !player:has_turn(TURN_ATTACK) then
      return true
    else
      player:take_turn(TURN_ATTACK, player:get_turns(TURN_ATTACK))
    end
  end
end
function CombatSystem:DoAnimationEvent(player, event)
  if event == PLAYERANIMEVENT_RELOAD and player:in_combat() and !player:is_frozen() then
    player:take_turn(TURN_ATTACK, player:get_turns(TURN_ATTACK))
  end
end

function CombatSystem:CanPlayerRaiseWeapon(player)
  if player:in_combat() and (player:is_frozen() or !player:has_turn(TURN_ATTACK)) then
    return false
  end
end

function CombatSystem:ShouldWeaponBeRaised(player, weapon)
  if player:in_combat() and (player:is_frozen() or !player:has_turn(TURN_ATTACK)) then
    return false
  end
end

function CombatSystem:PlayerCanUseItem(player, item_obj, action, ...)
  if player:in_combat() and (player:is_frozen() or !player:has_turn(TURN_MOVE)) then
    return false
  end
end

function CombatSystem:PlayerCanMoveItem(player, item_obj, instance_ids, inventory_id, x, y)
  if player:in_combat() and (player:is_frozen() or !player:has_turn(TURN_MOVE)) then
    return false
  end
end

function CombatSystem:PlayerUsedItem(player, item_obj, act, ...)
  if player:in_combat() and !player:is_frozen() then
    player:take_turn(TURN_MOVE)
  end
end

function CombatSystem:OnItemMoved(player, item_obj, instance_ids, inventory_id, x, y)
  if player:in_combat() and !player:is_frozen() then
    player:take_turn(TURN_MOVE)
  end
end

function CombatSystem:ShowHelp(player)
  if player:in_combat() and !player:is_frozen() then
    if !player.turn_done then
      player:notify('notification.combat.leave_try')
      player.combat_leaving = true
    else
      player:notify('notification.combat.skip')
    end

    player:get_combat():next_turn()
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

function CombatSystem:CanPlayerAutoWalk(player)
  if player:is_frozen() then
    return false
  end
end
