--- The City Administrator, who runs the city for the Combine: a whitelisted human faction whose
-- members wear the administrator's suit.

FACTION.name = 'faction.admin.title'
FACTION.description = 'faction.admin.desc'
FACTION.color = Color(210, 220, 100)
FACTION.whitelisted = true
FACTION.material = 'flux/hl2rp/factions/admin.jpg'
FACTION.kit = { 'admin_suit' }
FACTION.stats = {
  ['intelligence'] = 1,
  ['determination'] = 1
}

FACTION.menu_sound = {
  'vo/breencast/br_welcome02.wav',
  'vo/breencast/br_instinct08.wav',
  'vo/breencast/br_welcome07.wav'
}
