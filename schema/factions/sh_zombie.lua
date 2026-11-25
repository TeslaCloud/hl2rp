--- Zombies and headcrabs: a whitelisted faction that plays the headcrab parasites of
-- Half-Life 2 and the bodies they have taken over, every one of them named Zombie.

FACTION.name = 'faction.zombie.title'
FACTION.description = 'faction.zombie.description'
FACTION.phys_desc = 'faction.zombie.phys_desc'
FACTION.color = Color(7, 135, 32)
FACTION.material = 'flux/hl2rp/factions/citizen.jpg'
FACTION.whitelisted = true
FACTION.name_template = 'Zombie'
FACTION.has_gender = false
FACTION.ooc_hidden = false
FACTION.has_name = false

FACTION.menu_sound = {
  'vo/npc/male01/answer16.wav'
}
FACTION.models = {
  universal = {
    'models/zombie/classic.mdl',
    'models/headcrabclassic.mdl',
    'models/zombie/fast.mdl',
    'models/zombie/poison.mdl',
    'models/headcrab.mdl',
    'models/headcrabblack.mdl'
  }
}

FACTION.model_classes = {
  universal = 'zombie'
}
