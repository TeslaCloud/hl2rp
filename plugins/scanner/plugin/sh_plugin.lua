PLUGIN:set_global('Scanners')

require_relative 'cl_hooks'
require_relative 'sv_hooks'

Areas.register_type(
  'scanner_depot',
  'Scanner Depot',
  'An area where the scanners spawn.',
  Color(255, 0, 255),
  function(actor, area, has_entered, pos, cur_time)
  end
)
