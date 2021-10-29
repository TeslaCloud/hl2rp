local damage_info = FindMetaTable('CTakeDamageInfo')

function damage_info:get_hitgroup()
  local damage_pos = self:GetDamagePosition()
  local trace = util.TraceLine({
    start = damage_pos,
    endpos = damage_pos + self:GetDamageForce()
  })

  return trace.HitGroup
end
