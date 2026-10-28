--- Builds the forcefield collision meshes once the local player has loaded in.
function Forcefields:PlayerInitialized()
  Forcefields:update_forcefields()
end

timer.Create('forcefield_updater', 250, 0, function()
  Forcefields:update_forcefields()
end)
