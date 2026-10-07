concommand.Add('fl_punch', function(client)
  Cable.send('fl_punch_cable', client)
end)

Cable.receive('fl_punch_animation', function(actor)
  actor.AutomaticFrameAdvance = true
  actor:SetAnimation(actor:LookupSequence('ACT_MELEE_ATTACK1'))
end)
