function Scanners:ShouldHUDPaintCrosshair()
  if PLAYER:controls_scanner() then
    return false
  end
end

function Scanners:InputMouseApply(cmd)
  if PLAYER:controls_scanner() then
    cmd:SetMouseX(0)
    cmd:SetMouseY(0)

    return true
  end
end

local scanner_material = Material('effects/combine_binocoverlay')

function Scanners:HUDPaintBackground()
  if PLAYER:controls_scanner() then
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(scanner_material)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
  end
end

Cable.receive('fl_scanner_update', function(entity)
  PLAYER.scanner = entity
end)

Cable.receive('fl_scanner_flash', function(entity)
  local flash = DynamicLight(entity:EntIndex())
  flash.pos = entity:GetPos()
  flash.r = 255
  flash.g = 255
  flash.b = 255
  flash.brightness = 5
  flash.Decay = 5000
  flash.Size = 256
  flash.DieTime = CurTime() + 1
end)
