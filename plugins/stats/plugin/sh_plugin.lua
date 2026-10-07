PLUGIN:set_global('Stats')

require_relative 'cl_hooks'
require_relative 'sv_hooks'

--- Returns the attribute points new characters get, half the number of stat attributes rounded down.
-- @return [Number attribute points]
function Stats:default_attribute_points()
  return math.floor(table.Count(Attributes.get_by_type(ATTRIBUTE_STAT)) * 0.5)
end
