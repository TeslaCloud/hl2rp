--- Builds the forcefield collision meshes once the local player has loaded in.
function ForceFields:PlayerInitialized()
  ForceFields:update_force_fields()
end

timer.Create('forcefield_updater', 250, 0, function()
  ForceFields:update_force_fields()
end)
