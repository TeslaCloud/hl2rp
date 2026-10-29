--- Client side of the schema: the `fl_punch` console command, with which Overwatch soldiers
-- punch the player they look at.

concommand.Add('fl_punch', function()
  Cable.send('fl_punch')
end)
