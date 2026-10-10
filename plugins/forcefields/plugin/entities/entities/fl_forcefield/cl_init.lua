include('shared.lua')

local material = Material('effects/com_shield003a')
local render_mins = Vector(0, 0, -40)
local flip_angle = Angle(0, 180, 0)

--- Builds the clientside collision mesh between the forcefield and the wall to its right.
function ENT:Initialize()
  local start = self:GetPos() + Vector(0, 0, 50)
  local right = self:GetRight()
  local data = {}
    data.start = start + right * -16
    data.endpos = start + right * -600
    data.filter = self
  local trace = util.TraceLine(data)
  local post_pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50))

  local verts = {
    { pos = Vector(0, 0, -35) },
    { pos = Vector(0, 0, 150) },
    { pos = post_pos + Vector(0, 0, 150) },
    { pos = post_pos + Vector(0, 0, 150) },
    { pos = post_pos - Vector(0, 0, 35) },
    { pos = Vector(0, 0, -35) }
  }

  self:PhysicsFromMesh(verts)
  self:EnableCustomCollisions(true)
end

--- Draws the forcefield and its shield on both sides when the local player is within 2048 units.
function ENT:Draw()
  local pos = self:GetPos()

  if PLAYER:GetPos():DistToSqr(pos) > 4194304 then return end

  local post = self:GetDTEntity(0)
  local up = self:GetUp()
  local matrix = Matrix()

  self:DrawModel()
  matrix:Translate(pos + up * -40 + self:GetForward() * -2)
  matrix:Rotate(self:GetAngles())

  render.SetMaterial(material)

  if IsValid(post) then
    local vertex = self:WorldToLocal(post:GetPos())
    self:SetRenderBounds(render_mins, vertex + up * 150)

    cam.PushModelMatrix(matrix)
      self:draw_shield(vertex)
    cam.PopModelMatrix()

    matrix:Translate(vertex)
    matrix:Rotate(flip_angle)

    cam.PushModelMatrix(matrix)
      self:draw_shield(vertex)
    cam.PopModelMatrix()
  end
end

--- Draws one side of the shield as a textured quad up to the post, unless the forcefield is off.
-- @param vertex [Vector position of the post relative to the forcefield]
function ENT:draw_shield(vertex)
  if self:GetDTInt(0) != 4 then
    local dist = self:GetDTEntity(0):GetPos():Distance(self:GetPos())
    local mat_fac = 45
    local height = 5
    local width = dist / mat_fac
    local top = self:GetUp() * 190
    mesh.Begin(MATERIAL_QUADS, 1)
    mesh.Position(vector_origin)
    mesh.TexCoord(0, 0, 0)
    mesh.AdvanceVertex()
    mesh.Position(top)
    mesh.TexCoord(0, 0, height)
    mesh.AdvanceVertex()
    mesh.Position(vertex + top)
    mesh.TexCoord(0, width, height)
    mesh.AdvanceVertex()
    mesh.Position(vertex)
    mesh.TexCoord(0, width, 0)
    mesh.AdvanceVertex()
    mesh.End()
  end
end
