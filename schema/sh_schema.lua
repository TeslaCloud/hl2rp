require_relative 'cl_hooks'
require_relative 'sh_animations'
require_relative 'sh_enums'
require_relative 'sh_names'
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

do
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
end

do
  local hitgroup_table = {
    [HITGROUP_GENERIC]    = LIMBGROUP_TORSO,
    [HITGROUP_HEAD]       = LIMBGROUP_HEAD,
    [HITGROUP_CHEST]      = LIMBGROUP_TORSO,
    [HITGROUP_STOMACH]    = LIMBGROUP_TORSO,
    [HITGROUP_LEFTARM]    = LIMBGROUP_ARMS,
    [HITGROUP_RIGHTARM]   = LIMBGROUP_ARMS,
    [HITGROUP_LEFTLEG]    = LIMBGROUP_LEGS,
    [HITGROUP_RIGHTLEG]   = LIMBGROUP_LEGS,
    [HITGROUP_GEAR]       = LIMBGROUP_TORSO
  }

  --- Returns the limb group a hitgroup belongs to.
  -- @param hitgroup [Number HITGROUP_ enum]
  -- @return [Number LIMBGROUP_ enum]
  function SCHEMA:hitgroup_to_limb(hitgroup)
    return hitgroup_table[hitgroup]
  end

  local hitgroup_name = {
    [HITGROUP_GENERIC]    = 'ui.limb.body',
    [HITGROUP_HEAD]       = 'ui.limb.head',
    [HITGROUP_CHEST]      = 'ui.limb.chest',
    [HITGROUP_STOMACH]    = 'ui.limb.stomach',
    [HITGROUP_LEFTARM]    = 'ui.limb.left_arm',
    [HITGROUP_RIGHTARM]   = 'ui.limb.right_arm',
    [HITGROUP_LEFTLEG]    = 'ui.limb.left_leg',
    [HITGROUP_RIGHTLEG]   = 'ui.limb.right_leg',
    [HITGROUP_GEAR]       = 'ui.limb.groin'
  }

  --- Returns the language phrase of a hitgroup's body part name.
  -- @param hitgroup [Number HITGROUP_ enum]
  -- @return [String language phrase]
  function SCHEMA:get_hitgroup_name(hitgroup)
    return hitgroup_name[hitgroup]
  end
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
