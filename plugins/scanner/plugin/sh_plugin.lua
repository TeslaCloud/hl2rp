--- Scanner lets players fly the city scanners of Half-Life 2 that they spawn, seeing through
-- them and steering them with the movement keys and the mouse; mouse 1 takes a photo, F
-- toggles the spotlight and E leaves the scanner. The control panel entity can be made
-- static when the Static Entities plugin is loaded.

PLUGIN:set_global('Scanner')

if SERVER and StaticEnts then
  StaticEnts:whitelist_ent 'fl_scanner_control_panel'
end

require_relative 'cl_hooks'
require_relative 'sv_hooks'
