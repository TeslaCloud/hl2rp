local player_meta = FindMetaTable('Player')

--- Checks whether the player is controlling a scanner.
-- @return [Boolean whether the player controls a scanner]
function player_meta:controls_scanner()
  return self.scanner != nil
end

--- Returns the scanner the player is controlling.
-- @return [Entity scanner, nil if the player does not control one]
function player_meta:get_scanner()
  return self.scanner
end

if SERVER then
  --- Puts the player in control of a scanner, viewing through it while it follows a marker the player steers.
  -- The player's weapons are stored and stripped until they exit the scanner.
  -- @param entity [NPC scanner to control]
  function player_meta:control_scanner(entity)
    entity:AddEntityRelationship(self, D_NU, 99)

    local marker = entity.marker or ents.Create('path_corner')
    local target_name = 'scanner_'..entity:EntIndex()
    marker:SetKeyValue('targetname', target_name)
    marker:SetPos(entity:GetPos())

    entity.target_name = target_name
    entity.marker = marker
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

    entity:CallOnRemove('fl_scanner_removed', function(entity)
      if IsValid(entity.marker) then
        entity.marker:Remove()
      end

      if IsValid(entity.pilot) then
        entity.pilot:exit_scanner()
      end
    end)
  end

  --- Releases the player's scanner and restores their view and weapons.
  function player_meta:exit_scanner()
    local scanner = self.scanner
    scanner.pilot = nil
    scanner:Fire('SetFollowTarget', scanner.target_name)

    self:give_weapons(self.weapons)
    self.weapons = nil
    self.scanner = nil
    self:SetViewEntity(self)
    self:Freeze(false)

    Cable.send(self, 'fl_scanner_update', entity)
  end
end
