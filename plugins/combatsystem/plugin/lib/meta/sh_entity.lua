local ent_meta = FindMetaTable('Entity')

function ent_meta:in_combat()
  return isnumber(self:get_nv('combat_id', nil))
end

function ent_meta:get_combat()
  return CombatSystem:find(self:get_nv('combat_id'))
end
