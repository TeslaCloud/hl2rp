Cable.receive('fl_animation_start', function(actor, animation)
  actor:play_animation(animation)
end)

function Animations:OnActiveCharacterSet(owner, character)
  owner:set_nv('fl_animation_angle', nil)
  owner:set_nv('fl_animation', nil)
end
