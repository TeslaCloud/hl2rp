--- The Combine Civil Authority, the Civil Protection units: a whitelisted faction named by
-- unit, from the city, the index, the rank, the tagline and a unit ID, with a regular and a
-- rank leader rank.

FACTION.name = 'faction.combine.cca.title'
FACTION.description = 'faction.combine.cca.desc'
FACTION.phys_desc = 'faction.combine.cca.phys_desc'
FACTION.color = Color(135, 140, 225)
FACTION.material = 'flux/hl2rp/factions/cca.jpg'
FACTION.has_name = false
FACTION.has_gender = true
FACTION.whitelisted = true
FACTION.name_template = '{data:city}.{data:index}{rank}:{data:tagline}-{callback:get_unit_id}'
FACTION:set_data('tagline', 'TAGLINE')
FACTION:set_data('city', 'C24')
FACTION:set_data('index', 'i5')
FACTION.stats = {
  ['strength'] = 1,
  ['endurance'] = 1
}

FACTION.menu_sound = {
  'npc/metropolice/vo/pickupthecan1.wav',
  'npc/metropolice/vo/serve.wav',
  'npc/metropolice/vo/standardloyaltycheck.wav',
  'npc/metropolice/vo/apply.wav',
  'npc/metropolice/vo/control100percent.wav'
}

FACTION.model_classes = {
  male = 'metrocop',
  female = 'female'
}

FACTION.models = {
  male = {
    'models/teslacloud/cca/male01.mdl',
    'models/teslacloud/cca/male02.mdl',
    'models/teslacloud/cca/male03.mdl',
    'models/teslacloud/cca/male04.mdl',
    'models/teslacloud/cca/male05.mdl',
    'models/teslacloud/cca/male06.mdl',
    'models/teslacloud/cca/male07.mdl',
    'models/teslacloud/cca/male08.mdl',
    'models/teslacloud/cca/male09.mdl',
    'models/teslacloud/cca/male10.mdl'
  },
  female = {
    'models/teslacloud/cca/female01.mdl',
    'models/teslacloud/cca/female02.mdl',
    'models/teslacloud/cca/female03.mdl',
    'models/teslacloud/cca/female04.mdl',
    'models/teslacloud/cca/female05.mdl',
    'models/teslacloud/cca/female06.mdl',
    'models/teslacloud/cca/female07.mdl'
  }
}

FACTION:add_rank ''
FACTION:add_rank '.RL'

--- Generates a random unit ID from 1000 to 9999.
-- @return [Number unit ID]
function FACTION:generate_id()
  return math.random(1000, 9999)
end

FACTION.get_unit_id = SCHEMA.get_unit_id
