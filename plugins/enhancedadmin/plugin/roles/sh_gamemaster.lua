--- Adds the Enhanced Administration commands that set the health and the armor of players to
-- the `gamemaster` role, and through it to every role based on it.

--- Allows the plugin's gamemaster commands.
function ROLE:define_permissions()
  can 'sethealth'
  can 'setarmor'
end
