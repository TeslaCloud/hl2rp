--- Client-side receivers of the Scanner plugin: the scanner that the local player controls
-- and the light of the flash of a scanner.

Cable.receive('fl_scanner_update', function(entity)
  PLAYER.scanner = entity
end)

Cable.receive('fl_scanner_flash', function(entity)
  if !IsValid(entity) then return end

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
