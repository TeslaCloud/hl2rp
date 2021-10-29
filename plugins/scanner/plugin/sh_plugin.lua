PLUGIN:set_global('Scanners')

require_relative 'cl_hooks'
require_relative 'sv_hooks'

Areas.register_type(
  'scanner_depot',
  'Scanner Depot',
  'An area where the scanners spawn.',
  function(player, area, poly, has_entered, cur_pos, cur_time)
  end
)
