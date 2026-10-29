--- Network handlers of the schema on the server: the punch that Overwatch soldiers ask for
-- with the `fl_punch` console command.

Cable.receive('fl_punch', function(actor)
  if !IsValid(actor) then return end

  SCHEMA:punch(actor)
end)
