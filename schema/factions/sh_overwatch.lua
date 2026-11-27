--- The Combine Overwatch, the soldiers of the Combine: the whitelisted faction of every synth,
-- shown under its squad, its rank and its unit number, with the OWS, GUARD and EOW ranks.

FACTION.name = 'faction.combine.overwatch.title'
FACTION.description = 'faction.combine.overwatch.desc'
FACTION.color = Color(225, 115, 100)
FACTION.material = 'flux/hl2rp/factions/overwatch.jpg'
FACTION.species = 'synth'
FACTION.whitelisted = true
FACTION.name_template = 'OW.ECHO-{rank}.{name}'
FACTION.stats = {
  ['strength'] = 1,
  ['reflexes'] = 1,
  ['endurance'] = 1,
  ['perception'] = 1,
  ['determination'] = 1
}
FACTION.menu_sound = {
  'npc/combine_soldier/vo/prison_soldier_activatecentral.wav',
  'npc/combine_soldier/vo/prison_soldier_fullbioticoverrun.wav',
  'npc/combine_soldier/vo/prison_soldier_prosecuted7.wav'
}

FACTION:add_rank('OWS')
FACTION:add_rank('GUARD')
FACTION:add_rank('EOW')
