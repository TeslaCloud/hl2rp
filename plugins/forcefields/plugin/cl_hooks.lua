--- Rebuilds the clientside collision mesh of every forcefield between its two posts.
function Forcefields:update_forcefields()
  local forcefields = ents.FindByClass('fl_forcefield')

  for i = 1, #forcefields do
    local forcefield = forcefields[i]
    local post = forcefield:GetDTEntity(0)

    if IsValid(post) then
      local post_pos = forcefield:WorldToLocal(post:GetPos() - Vector(0, 0, 50))
      local verts = {
        { pos = Vector(0, 0, -35) },
        { pos = Vector(0, 0, 150) },
        { pos = post_pos + Vector(0, 0, 150) },
        { pos = post_pos + Vector(0, 0, 150) },
        { pos = post_pos - Vector(0, 0, 35) },
        { pos = Vector(0, 0, -35) }
      }

      forcefield:PhysicsFromMesh(verts)
      forcefield:EnableCustomCollisions(true)
      forcefield:GetPhysicsObject():EnableCollisions(false)
    end
  end
end

--- Builds the forcefield collision meshes once the local player has loaded in.
function Forcefields:PlayerInitialized()
  Forcefields:update_forcefields()
end

timer.Create('forcefield_updater', 250, 0, function()
  Forcefields:update_forcefields()
end)
