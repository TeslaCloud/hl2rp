--- Client side of the force field: the collision mesh that prediction uses, built from the
-- post the server placed, and the shield drawn on both sides between the two posts.

include('shared.lua')

local IsValid = IsValid
local material = Material('effects/com_shield003a')
local render_mins = Vector(0, 0, -40)
local render_top = Vector(0, 0, 150)
local shield_offset = Vector(-2, 0, -40)
local shield_top = Vector(0, 0, 190)
local flip_angle = Angle(0, 180, 0)
local shield_matrix = Matrix()

const texture_repeat = 1 / 45
const texture_height = 5

--- Builds the collision mesh from the post once the post has arrived and whenever it changes,
-- and tells the physics engine when the mode has changed, since that changes who collides.
function ENT:Think()
  local post = self:GetPost()

  if post != self.mesh_post and IsValid(post) then
    self:update_mesh(post)
  end

  local mode = self:GetMode()

  if mode != self.mesh_mode then
    self.mesh_mode = mode
    self:CollisionRulesChanged()
  end
end

--- Builds the clientside collision mesh between the forcefield and its post, sets the render
-- bounds to cover the shield and keeps the corners and the texture width of the shield for
-- drawing it.
-- @param post [Entity post at the far end of the shield]
function ENT:update_mesh(post)
  local vertex = self:WorldToLocal(post:GetPos())

  self.mesh_post = post
  self.post_vertex = vertex
  self.shield_corner = vertex + shield_top
  self.shield_width = vertex:Length() * texture_repeat

  self:build_mesh(post)
  self:SetRenderBounds(render_mins, vertex + render_top)

  local phys_obj = self:GetPhysicsObject()

  if IsValid(phys_obj) then
    phys_obj:EnableCollisions(false)
  end
end

--- Draws the forcefield and, unless it is off, its shield on both sides when the local player
-- is within 2048 units.
function ENT:Draw()
  local pos = self:GetPos()

  if PLAYER:GetPos():DistToSqr(pos) > 4_194_304 then return end

  self:DrawModel()

  if !IsValid(self.mesh_post) or self:is_off_mode(self:GetMode()) then return end

  shield_matrix:Identity()
  shield_matrix:Translate(pos)
  shield_matrix:Rotate(self:GetAngles())
  shield_matrix:Translate(shield_offset)

  render.SetMaterial(material)

  cam.PushModelMatrix(shield_matrix)
    self:draw_shield()
  cam.PopModelMatrix()

  shield_matrix:Translate(self.post_vertex)
  shield_matrix:Rotate(flip_angle)

  cam.PushModelMatrix(shield_matrix)
    self:draw_shield()
  cam.PopModelMatrix()
end

--- Draws one side of the shield as a textured quad up to the post, with the corners that
-- `ENT:update_mesh` has kept.
function ENT:draw_shield()
  local vertex = self.post_vertex
  local width = self.shield_width

  mesh.Begin(MATERIAL_QUADS, 1)
  mesh.Position(vector_origin)
  mesh.TexCoord(0, 0, 0)
  mesh.AdvanceVertex()
  mesh.Position(shield_top)
  mesh.TexCoord(0, 0, texture_height)
  mesh.AdvanceVertex()
  mesh.Position(self.shield_corner)
  mesh.TexCoord(0, width, texture_height)
  mesh.AdvanceVertex()
  mesh.Position(vertex)
  mesh.TexCoord(0, width, 0)
  mesh.AdvanceVertex()
  mesh.End()
end
