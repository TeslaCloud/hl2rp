--- Client side library of the Force Fields plugin: rebuilding the collision meshes of the force
-- fields from their posts.

if !ForceFields then
  PLUGIN:set_global('ForceFields')
end

--- Rebuilds the clientside collision mesh of every forcefield between its two posts.
function ForceFields:update_force_fields()
  local force_fields = ents.FindByClass('fl_forcefield')

  for i = 1, #force_fields do
    local forcefield = force_fields[i]
    local post = forcefield:GetPost()

    if IsValid(post) then
      forcefield:update_mesh(post)
    end
  end
end
