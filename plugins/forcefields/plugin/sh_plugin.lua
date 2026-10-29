PLUGIN:set_global('Forcefields')

Forcefields.modes = {
  'forcefield.modes.cca_only',
  'forcefield.modes.cca_cwu',
  'forcefield.modes.cca_cwu_card',
  'forcefield.modes.cca_cwu_no_card',
  'forcefield.modes.everyone',
  'forcefield.modes.off'
}

local allowed_ents = {
  prop_combine_ball   = true,
  npc_grenade_frag    = true,
  rpg_missile         = true,
  grenade_ar2         = true,
  crossbow_bolt       = true,
  npc_combine_camera  = true,
  npc_turret_ceiling  = true,
  npc_cscanner        = true,
  npc_combinedropship = true,
  npc_combine_s       = true,
  npc_combinegunship  = true,
  npc_hunter          = true,
  npc_helicopter      = true,
  npc_manhack         = true,
  npc_metropolice     = true,
  npc_rollermine      = true,
  npc_clawscanner     = true,
  npc_stalker         = true,
  npc_strider         = true,
  npc_turret_floor    = true,
  prop_vehicle_zapc   = true,
  prop_physics        = true,
  hunter_flechette    = true,
  npc_tripmine        = true
}

local CurTime = CurTime

const card_check_interval = 1

--- Checks whether a player carries a CP card or a CP officer card. The answer is looked up in
-- the inventory at most once a second per player and kept on the player in between, since
-- forcefields ask for it on every collision check. Always false without the Inventory plugin.
-- @param activator [Player]
-- @return [Boolean]
function Forcefields:carries_cp_card(activator)
  if !Inventories then return false end

  local cur_time = CurTime()

  if (activator.forcefield_card_check_at or 0) <= cur_time then
    activator.forcefield_card_check_at = cur_time + card_check_interval
    activator.forcefield_has_card = activator:has_item('card_cp') or activator:has_item('card_cp_officer')
  end

  return activator.forcefield_has_card
end

--- Lets whitelisted projectiles and NPCs pass through forcefields and asks ShouldForcefieldCollide for players.
-- @param a [Entity first entity]
-- @param b [Entity second entity]
-- @return [Boolean whether the entities collide, nil to use the default]
function Forcefields:ShouldCollide(a, b)
  local a_class, b_class = a:GetClass(), b:GetClass()

  if a_class != 'fl_forcefield' and b_class != 'fl_forcefield' then return end

  if allowed_ents[a_class] or allowed_ents[b_class] then
    return false
  end

  local activator
  local entity
  local entity_class

  if a:IsPlayer() then
    activator = a
    entity = b
    entity_class = b_class
  elseif b:IsPlayer() then
    activator = b
    entity = a
    entity_class = a_class
  end

  if entity_class == 'fl_forcefield' and IsValid(entity) then
    if IsValid(activator) then
      if activator:KeyDown(IN_USE) then return true end

      if activator:is_combine() or activator:get_nv('forcefield_collide') == false then
        return false
      end

      return Plugin.call('ShouldForcefieldCollide', activator, entity, entity:GetDTInt(0) or 1)
    else
      return true
    end
  end
end

--- Decides whether a player collides with a forcefield based on its mode. CWU members pass in
-- modes 2 to 4, and in mode 3 so does anyone who carries a CP card or a CP officer card (see
-- `Forcefields:carries_cp_card`).
-- @param activator [Player player touching the forcefield]
-- @param _field [Entity forcefield]
-- @param mode [Number index into Forcefields.modes]
-- @return [Boolean false to let the player through, true to block them, nil to use the default]
function Forcefields:ShouldForcefieldCollide(activator, _field, mode)
  if mode >= 2 and mode <= 4 and IsValid(activator) then
    if activator:get_faction_id() == 'citizen' and activator:is_rank('cwu') then
      return false
    end

    if mode == 3 and self:carries_cp_card(activator) then
      return false
    end
  end

  if mode == 5 or mode == 6 then
    return false
  elseif mode == 1 then
    return true
  end
end

if SERVER then
  StaticEnts:whitelist_ent 'fl_forcefield'
end

require_relative 'cl_hooks'
