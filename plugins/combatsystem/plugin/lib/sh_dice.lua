mod 'Dice'

local random = math.random

--- Rolls several dice and sums them.
-- @param number [Number amount of dice]
-- @param edges [Number sides on each die]
-- @return [Number sum of the rolls]
function Dice.roll(number, edges)
  local value = 0

  for i = 1, number do
    value = value + random(1, edges)
  end

  return value
end

--- Rolls the dice twice and keeps the higher sum.
-- @param number [Number amount of dice]
-- @param edges [Number sides on each die]
-- @return [Number higher of the two sums]
function Dice.roll_advantaged(number, edges)
  return math.max(Dice.roll(number, edges), Dice.roll(number, edges))
end

--- Rolls the dice twice and keeps the lower sum.
-- @param number [Number amount of dice]
-- @param edges [Number sides on each die]
-- @return [Number lower of the two sums]
function Dice.roll_disadvantaged(number, edges)
  return math.min(Dice.roll(number, edges), Dice.roll(number, edges))
end

--- Returns a normally distributed random integer centered between two bounds.
-- @param from [Number lower bound]
-- @param to [Number upper bound]
-- @return [Number rounded value clamped to the bounds]
function Dice.gauss(from, to)
  local variance = (to - from) * 0.5
  local mean = from + variance
  local number = math.sqrt(-2 * variance * math.log(random())) * math.cos(2 * math.pi * random()) + mean

  number = math.Round(number)

  return math.Clamp(number, from, to)
end

--- Rolls four three-sided fudge dice, giving a value from -4 to 4, and adds it to a number.
-- @param number=0 [Number value to add the roll to]
-- @return [Number number plus the roll]
function Dice.fudge(number)
  return (number or 0) + Dice.roll(4, 3) - 8
end

--- Ranks a roll as a critical failure, a critical success or a regular result.
-- @param value [Number roll to rank]
-- @param min [Number value at or below which the roll is a critical failure]
-- @param max [Number value at or above which the roll is a critical success]
-- @return [Number RANK_CRITFAIL, RANK_CRITLUCK or RANK_REGULAR]
function Dice.get_rank(value, min, max)
  if value <= min then
    return RANK_CRITFAIL
  elseif value >= max then
    return RANK_CRITLUCK
  else
    return RANK_REGULAR
  end
end
