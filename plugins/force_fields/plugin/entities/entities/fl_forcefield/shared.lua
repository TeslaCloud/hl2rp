--- The Combine force field: a fence post with a shield that reaches to a second post at the
-- wall to its right. Its networked mode, an index into `ForceFields.modes`, decides who the
-- shield lets through.

ENT.Type            = 'anim'
ENT.Base            = 'base_anim'
ENT.PrintName       = 'Force Field'
ENT.Category        = 'HL2RP'
ENT.Spawnable       = true
ENT.AdminOnly       = true
ENT.RenderGroup     = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true

--- Sets up the networked mode and the networked post at the far end of the shield.
function ENT:SetupDataTables()
  self:NetworkVar('Int', 0, 'Mode')
  self:NetworkVar('Entity', 0, 'Post')
end

--- Checks whether a mode turns the shield off, which the last of `ForceFields.modes` does.
-- @param mode [Number index into ForceFields.modes]
-- @return [Boolean]
function ENT:is_off_mode(mode)
  return mode == #ForceFields.modes
end

--- Builds the collision mesh of the shield, a wall from the forcefield to its post.
-- @param post [Entity post at the far end of the shield]
function ENT:build_mesh(post)
  local post_pos = self:WorldToLocal(post:GetPos())

  self:PhysicsFromMesh({
    { pos = Vector(0, 0, -35) },
    { pos = Vector(0, 0, 150) },
    { pos = post_pos + Vector(0, 0, 150) },
    { pos = post_pos + Vector(0, 0, 150) },
    { pos = post_pos - Vector(0, 0, 35) },
    { pos = Vector(0, 0, -35) }
  })
  self:EnableCustomCollisions(true)
end
