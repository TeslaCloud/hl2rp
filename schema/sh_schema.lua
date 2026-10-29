--- Main file of the Half-Life 2 roleplay schema, run on both realms. Includes the root files of
-- the schema, sets the default theme, the human and combine faction groups and the tokens
-- currency, and adds the combine and human checks to `SCHEMA`, `Player` and `Entity`.

require_relative 'cl_schema'
require_relative 'sv_schema'
require_relative 'cl_hooks'
require_relative 'sh_hooks'
require_relative 'sv_hooks'
require_relative 'sv_nethooks'

local IsValid = IsValid

SCHEMA.default_theme = 'hl2rp'
SCHEMA.human_factions = {
  ['citizen']   = true,
  ['admin']     = true
}
SCHEMA.combine_factions = {
  ['admin']     = true,
  ['cca']       = true,
  ['overwatch'] = true
}

Currencies:register_currency('tokens', {
  name        = 'currency.tokens',
  symbol      = '₮',
  hidden      = false,
  model_table = {
    [0]         = 'models/props_lab/box01a.mdl',
    [50]        = 'models/props_junk/cardboard_box004a.mdl',
    [200]       = 'models/props_junk/cardboard_box003a.mdl',
    [1000]      = 'models/props_junk/cardboard_box002a.mdl',
    [10_000]    = 'models/props_junk/wood_crate001a.mdl'
  }
})

Config.set('currencies_default', 'tokens')

--- Checks whether a faction belongs to the combine.
-- @param faction [String faction ID]
-- @return [Boolean whether the faction is a combine faction]
function SCHEMA:combine_faction(faction)
  return self.combine_factions[faction] or false
end

--- Checks whether a faction is made up of humans.
-- @param faction [String faction ID]
-- @return [Boolean whether the faction is a human faction]
function SCHEMA:human_faction(faction)
  return self.human_factions[faction] or false
end

--- Checks whether a player is in a combine faction.
-- @param target [Player player to check]
-- @return [Boolean whether the player is combine]
function SCHEMA:is_combine(target)
  if IsValid(target) and target:IsPlayer() then
    return self:combine_faction(target:get_faction_id())
  end

  return false
end

--- Checks whether a player is in a human faction.
-- @param target [Player player to check]
-- @return [Boolean whether the player is human]
function SCHEMA:is_human(target)
  if IsValid(target) and target:IsPlayer() then
    return self:human_faction(target:get_faction_id())
  end

  return false
end

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

local entity_meta = FindMetaTable('Entity')

--- Checks whether the entity is a door without the 256, 8192 or 32768 spawn flags, which combine cards can open.
-- @return [Boolean whether the entity is a combine door]
function entity_meta:is_combine_door()
  if IsValid(self) and self:is_door() and !self:HasSpawnFlags(256) and !self:HasSpawnFlags(8192) and
     !self:HasSpawnFlags(32_768) then
    return true
  end

  return false
end
