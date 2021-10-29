include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

function ENT:SpawnFunction(player, trace)
  if !trace.Hit then return end

  local entity = ents.Create('fl_forcefield')

  entity:SetPos(trace.HitPos + Vector(0, 0, 40))
  entity:SetAngles(Angle(0, trace.HitNormal:Angle().y - 90, 0))
  entity:Spawn()
  entity.owner = player

  return entity
end

function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Mode')
  self:DTVar('Entity', 0, 'Dummy')
end

function ENT:Initialize()
  self:SetModel('models/props_combine/combine_fence01b.mdl')
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:DrawShadow(false)

  if !isbool(self.on) then
    self.on = true
  end

  self.mode = self.mode or 1
  self:SetDTInt(0, self.mode)

  local data = {}

  if !self.no_correct then
    data = {}
      data.start = self:GetPos()
      data.endpos = self:GetPos() - Vector(0, 0, 300)
      data.filter = self
    local trace = util.TraceLine(data)

    if trace.Hit and util.IsInWorld(trace.HitPos) and self:IsInWorld() then
      self:SetPos(trace.HitPos + Vector(0, 0, 39.9))
    end

    data = {}
      data.start = self:GetPos()
      data.endpos = self:GetPos() + Vector(0, 0, 150)
      data.filter = self
    trace = util.TraceLine(data)

    if trace.Hit then
      self:SetPos(self:GetPos() - Vector(0, 0, trace.HitPos:Distance(self:GetPos() + Vector(0, 0, 151))))
    end
  end

  data = {}
    data.start = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -16
    data.endpos = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -600
    data.filter = self
  trace = util.TraceLine(data)

  self.post = ents.Create('prop_physics')
  self.post:SetModel('models/props_combine/combine_fence01a.mdl')
  self.post:SetPos(self.force_pos or trace.HitPos - Vector(0, 0, 50))
  self.post:SetAngles(Angle(0, self:GetAngles().y, 0))
  self.post:Spawn()
  self.post.PhysgunDisabled = true
  self.post:SetCollisionGroup(COLLISION_GROUP_WORLD)
  self.post:DrawShadow(false)
  self.post:DeleteOnRemove(self)
  self.post:MakePhysicsObjectAShadow(false, false)
  self:DeleteOnRemove(self.post)

  local verts = {
    { pos = Vector(0, 0, -35) },
    { pos = Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) - Vector(0, 0, 35) },
    { pos = Vector(0, 0, -35) },
  }

  self:PhysicsFromMesh(verts)

  local phys_obj = self:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:SetMaterial('default_silent')
    phys_obj:EnableMotion(false)
  end

  self:SetCustomCollisionCheck(true)
  self:EnableCustomCollisions(true)

  phys_obj = self.post:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:EnableMotion(false)
  end

  self:SetDTEntity(0, self.post)

  self.shield_loop = CreateSound(self, 'ambient/machines/combine_shield_loop3.wav')

  if self.mode == 4 then
    self.on = false
    self:SetSkin(1)
    self.post:SetSkin(1)
    self:EmitSound('shield/deactivate.wav')
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
  end

  self:SetPersistent(true)
end

function ENT:StartTouch(ent)
  if !self.on then return end

  if ent:IsPlayer() then
    if !ent:is_combine() then
      if !ent.shield_touch then
        ent.shield_touch = CreateSound(ent, 'ambient/machines/combine_shield_touch_loop1.wav')
        ent.shield_touch:Play()
        ent.shield_touch:ChangeVolume(0.25, 0)
      else
        ent.shield_touch:Play()
        ent.shield_touch:ChangeVolume(0.25, 0.5)
      end
    end
  end
end

function ENT:Touch(ent)
  if !self.on then return end

  if ent:IsPlayer() then
    if !ent:is_combine() then
      if ent.shield_touch then
        ent.shield_touch:ChangeVolume(0.3, 0)
      end
    end
  end
end

function ENT:EndTouch(ent)
  if !self.on then return end

  if ent:IsPlayer() then
    if !ent:is_combine() then
      if ent.shield_touch then
        ent.shield_touch:FadeOut(0.5)
      end
    end
  end
end

function ENT:Think()
  if IsValid(self) and self.on then
    self.shield_loop:Play()
    self.shield_loop:ChangeVolume(0.4, 0)
  else
    self.shield_loop:Stop()
  end

  local phys_obj = self:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:EnableMotion(false)
  end
end

function ENT:OnRemove()
  if self.shield_loop then
    self.shield_loop:Stop()
  end
end

function ENT:RestoreMode(mode, is_on)
  self.on = is_on
  self.mode = mode
end

function ENT:Use(act, call, type, val)
  local cur_time = CurTime()

  if (self.nextUse or 0) < cur_time then
    self.nextUse = cur_time + 1
  else
    return
  end

  if act:is_combine() then
    self.mode = (self.mode or 1) + 1
    self:SetDTInt(0, self.mode)

    if self.mode > #Forcefields.modes then
      self.mode = 1
      self:SetDTInt(0, self.mode)
    end

    if self.mode == 4 then
      self.on = false
      self:SetSkin(1)
      self.post:SetSkin(1)
      self:EmitSound('shield/deactivate.wav')
      self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    else
      self.on = true
      self:SetSkin(0)
      self.post:SetSkin(0)
      self:EmitSound('shield/activate.wav')
      self:SetCollisionGroup(COLLISION_GROUP_NONE)
    end

    self:EmitSound('buttons/combine_button5.wav', 140, 100 + (self.mode - 1) * 15)
    act:notify('Changed force field mode to: '..Forcefields.modes[self.mode])
  end
end

function ENT:OnRemove()
  if self.shield_loop then
    self.shield_loop:Stop()
    self.shield_loop = nil
  end

  if self.shield_touch then
    self.shield_touch:Stop()
    self.shield_touch = nil
  end
end
