PLUGIN:set_global('Scanners')

if SERVER and StaticEnts then
  StaticEnts:whitelist_ent 'fl_scanner_control_panel'
end

require_relative 'cl_hooks'
require_relative 'cl_nethooks'
require_relative 'sv_hooks'
