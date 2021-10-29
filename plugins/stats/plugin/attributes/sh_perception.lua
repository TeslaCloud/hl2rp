ATTRIBUTE.name = 'attribute.perception.title'
ATTRIBUTE.description = 'attribute.perception.description'
ATTRIBUTE.icon = 'flux/icons/eye-target.png'
ATTRIBUTE.type = ATTRIBUTE_STAT
ATTRIBUTE.min = -3
ATTRIBUTE.max = 3
ATTRIBUTE.default = 0
ATTRIBUTE.has_progress = false
ATTRIBUTE.levels = {
  superb = 'attribute.perception.superb',
  great = 'attribute.perception.great',
  good = 'attribute.perception.good',
  fair = 'attribute.perception.fair',
  mediocre = 'attribute.perception.mediocre',
  poor = 'attribute.perception.poor',
  terrible = 'attribute.perception.terrible'
}

ATTRIBUTE.effects = {
  {
    text = 'ui.effect.hearing_radius',
    get_value = function(value) return (value > 0 and '+' or value < 0 and '-' or '')..Unit:format((value:abs() * 1.5):m():round(), 'metric') end,
    get_color = function(value) return (value > 0 and Color('lightgreen')) or value < 0 and Color('pink') or color_white end
  }
}
