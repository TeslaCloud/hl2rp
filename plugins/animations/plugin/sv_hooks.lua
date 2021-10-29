Cable.receive('fl_animation_start', function(player, animation)
  player:play_animation(animation)
end)

function Animations:OnActiveCharacterSet(player, character)
  player:set_nv('fl_animation_angle', nil)
  player:set_nv('fl_animation', nil)
end
