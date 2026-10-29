--- Hides the crosshair while the local player controls a scanner.
-- @return [Boolean false while controlling a scanner, nil otherwise]
function Scanners:ShouldHUDPaintCrosshair()
  if PLAYER:controls_scanner() then
    return false
  end
end

--- Stops mouse input from turning the player's view while they control a scanner and writes
-- the mouse deltas into the command, where the server reads them to steer the scanner.
-- @param cmd [CUserCmd command being processed]
-- @param x [Number horizontal mouse delta]
-- @param y [Number vertical mouse delta]
-- @return [Boolean true to override the view angles, nil otherwise]
function Scanners:InputMouseApply(cmd, x, y)
  if PLAYER:controls_scanner() then
    cmd:SetMouseX(x)
    cmd:SetMouseY(y)

    return true
  end
end

local scanner_material = Material('effects/combine_binocoverlay')

--- Draws the scanner overlay over the screen while the local player controls a scanner.
function Scanners:HUDPaintBackground()
  if PLAYER:controls_scanner() then
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(scanner_material)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
  end
end
