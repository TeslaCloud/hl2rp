function Forcefields:update_forcefields()
  for k, v in pairs(ents.FindByClass('fl_forcefield')) do
    if IsValid(v:GetDTEntity(0)) then
      local start_pos = v:GetDTEntity(0):GetPos() - Vector(0, 0, 50)
      local verts = {
        { pos = Vector(0, 0, -35) },
        { pos = Vector(0, 0, 150) },
        { pos = v:WorldToLocal(start_pos) + Vector(0, 0, 150) },
        { pos = v:WorldToLocal(start_pos) + Vector(0, 0, 150) },
        { pos = v:WorldToLocal(start_pos) - Vector(0, 0, 35) },
        { pos = Vector(0, 0, -35) },
      }

      v:PhysicsFromMesh(verts)
      v:EnableCustomCollisions(true)
      v:GetPhysicsObject():EnableCollisions(false)
    end
  end
end

function Forcefields:PlayerInitialized()
  Forcefields:update_forcefields()
end

timer.Create('forcefield_updater', 250, 0, function()
  Forcefields:update_forcefields()
end)
