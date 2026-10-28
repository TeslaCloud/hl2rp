--- Hides the crosshair while the local player controls a scanner.
-- @return [Boolean false while controlling a scanner, nil otherwise]
function Scanners:ShouldHUDPaintCrosshair()
  if PLAYER:controls_scanner() then
    return false
  end
end

--- Stops mouse input from turning the player's view while they control a scanner.
-- @param cmd [CUserCmd command being processed]
-- @return [Boolean true to override the view angles, nil otherwise]
function Scanners:InputMouseApply(cmd)
  if PLAYER:controls_scanner() then
    cmd:SetMouseX(0)
    cmd:SetMouseY(0)

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
