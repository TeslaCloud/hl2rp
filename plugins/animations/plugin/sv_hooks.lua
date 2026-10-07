Cable.receive('fl_animation_start', function(actor, animation)
  actor:play_animation(animation)
end)

--- Clears the player's animation state when they switch characters.
-- @param owner [Player player whose character was set]
-- @param character [Character newly active character]
function Animations:OnActiveCharacterSet(owner, character)
  owner:set_nv('fl_animation_angle', nil)
  owner:set_nv('fl_animation', nil)
end
