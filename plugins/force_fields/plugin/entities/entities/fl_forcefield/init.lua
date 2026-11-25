--- Server side of the force field: spawning it with its post, the shield hum and touch
-- sounds, cycling its mode with the use key, and restoring the mode it was saved in.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Spawns a forcefield where the player is looking, facing along the hit surface.
-- @param owner [Player player spawning the forcefield]
-- @param trace [Table eye trace of the player]
-- @return [Entity spawned forcefield, nil if the trace hit nothing]
function ENT:SpawnFunction(owner, trace)
  if !trace.Hit then return end

  local entity = ents.Create('fl_forcefield')

  entity:SetPos(trace.HitPos + Vector(0, 0, 40))
  entity:SetAngles(Angle(0, trace.HitNormal:Angle().y - 90, 0))
  entity:Spawn()
  entity.owner = owner

  return entity
end

--- Snaps the forcefield to the floor, spawns its post at the wall to the right, builds the
-- collision mesh and puts the forcefield into its first mode.
function ENT:Initialize()
  self:SetModel('models/props_combine/combine_fence01b.mdl')
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:DrawShadow(false)

  local data

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

  local start = self:GetPos() + Vector(0, 0, 50)
  local right = self:GetRight()

  data = {}
    data.start = start + right * -16
    data.endpos = start + right * -600
    data.filter = self
  local trace = util.TraceLine(data)

  local post = ents.Create('prop_physics')
  post:SetModel('models/props_combine/combine_fence01a.mdl')
  post:SetPos(self.force_pos or trace.HitPos - Vector(0, 0, 50))
  post:SetAngles(Angle(0, self:GetAngles().y, 0))
  post:Spawn()
  post.PhysgunDisabled = true
  post:SetCollisionGroup(COLLISION_GROUP_WORLD)
  post:DrawShadow(false)
  post:DeleteOnRemove(self)
  post:MakePhysicsObjectAShadow(false, false)
  self:DeleteOnRemove(post)

  self:build_mesh(post)

  local phys_obj = self:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:SetMaterial('default_silent')
    phys_obj:EnableMotion(false)
  end

  self:SetCustomCollisionCheck(true)

  phys_obj = post:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:EnableMotion(false)
  end

  self:SetPost(post)

  self.shield_loop = CreateSound(self, 'ambient/machines/combine_shield_loop3.wav')

  self:apply_mode(self.mode or 1)
  self:SetPersistent(true)
end

--- Starts the touch sound when a non-combine player walks into the active forcefield.
-- @param ent [Entity entity that started touching]
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

--- Keeps the touch sound playing while a non-combine player touches the active forcefield.
-- @param ent [Entity entity touching the forcefield]
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

--- Fades out the touch sound when a non-combine player stops touching the forcefield.
-- @param ent [Entity entity that stopped touching]
function ENT:EndTouch(ent)
  if ent:IsPlayer() then
    if !ent:is_combine() then
      if ent.shield_touch then
        ent.shield_touch:FadeOut(0.5)
      end
    end
  end
end

--- Plays the shield hum while the forcefield is on and keeps it frozen in place.
function ENT:Think()
  if self.on then
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

--- Restores the saved mode and on state of the forcefield.
-- @param mode [Number index into ForceFields.modes]
-- @param is_on [Boolean whether the forcefield is on]
function ENT:RestoreMode(mode, is_on)
  self.on = is_on
  self.mode = mode
end

--- Puts the forcefield into a mode and networks it. The last mode turns the shield off: no
-- hum, the off skin on both posts and no collisions; every other mode turns it on.
-- @param mode [Number index into ForceFields.modes]
function ENT:apply_mode(mode)
  local is_on = !self:is_off_mode(mode)
  local skin = is_on ? 0 : 1
  local post = self:GetPost()

  self.mode = mode
  self.on = is_on
  self:SetMode(mode)
  self:SetSkin(skin)

  if IsValid(post) then
    post:SetSkin(skin)
  end

  self:SetCollisionGroup(is_on ? COLLISION_GROUP_NONE : COLLISION_GROUP_WORLD)
  self:CollisionRulesChanged()
end

--- Cycles a combine player through the forcefield modes, turning the shield off in the 'Off' mode.
-- @param act [Player player using the forcefield]
-- @param _call [Entity caller of the use]
-- @param _type [Number USE_ type]
-- @param _val [Number use value]
function ENT:Use(act, _call, _type, _val)
  if !IsValid(act) or !act:IsPlayer() or !act:is_combine() then return end

  local cur_time = CurTime()

  if (self.next_use or 0) < cur_time then
    self.next_use = cur_time + 1
  else
    return
  end

  local mode = self:GetMode() + 1

  if mode > #ForceFields.modes then
    mode = 1
  end

  self:apply_mode(mode)
  self:EmitSound(self.on ? 'shield/activate.wav' : 'shield/deactivate.wav')
  self:EmitSound('buttons/combine_button5.wav', 140, 100 + (mode - 1) * 15)
  act:notify('notification.forcefield.mode_changed', { mode = ForceFields.modes[mode] })
end

--- Puts a forcefield that the duplicator has restored, such as a static one at map load, back
-- into the mode it was saved in. It has spawned in the first mode before the saved fields
-- were merged into it.
-- @param data [Map saved copy of the forcefield]
function ENT:OnDuplicated(data)
  self:apply_mode(data.mode or 1)
end

--- Leaves the hum and the use cooldown out of the saved copy of the forcefield; the hum is
-- created again when it spawns.
-- @param data [Map saved copy of the forcefield]
function ENT:OnEntityCopyTableFinish(data)
  data.shield_loop = nil
  data.next_use = nil
end

--- Stops the shield hum when the forcefield is removed.
function ENT:OnRemove()
  if self.shield_loop then
    self.shield_loop:Stop()
    self.shield_loop = nil
  end
end
