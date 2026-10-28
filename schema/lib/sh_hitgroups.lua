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
