--- Client side of the schema: the `fl_punch` console command, with which Overwatch soldiers
-- punch the player they look at, bound to G by default.

concommand.Add('fl_punch', function()
  Cable.send('fl_punch')
end)

Flux.Binds:add_bind('Punch', 'fl_punch', KEY_G)
