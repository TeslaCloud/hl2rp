--- Player extensions of the schema: whether a player is combine or human, and the type of the
-- weapon they hold.

local IsValid = IsValid
local player_meta = FindMetaTable('Player')

--- Checks whether the player is in a combine faction.
-- @return [Boolean whether the player is combine]
function player_meta:is_combine()
  return SCHEMA:is_combine(self)
end

--- Checks whether the player is in a human faction.
-- @return [Boolean whether the player is human]
function player_meta:is_human()
  return SCHEMA:is_human(self)
end

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
