mod 'Dice'

function Dice.roll(number, edges)
  local value = 0

  for i = 1, number do
    value = value + math.random(1, edges)
  end

  return value
end

function Dice.roll_advantaged(number, edges)
  return math.max(Dice.roll(number, edges), Dice.roll(number, edges))
end

function Dice.roll_disadvantaged(number, edges)
  return math.min(Dice.roll(number, edges), Dice.roll(number, edges))
end

function Dice.gauss(from, to)
  local variance = (to - from) * 0.5
  local mean = from + variance
  local number = math.sqrt(-2 * variance * math.log(math.random())) * math.cos(2 * math.pi * math.random()) + mean

  number = math.Round(number)

  return math.Clamp(number, from, to)
end

function Dice.fudge(number)
  return (number or 0) + Dice.roll(4, 3) - 8
end

function Dice.get_rank(value, min, max)
  if value <= min then
    return RANK_CRITFAIL
  elseif value >= max then
    return RANK_CRITLUCK
  else
    return RANK_REGULAR
  end
end
