FACTION.name = 'faction.combine.overwatch.title'
FACTION.description = 'faction.combine.overwatch.desc'
FACTION.phys_desc = 'faction.combine.overwatch.phys_desc'
FACTION.color = Color(225, 115, 100)
FACTION.material = 'flux/hl2rp/factions/overwatch.jpg'
FACTION.has_name = false
FACTION.has_gender = false
FACTION.whitelisted = true
FACTION.default_class = 'soldier'
FACTION.name_template = 'OW.{data:squad}-{rank}.{callback:get_unit_id}'
FACTION:set_data('squad', 'ECHO')
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

FACTION.model_classes = {
  universal = 'ota'
}

FACTION.models.universal = {
  'models/teslacloud/overwatch/overwatch.mdl'
}

FACTION:add_rank('OWS')
FACTION:add_rank('GUARD')
FACTION:add_rank('EOW')

function FACTION:generate_id()
  return math.random(100, 999)
end

function FACTION:get_unit_id(player)
  return player:name():match('%d+$') or self:generate_id()
end

function FACTION:on_player_leave(player)
  if player:is_human() then
    Characters.set_name(player, SCHEMA:get_random_name(player:get_gender()))
  end
end
