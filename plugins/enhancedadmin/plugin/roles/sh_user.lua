--- Adds the Enhanced Administration commands that every player may run to the `user` role,
-- and through it to every role based on it: Message, which sends a private message to
-- another player, and Report, which sends a report to the staff.

--- Allows the plugin's player commands.
function ROLE:define_permissions()
  can 'message'
  can 'report'
end
