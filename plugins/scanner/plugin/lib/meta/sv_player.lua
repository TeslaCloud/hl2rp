--- Server-side player extensions of the Scanner plugin: taking control of a scanner and
-- leaving it.

local player_meta = FindMetaTable('Player')

--- Puts the player in control of a scanner, viewing through it while it follows a marker the player steers.
-- The aim of the scanner starts level, in the direction the scanner faces. The player's
-- weapons are stored and stripped until they exit the scanner.
-- @param entity [NPC scanner to control]
function player_meta:control_scanner(entity)
  if self:controls_scanner() then
    self:exit_scanner()
  end

  entity:AddEntityRelationship(self, D_NU, 99)

  local marker = entity.marker or ents.Create('path_corner')
  local target_name = 'scanner_'..entity:EntIndex()
  marker:SetKeyValue('targetname', target_name)
  marker:SetPos(entity:GetPos())

  entity.target_name = target_name
  entity.marker = marker
  entity.aim_angle = Angle(0, entity:GetAngles().y, 0)
  entity.pilot = self
  entity.flashlight = false
  entity:SetKeyValue('SpotlightDisabled', 'true')
  entity:SetKeyValue('ShouldInspect', 'false')

  self.scanner = entity
  self.weapons = self:get_weapons_list()
  self:SetViewEntity(entity)
  self:StripWeapons()

  Cable.send(self, 'fl_scanner_update', entity)

  entity:Fire('SetDistanceOverride', 64)
  entity:Fire('SetFollowTarget', target_name)

  entity:CallOnRemove('fl_scanner_removed', function(scanner)
    if IsValid(scanner.marker) then
      scanner.marker:Remove()
    end

    if IsValid(scanner.pilot) then
      scanner.pilot:exit_scanner()
    end
  end)
end

--- Releases the player's scanner and restores their view and the weapons that were stored
-- when they took control, if any are still stored.
function player_meta:exit_scanner()
  local scanner = self.scanner

  if IsValid(scanner) then
    scanner.pilot = nil
    scanner:Fire('SetFollowTarget', scanner.target_name)
  end

  if self.weapons then
    self:give_weapons(self.weapons)
  end

  self.weapons = nil
  self.scanner = nil
  self:SetViewEntity(self)
  self:Freeze(false)

  Cable.send(self, 'fl_scanner_update', nil)
end
