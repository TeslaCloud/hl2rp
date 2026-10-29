--- Client-side hooks of the Scanner plugin: the crosshair, the aim and the overlay of a player
-- who controls a scanner.

--- Hides the crosshair while the local player controls a scanner.
-- @return [Boolean false while controlling a scanner, nil otherwise]
function Scanner:ShouldHUDPaintCrosshair()
  if PLAYER:controls_scanner() then
    return false
  end
end

const math_modf = math.modf
const yaw_convar = GetConVar('m_yaw')
const pitch_convar = GetConVar('m_pitch')
const inverse_default_scale = 1 / 0.022

local mouse_rest_x = 0
local mouse_rest_y = 0

--- Stops mouse input from turning the player's view while they control a scanner and writes
-- the mouse deltas into the command, where the server reads them to steer the scanner. The
-- deltas are scaled by `m_yaw` and `m_pitch` relative to their defaults, so sensitivity and an
-- inverted mouse apply as they do to the view; the command holds whole units and the
-- fractional rest is carried over to the next command.
-- @param cmd [CUserCmd command being processed]
-- @param x [Number horizontal mouse delta]
-- @param y [Number vertical mouse delta]
-- @return [Boolean true to override the view angles, nil otherwise]
function Scanner:InputMouseApply(cmd, x, y)
  if !PLAYER:controls_scanner() then return end

  local whole_x, whole_y

  whole_x, mouse_rest_x = math_modf(mouse_rest_x + x * yaw_convar:GetFloat() * inverse_default_scale)
  whole_y, mouse_rest_y = math_modf(mouse_rest_y + y * pitch_convar:GetFloat() * inverse_default_scale)

  cmd:SetMouseX(whole_x)
  cmd:SetMouseY(whole_y)

  return true
end

local scanner_material = Material('effects/combine_binocoverlay')

--- Draws the scanner overlay over the screen while the local player controls a scanner.
function Scanner:HUDPaintBackground()
  if PLAYER:controls_scanner() then
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(scanner_material)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
  end
end
