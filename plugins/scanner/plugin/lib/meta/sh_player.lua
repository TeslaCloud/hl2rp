local player_meta = FindMetaTable('Player')

function player_meta:controls_scanner()
  return self.scanner != nil
end

function player_meta:get_scanner()
  return self.scanner
end

if SERVER then
  function player_meta:control_scanner(entity)
    entity:AddEntityRelationship(self, D_NU, 99)

    local marker = entity.marker or ents.create('path_corner')
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
