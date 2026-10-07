PLUGIN:set_global('Forcefields')

Forcefields.modes = {
  'CCA only',
  'CCA + CWU',
  'CCA, CWU + Card',
  'CCA, CWU, NO CARD',
  'Everyone',
  'Off'
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
  npc_tripmine        = true,
  prop_vehicle_zapc   = true
}

function Forcefields:ShouldCollide(a, b)
  local activator
  local entity

  if a:IsPlayer() then
    activator = a
    entity = b
  elseif b:IsPlayer() then
    activator = b
    entity = a
  end

  local a_class, b_class = a:GetClass(), b:GetClass()

  if (allowed_ents[a_class] or allowed_ents[b_class]) and
     (a_class == 'fl_forcefield' or b_class == 'fl_forcefield') then
    return false
  end

  if IsValid(entity) and entity:GetClass() == 'fl_forcefield' then
    if IsValid(activator) then
      if activator:KeyDown(IN_USE) then return true end -- if the player is pressing 'use' key they should always collide so that using works.

      if activator:is_combine() or activator:get_nv('forcefield_collide') == false then
        return false
      end

      return Plugin.call('ShouldForcefieldCollide', activator, entity, entity:GetDTInt(0) or 1)
    else
      return true
    end
  end
end

function Forcefields:ShouldForcefieldCollide(activator, field, mode)
  if mode == 2 and IsValid(activator) then
    if activator:get_faction_id() == 'cwu' then
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
