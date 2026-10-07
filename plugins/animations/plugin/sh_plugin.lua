PLUGIN:set_global('Animations')

local stored = Animations.stored or {}
Animations.stored = stored

do
  --- Registers an animation that players can play from the context menu.
  -- @param data [Table animation data with id, name, enter, anim, exit and duration fields]
  function Animations:register_anim(data)
    stored[data.id] = data
  end

  --- Returns a registered animation.
  -- @param id [String ID of the animation]
  -- @return [Table animation data, nil if it is not registered]
  function Animations:get(id)
    return stored[id]
  end

  --- Returns all registered animations.
  -- @return [Map animation data by ID]
  function Animations:all()
    return stored
  end
end

require_relative 'cl_hooks'
require_relative 'sv_hooks'

--- Stops an animating player from moving and makes them leave the animation when they press a movement key.
-- @param actor [Player player being moved]
-- @param move_data [CMoveData movement data of the player]
function Animations:Move(actor, move_data)
  if actor:get_nv('fl_animation_angle') then
    move_data:SetVelocity(vector_origin)
    move_data:SetForwardSpeed(0)
    move_data:SetSideSpeed(0)

    if move_data:KeyPressed(IN_FORWARD) or move_data:KeyPressed(IN_MOVELEFT)
    or move_data:KeyPressed(IN_MOVERIGHT) or move_data:KeyPressed(IN_BACK)
    or move_data:KeyPressed(IN_JUMP) then
      actor:leave_animation()
    end
  end
end

--- Keeps an animating player rendered at the angle they started the animation at.
-- @param actor [Player player being animated]
function Animations:UpdateAnimation(actor)
  local angle = actor:get_nv('fl_animation_angle')

  if angle then
    actor:SetRenderAngles(angle)
  end
end

Animations:register_anim({
  id = 'sit_ground',
  name = 'animations.sit_ground.name',
  enter = 'idle_to_sit_ground',
  anim = 'sit_ground',
  exit = 'sit_ground_to_idle',
  duration = 0
})
