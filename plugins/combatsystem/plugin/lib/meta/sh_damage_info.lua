local damage_info = FindMetaTable('CTakeDamageInfo')

--- Traces along the damage force from the damage position to find which hitgroup was hit.
-- Used for NPCs, whose hit location the Damage plugin does not remember; a hit with little or
-- no force, such as a blast, traces nothing and comes out as HITGROUP_GENERIC.
-- @return [Number HITGROUP_ enum of the hit body part]
function damage_info:get_hitgroup()
  local damage_pos = self:GetDamagePosition()
  local trace = util.TraceLine({
    start = damage_pos,
    endpos = damage_pos + self:GetDamageForce()
  })

  return trace.HitGroup
end
