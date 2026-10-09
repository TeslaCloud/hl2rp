--- Stats gives every character six stats that go from -3 (terrible) to 3 (superb):
-- endurance, intelligence, perception, reflexes, strength and determination.
-- A new character spreads the points of the `stats_creation_points` config over them in a
-- stage of character creation, and the server checks the result. The faction of a character
-- adds the bonuses it lists in `FACTION.stats`, as boosts of the Attributes plugin that
-- carry the `Stats.faction_boost_id` identifier and last for as long as the character is in
-- the faction; the `stats_faction_bonuses` config turns them off.
--
-- Every level of a stat changes something in play by the share its config sets, and a
-- level below zero changes it the other way:
-- * perception: the range at which in-character speech is heard
--   (`stats_perception_hearing`, 1.5 meters);
-- * endurance: slower stamina drain and faster stamina regeneration
--   (`stats_endurance_stamina`, 10%), faster health regeneration and recovery of hurt limbs
--   (`stats_endurance_recovery`, 10%);
-- * strength: heavier objects can be picked up and are thrown harder
--   (`stats_strength_lifting`, 10%);
-- * reflexes: less fall damage (`stats_reflexes_fall`, 10%);
-- * intelligence: lower prices when buying from vendors (`stats_intelligence_prices`, 2%)
--   and more progress in skills (`stats_intelligence_learning`, 10%);
-- * determination: weaker slowdown and aim drift from hurt limbs
--   (`stats_determination_pain`, 10%).
--
-- The effects run through the hooks of the Stamina, Pickup Objects, Damage, Limb Damage,
-- Vendors and Attributes plugins, so an effect whose plugin is not loaded simply does
-- nothing. Each stat lists its effects in the `effects` field of its definition, which the
-- creation stage and the Attributes tab show.
-- @module [Stats]

PLUGIN:set_global('Stats')

Stats.faction_boost_id = 'faction'
Stats.min_hearing_radius = 1

require_relative 'sh_enums'
require_relative 'sh_hooks'
require_relative 'cl_hooks'
require_relative 'sv_hooks'

--- Returns the points a new character has to spread over its stats: the
-- `stats_creation_points` config, never more than the stats can take. The levels a player
-- picks have to add up to this number.
-- @return [Number attribute points]
function Stats:default_attribute_points()
  local key = 'stats_creation_points'
  local points = tonumber(Config.get(key)) or tonumber(Config.get_default(key)) or 0
  local highest = 0

  for k, v in pairs(Attributes.get_by_type(ATTRIBUTE_STAT)) do
    highest = highest + v.max
  end

  return math.min(math.floor(points), highest)
end

--- Checks whether characters get the stat bonuses of their faction.
-- @return [Boolean the `stats_faction_bonuses` config; true while it has no value]
function Stats:faction_bonuses_enabled()
  return Config.get('stats_faction_bonuses') != false
end

--- Returns the stat bonuses that a faction lists in its `stats` field. Entries that do not
-- name a registered stat or do not hold a number other than zero are left out.
-- ```
-- -- factions/sh_cca.lua
-- FACTION.stats = {
--   ['strength'] = 1,
--   ['endurance'] = 1
-- }
-- ```
-- @param faction_table [Faction faction to read the bonuses of; anything else has none]
-- @return [Map bonus levels keyed by stat ID]
function Stats:get_faction_bonuses(faction_table)
  local bonuses = {}

  if !istable(faction_table) or !istable(faction_table.stats) then
    return bonuses
  end

  local stats = Attributes.get_by_type(ATTRIBUTE_STAT)

  for k, v in pairs(faction_table.stats) do
    local bonus = tonumber(v)

    if stats[k] and bonus and bonus == bonus and bonus != 0 then
      bonuses[k] = bonus
    end
  end

  return bonuses
end

--- Returns the bonus that the faction of a player currently adds to one of their stats:
-- the value of the boost that carries the `Stats.faction_boost_id` identifier.
-- @param target [Player]
-- @param attribute_id [String ID of the stat]
-- @return [Number bonus levels, or nil if the stat has no faction bonus]
function Stats:get_faction_boost(target, attribute_id)
  for k, v in ipairs(target:get_attribute_boosts(attribute_id)) do
    if v.id == self.faction_boost_id then
      return tonumber(v.value)
    end
  end
end
