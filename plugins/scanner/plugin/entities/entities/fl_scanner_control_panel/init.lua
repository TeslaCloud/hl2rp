include('shared.lua')

AddCSLuaFile('shared.lua')

function ENT:Initialize()
  self:SetModel('models/props_combine/combine_intmonitor001.mdl')
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:PhysicsInit(SOLID_VPHYSICS)

  self:SetPersistent(true)
end
