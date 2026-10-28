local IsValid = IsValid

local weapon_types = {
  ['weapon_357']        = WEAPON_RANGED,
  ['weapon_ar2']        = WEAPON_RANGED,
  ['weapon_crossbow']   = WEAPON_RANGED,
  ['weapon_pistol']     = WEAPON_RANGED,
  ['weapon_rpg']        = WEAPON_RANGED,
  ['weapon_shotgun']    = WEAPON_RANGED,
  ['weapon_smg1']       = WEAPON_RANGED,
  ['weapon_crowbar']    = WEAPON_MELEE,
  ['weapon_stunstick']  = WEAPON_MELEE,
  ['weapon_fists']      = WEAPON_MELEE,
  ['weapon_frag']       = WEAPON_THROWABLE,
  ['weapon_slam']       = WEAPON_THROWABLE,
  ['weapon_bugbait']    = WEAPON_THROWABLE
}

--- Returns whether a weapon class is ranged, melee or throwable.
-- @param weapon_class [String weapon class]
-- @return [Number WEAPON_ enum, WEAPON_DEFAULT for unknown weapons]
function SCHEMA:get_weapon_type(weapon_class)
  return weapon_types[weapon_class] or WEAPON_DEFAULT
end

local player_meta = FindMetaTable('Player')

--- Returns the type of the weapon the player is holding.
-- @return [Number WEAPON_ enum, WEAPON_DEFAULT if no weapon is held]
function player_meta:get_active_weapon_type()
  local weapon = self:GetActiveWeapon()

  if IsValid(weapon) then
    local weapon_class = weapon:GetClass()

    if weapon_class then
      return SCHEMA:get_weapon_type(weapon_class)
    end
  end

  return WEAPON_DEFAULT
end
