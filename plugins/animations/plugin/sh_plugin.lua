PLUGIN:set_global('Animations')

local stored = Animations.stored or {}
Animations.stored = stored

do
  function Animations:register_anim(data)
    stored[data.id] = data
  end

  function Animations:get(id)
    return stored[id]
  end

  function Animations:all()
    return stored
  end
end

require_relative 'cl_hooks'
require_relative 'sv_hooks'

function Animations:Move(player, move_data)
  if player:get_nv('fl_animation_angle') then
    move_data:SetVelocity(vector_origin)
    move_data:SetForwardSpeed(0)
    move_data:SetSideSpeed(0)

    if move_data:KeyPressed(IN_FORWARD) or move_data:KeyPressed(IN_MOVELEFT)
    or move_data:KeyPressed(IN_MOVERIGHT) or move_data:KeyPressed(IN_BACK)
    or move_data:KeyPressed(IN_JUMP) then
      player:leave_animation()
    end
  end
end

function Animations:UpdateAnimation(player)
  local angle = player:get_nv('fl_animation_angle')

  if angle then
    player:SetRenderAngles(angle)
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
