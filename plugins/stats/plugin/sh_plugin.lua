PLUGIN:set_global('Stats')

require_relative 'cl_hooks'
require_relative 'sv_hooks'

function Stats:default_attribute_points()
  return math.floor(table.count(Attributes.get_by_type(ATTRIBUTE_STAT)) * 0.5)
end
