--- Determination stat: the willpower of a character, from -3 (terrible) to 3 (superb).
-- Every level weakens the slowdown, the lower jumps and the aim drift that hurt limbs cause
-- by the `stats_determination_pain` config. Levels below zero strengthen them.
-- The icon is a FontAwesome one, as the content of the schema has no image for this stat.

ATTRIBUTE.name = 'attribute.determination.title'
ATTRIBUTE.description = 'attribute.determination.description'
ATTRIBUTE.icon = 'fa-fist-raised'
ATTRIBUTE.type = ATTRIBUTE_STAT
ATTRIBUTE.min = -3
ATTRIBUTE.max = 3
ATTRIBUTE.default = 0
ATTRIBUTE.has_progress = false
ATTRIBUTE.levels = {
  superb = 'attribute.determination.superb',
  great = 'attribute.determination.great',
  good = 'attribute.determination.good',
  fair = 'attribute.determination.fair',
  mediocre = 'attribute.determination.mediocre',
  poor = 'attribute.determination.poor',
  terrible = 'attribute.determination.terrible'
}

ATTRIBUTE.effects = {
  Stats:percent_effect('ui.effect.limb_penalties', 'stats_determination_pain', true, function()
    return Limbs != nil and Limbs:is_enabled()
  end)
}
