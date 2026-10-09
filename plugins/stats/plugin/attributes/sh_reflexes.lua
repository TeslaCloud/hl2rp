--- Reflexes stat: the dexterity and reaction of a character, from -3 (terrible) to 3 (superb).
-- Every level lowers the fall damage the character takes by the `stats_reflexes_fall`
-- config. Levels below zero raise it.

ATTRIBUTE.name = 'attribute.reflexes.title'
ATTRIBUTE.description = 'attribute.reflexes.description'
ATTRIBUTE.icon = 'flux/icons/body-balance.png'
ATTRIBUTE.type = ATTRIBUTE_STAT
ATTRIBUTE.min = -3
ATTRIBUTE.max = 3
ATTRIBUTE.default = 0
ATTRIBUTE.has_progress = false
ATTRIBUTE.levels = {
  superb = 'attribute.reflexes.superb',
  great = 'attribute.reflexes.great',
  good = 'attribute.reflexes.good',
  fair = 'attribute.reflexes.fair',
  mediocre = 'attribute.reflexes.mediocre',
  poor = 'attribute.reflexes.poor',
  terrible = 'attribute.reflexes.terrible'
}

ATTRIBUTE.effects = {
  Stats:percent_effect('ui.effect.fall_damage', 'stats_reflexes_fall', true, function()
    return Damage != nil
  end)
}
