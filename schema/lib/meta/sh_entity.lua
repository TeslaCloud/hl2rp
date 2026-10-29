--- Entity extension of the schema: whether a door is one that combine cards open.

local IsValid = IsValid
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
