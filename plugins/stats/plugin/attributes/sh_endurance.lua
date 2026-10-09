--- Endurance stat: the fitness and toughness of a character, from -3 (terrible) to 3 (superb).
-- Every level slows the drain of stamina and speeds up its regeneration by the
-- `stats_endurance_stamina` config, and speeds up health regeneration and the recovery of
-- hurt limbs by the `stats_endurance_recovery` config. Levels below zero do the opposite.

ATTRIBUTE.name = 'attribute.endurance.title'
ATTRIBUTE.description = 'attribute.endurance.description'
ATTRIBUTE.icon = 'flux/icons/hearts.png'
ATTRIBUTE.type = ATTRIBUTE_STAT
ATTRIBUTE.min = -3
ATTRIBUTE.max = 3
ATTRIBUTE.default = 0
ATTRIBUTE.has_progress = false
ATTRIBUTE.levels = {
  superb = 'attribute.endurance.superb',
  great = 'attribute.endurance.great',
  good = 'attribute.endurance.good',
  fair = 'attribute.endurance.fair',
  mediocre = 'attribute.endurance.mediocre',
  poor = 'attribute.endurance.poor',
  terrible = 'attribute.endurance.terrible'
}

ATTRIBUTE.effects = {
  Stats:percent_effect('ui.effect.stamina_drain', 'stats_endurance_stamina', true, function()
    return Stamina != nil
  end),
  Stats:percent_effect('ui.effect.stamina_regen', 'stats_endurance_stamina', false, function()
    return Stamina != nil
  end),
  Stats:percent_effect('ui.effect.health_regen', 'stats_endurance_recovery', false, function()
    return Damage != nil and Config.get('health_regen') == true
  end),
  Stats:percent_effect('ui.effect.limb_recovery', 'stats_endurance_recovery', false, function()
    return Limbs != nil and Limbs:is_enabled() and (tonumber(Config.get('limbs_recovery')) or 0) > 0
  end)
}
