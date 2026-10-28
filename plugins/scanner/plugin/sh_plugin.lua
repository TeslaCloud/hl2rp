PLUGIN:set_global('Scanners')

require_relative 'cl_hooks'
require_relative 'cl_nethooks'
require_relative 'sv_hooks'

Areas.register_type(
  'scanner_depot',
  'Scanner Depot',
  'An area where the scanners spawn.',
  Color(255, 0, 255),
  function(_actor, _area, _has_entered, _pos, _cur_time)
  end
)
