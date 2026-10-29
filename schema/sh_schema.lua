--- Main file of the Half-Life 2 roleplay schema, run on both realms. Includes the root files of
-- the schema, sets the default theme, the human and combine faction groups and the tokens
-- currency, and adds the combine and human checks to `SCHEMA`; those of `Player` and `Entity`
-- are in `lib/meta`.

require_relative 'cl_schema'
require_relative 'sv_schema'
require_relative 'cl_hooks'
require_relative 'sh_hooks'
require_relative 'sv_hooks'

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
