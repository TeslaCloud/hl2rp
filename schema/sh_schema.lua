require_relative 'cl_hooks'
require_relative 'sh_animations'
require_relative 'sh_enums'
require_relative 'sh_names'
require_relative 'sh_hooks'
require_relative 'sv_hooks'

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

function SCHEMA:combine_faction(faction)
  return self.combine_factions[faction] or false
end

function SCHEMA:human_faction(faction)
  return self.human_factions[faction] or false
end

function SCHEMA:is_combine(player)
  if IsValid(player) and player:IsPlayer() then
    return self:combine_faction(player:get_faction_id())
  end

  return false
end

function SCHEMA:is_human(player)
  if IsValid(player) and player:IsPlayer() then
    return self:human_faction(player:get_faction_id())
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

  function SCHEMA:get_hitgroup_name(hitgroup)
    return hitgroup_name[hitgroup]
  end
end

function SCHEMA:get_random_name(gender, char_data)
  if char_data.faction and char_data.faction == 'vortigaunt' then
    return table.random(self.vort_names)..' '..table.random(self.vort_last_names)
  end

  gender = (gender == 'no_gender' and 'male') or gender

  local last_name = table.random(self.last_names)
  local first_name = table.random(self[gender..'_names'])

  return first_name..' '..last_name
end

local player_meta = FindMetaTable('Player')

function player_meta:is_combine()
  return SCHEMA:is_combine(self)
end

function player_meta:is_human()
  return SCHEMA:is_human(self)
end

function player_meta:get_active_weapon_type()
  local weapon = self:GetActiveWeapon()

  if IsValid(weapon) and weapon:GetClass() then
    return SCHEMA:get_weapon_type(weapon:GetClass())
  end

  return WEAPON_DEFAULT
end

local entity_meta = FindMetaTable('Entity')

function entity_meta:is_combine_door()
  if IsValid(self) and self:is_door() and !self:HasSpawnFlags(256) and !self:HasSpawnFlags(8192) and !self:HasSpawnFlags(32768) then
      return true
  end

  return false
end
