--- Citizens: the people who live in the city under the Combine, and every human who wears
-- nothing that makes them a member of another faction. Members of the Civil Workers' Union
-- hold the CWU rank, which is kept in the record of the character.

FACTION.name = 'faction.citizen.title'
FACTION.description = 'faction.citizen.desc'
FACTION.color = Color(225, 185, 135)
FACTION.material = 'flux/hl2rp/factions/citizen.jpg'
FACTION.menu_sound = {
  'vo/npc/male01/answer16.wav',
  'vo/npc/male01/answer25.wav',
  'vo/npc/male01/answer28.wav',
  'vo/npc/male01/answer37.wav',
  'vo/npc/male01/finally.wav',
  'vo/npc/male01/question05.wav',
  'vo/npc/male01/question23.wav',
  'vo/npc/male01/question20.wav',
  'vo/npc/male01/question19.wav'
}

FACTION:add_rank ''
FACTION:add_rank 'CWU'
