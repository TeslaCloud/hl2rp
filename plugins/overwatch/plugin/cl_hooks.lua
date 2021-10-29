concommand.Add('fl_punch', function(player)
  Cable.send('fl_punch_cable', player)
end)

Cable.receive('fl_punch_animation', function(player)
  player.AutomaticFrameAdvance = true
  player:SetAnimation(player:LookupSequence("ACT_MELEE_ATTACK1"))
end)
