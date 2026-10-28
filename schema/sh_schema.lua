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
    [10000]     = 'models/props_junk/wood_crate001a.mdl'
  }
})

Config.set('default_currency', 'tokens')

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

--- Returns a random full name for a gender, or a random vortigaunt name for vortigaunt characters.
-- @param gender [String gender, 'no_gender' uses male names]
-- @param char_data=nil [Table character data, used to check the faction]
-- @return [String random first and last name]
function SCHEMA:get_random_name(gender, char_data)
  if char_data and char_data.faction == 'vortigaunt' then
    return table.Random(self.vort_names)..' '..table.Random(self.vort_last_names)
  end

  gender = (gender == 'no_gender' and 'male') or gender

  local last_name = table.Random(self.last_names)
  local first_name = table.Random(self[gender..'_names'])

  return first_name..' '..last_name
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
     !self:HasSpawnFlags(32768) then
    return true
  end

  return false
end
