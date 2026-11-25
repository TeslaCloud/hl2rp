--- Force Fields adds the Combine force field, which combine players cycle through the modes of
-- `ForceFields.modes` with the use key. The mode decides who passes: CWU members in modes 2
-- to 4, and in mode 3 holders of a CP card too, everyone in the last two. Combine players
-- always pass, a player who holds the use key collides with it to use it, and the
-- `ShouldForcefieldCollide` hook decides for everyone else. Force fields are saved with the
-- map when the Static Entities plugin is loaded.

PLUGIN:set_global('ForceFields')

ForceFields.modes = {
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

--- Checks whether a player carries a CP card or a CP officer card, as
-- `ForceFields:update_collision_state` has last found. Always false without the Items plugin.
-- @param activator [Player]
-- @return [Boolean]
function ForceFields:carries_cp_card(activator)
  return activator.forcefield_has_card == true
end

--- Looks again at what force fields decide by for a player: whether they are combine, a CWU
-- citizen or carry a CP card (see `Player:has_cp_card`). Force fields read the answers kept
-- on the player on every collision check. The physics engine keeps the result of a check for
-- a pair of entities, so it is told whenever one of the answers changes.
-- @param target [Player]
function ForceFields:update_collision_state(target)
  local is_combine = target:is_combine()
  local is_cwu = target:get_faction_id() == 'citizen' and target:is_rank('cwu')
  local has_card = Inventories != nil and target:has_cp_card()

  if is_combine == target.forcefield_is_combine and is_cwu == target.forcefield_is_cwu
  and has_card == target.forcefield_has_card then return end

  target.forcefield_is_combine = is_combine
  target.forcefield_is_cwu = is_cwu
  target.forcefield_has_card = has_card
  target:CollisionRulesChanged()
end

--- Lets whitelisted projectiles and NPCs pass through force fields and asks ShouldForcefieldCollide for players.
-- @param a [Entity first entity]
-- @param b [Entity second entity]
-- @return [Boolean whether the entities collide, nil to use the default]
function ForceFields:ShouldCollide(a, b)
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

      if activator.forcefield_is_combine or activator:get_nv('forcefield_collide') == false then
        return false
      end

      --- Decides whether a player who is not combine collides with a forcefield, on both
      -- realms, on every collision check between the two. The answer has to stay the same
      -- for the pair until `Entity:CollisionRulesChanged` is called on one of them. The
      -- plugin's own handler goes by the mode of the forcefield.
      -- @param activator [Player The player touching the forcefield]
      -- @param field [Entity The forcefield]
      -- @param mode [Number The mode of the forcefield, an index into ForceFields.modes]
      -- @return [Boolean Return false to let the player through, true to block them; nil
      --   leaves it to the other ShouldCollide handlers, and the two collide by default]
      return Plugin.call('ShouldForcefieldCollide', activator, entity, entity:GetMode())
    else
      return true
    end
  end
end

--- Decides whether a player collides with a forcefield based on its mode. CWU members pass in
-- modes 2 to 4, and in mode 3 so does anyone who carries a CP card or a CP officer card (see
-- `ForceFields:carries_cp_card`).
-- @param activator [Player player touching the forcefield]
-- @param _field [Entity forcefield]
-- @param mode [Number index into ForceFields.modes]
-- @return [Boolean false to let the player through, true to block them, nil to use the default]
function ForceFields:ShouldForcefieldCollide(activator, _field, mode)
  if mode >= 2 and mode <= 4 and IsValid(activator) then
    if activator.forcefield_is_cwu then
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

if SERVER and StaticEnts then
  StaticEnts:whitelist_ent 'fl_forcefield'
end

require_relative 'cl_hooks'
require_relative 'sh_hooks'
require_relative 'sv_hooks'
