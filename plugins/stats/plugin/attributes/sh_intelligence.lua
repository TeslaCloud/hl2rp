--- Intelligence stat: the strength of mind of a character, from -3 (terrible) to 3 (superb).
-- Every level lowers the prices vendors ask of the character by the
-- `stats_intelligence_prices` config and raises the progress gained in skills by the
-- `stats_intelligence_learning` config. Levels below zero do the opposite.

ATTRIBUTE.name = 'attribute.intelligence.title'
ATTRIBUTE.description = 'attribute.intelligence.description'
ATTRIBUTE.icon = 'flux/icons/bookmarklet.png'
ATTRIBUTE.type = ATTRIBUTE_STAT
ATTRIBUTE.min = -3
ATTRIBUTE.max = 3
ATTRIBUTE.default = 0
ATTRIBUTE.has_progress = false
ATTRIBUTE.levels = {
  superb = 'attribute.intelligence.superb',
  great = 'attribute.intelligence.great',
  good = 'attribute.intelligence.good',
  fair = 'attribute.intelligence.fair',
  mediocre = 'attribute.intelligence.mediocre',
  poor = 'attribute.intelligence.poor',
  terrible = 'attribute.intelligence.terrible'
}

ATTRIBUTE.effects = {
  Stats:percent_effect('ui.effect.vendor_prices', 'stats_intelligence_prices', true, function()
    return Vendors != nil
  end),
  Stats:percent_effect('ui.effect.skill_progress', 'stats_intelligence_learning', false, function()
    return !table.IsEmpty(Attributes.get_by_type(ATTRIBUTE_SKILL))
  end)
}
