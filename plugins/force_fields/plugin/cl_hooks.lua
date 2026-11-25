--- Client hooks of the Force Fields plugin: the collision meshes of the force fields that exist
-- when the local player joins.

--- Builds the forcefield collision meshes once the local player has loaded in.
function ForceFields:PlayerInitialized()
  ForceFields:update_force_fields()
end
