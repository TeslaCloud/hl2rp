--- The Combine Civil Authority, the Civil Protection units: a whitelisted human faction whose
-- members wear the Civil Protection uniform, which holds their rank, a regular or a rank
-- leader rank. A unit who carries a CP card is shown under its designation, made of the city,
-- the index, the rank, the tagline and the unit number kept on the card.

FACTION.name = 'faction.combine.cca.title'
FACTION.description = 'faction.combine.cca.desc'
FACTION.color = Color(135, 140, 225)
FACTION.material = 'flux/hl2rp/factions/cca.jpg'
FACTION.whitelisted = true
FACTION.kit = { 'cca_uniform', 'card_cp' }
FACTION.city = 'C24'
FACTION.index = 'i5'
FACTION.tagline = 'TAGLINE'
FACTION.stats = {
  ['strength'] = 1,
  ['endurance'] = 1
}

FACTION.menu_sound = {
  'npc/metropolice/vo/pickupthecan1.wav',
  'npc/metropolice/vo/serve.wav',
  'npc/metropolice/vo/standardloyaltycheck.wav',
  'npc/metropolice/vo/apply.wav',
  'npc/metropolice/vo/control100percent.wav'
}

FACTION:add_rank ''
FACTION:add_rank '.RL'

--- The items that carry the unit number of a Civil Protection unit.
const card_ids = { 'card_cp', 'card_cp_officer' }

--- Returns the unit number kept in the data of a CP card, giving the card a random one from
-- 1000 to 9999 the first time.
-- @param card [Item a CP card or CP officer card]
-- @return [Number the unit number]
function FACTION:get_unit_number(card)
  local unit_number = tonumber(card:get_data('unit_number'))

  if !unit_number then
    unit_number = math.random(1000, 9999)

    card:set_data('unit_number', unit_number)
  end

  return unit_number
end

--- Shows a unit who carries a CP card under its designation, such as `C24.i5.RL:TAGLINE-1234`,
-- and a unit without a card under its real name.
-- @param target [Player the member]
-- @param _name [String the real name of the character]
-- @param rank_table [Map the rank of the member, nil when they have none]
-- @return [String the designation, nil without a card]
function FACTION:get_display_name(target, _name, rank_table)
  for _, card_id in ipairs(card_ids) do
    local card = target:find_item(card_id)

    if card then
      local rank_name = rank_table and rank_table.name or ''

      return self.city..'.'..self.index..rank_name..':'..self.tagline..'-'..self:get_unit_number(card)
    end
  end
end
