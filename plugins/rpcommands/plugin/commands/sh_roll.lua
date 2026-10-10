--- The `roll` command: rolls a random number and shows it to the players nearby. While the
-- 'roll_versus' config is enabled, rolling while looking at a nearby player rolls for both of
-- them in one line. Plugins can adjust any roll through the `PlayerAdjustRoll` hook.

local config_get = Config.get

CMD.name = 'Roll'
CMD.description = 'command.roll.description'
CMD.syntax = 'command.roll.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.arguments = 0
CMD.no_console = true

local max_range = 1000000

--- Rolls a number for a player and lets plugins adjust it.
-- @param roller [Player player the number is rolled for]
-- @param range [Number maximum value of the roll]
-- @param opponent=nil [Player player the roll is made against, if it is a versus roll]
-- @return [Number whole number from 1 to range]
local function roll_number(roller, range, opponent)
  local natural = math.random(1, range)
  local roll_data = {
    roll = natural,
    natural = natural,
    range = range,
    opponent = opponent
  }

  --- Lets plugins adjust a number rolled with the `roll` command, for example to add a bonus
  -- for an attribute. Called on the server once for every roll: once for a plain roll, and
  -- for a versus roll once for the player who ran the command and once for their opponent.
  -- Every handler can change the roll, so return nothing.
  -- @param roller [Player the player the number is rolled for]
  -- @param roll_data [Map the roll: roll (Number the result, change it in place), natural
  --   (Number the number as it was rolled), range (Number maximum of the roll) and opponent
  --   (Player the other player of a versus roll, nil for a plain roll). The result is
  --   rounded down and kept between 1 and range]
  hook.Run('PlayerAdjustRoll', roller, roll_data)

  local roll = tonumber(roll_data.roll) or natural

  if roll != roll then
    roll = natural
  end

  return math.Clamp(math.floor(roll), 1, range)
end

--- Finds the player a roll is made against: the living player the caller is looking at, or
-- the one whose ragdoll they are looking at, within the talk radius.
-- @param actor [Player player running the command]
-- @return [Player the opponent, Vector where the opponent is; nothing if versus rolls are
--   disabled or the caller is not looking at a nearby player]
local function find_opponent(actor)
  if !config_get('roll_versus') then return end

  local entity = actor:GetEyeTraceNoCursor().Entity

  if !IsValid(entity) then return end

  local target = entity

  if !entity:IsPlayer() and isfunction(entity.get_ragdoll_owner) then
    target = entity:get_ragdoll_owner()
  end

  if !IsValid(target) or !target:IsPlayer() or target == actor or !target:Alive() then return end

  local position = entity:GetPos()

  local radius = config_get('talk_radius')

  if position:DistToSqr(actor:GetPos()) > radius * radius then return end

  return target, position
end

--- Rolls a random number up to a maximum and shows it to nearby players. Looking at a nearby
-- player makes it a versus roll, which also rolls for that player and is shown to the players
-- near either of them.
-- @param actor [Player player running the command]
-- @param range=100 [String maximum value of the roll, up to 1000000]
function CMD:on_run(actor, range)
  range = tonumber(range) or 100

  if range != range then
    range = 100
  end

  range = math.floor(math.Clamp(range, 1, max_range))

  local opponent, opponent_position = find_opponent(actor)
  local roll = roll_number(actor, range, opponent)
  local msg_table = { Color('purple'):lighten(50), actor, ' ' }
  local position = actor:GetPos()

  if opponent then
    local text = t('ui.chat.roll_versus', { roll = roll, max = range })
    local reply = t('ui.chat.roll_versus_reply', { roll = roll_number(opponent, range, actor), max = range })

    table.Add(msg_table, { text, ' ', opponent, reply })

    position = { position, opponent_position }
  else
    local text = t('ui.chat.roll', { roll = roll, max = range })

    table.insert(msg_table, text)
  end

  table.insert(msg_table, {
    sender = actor,
    position = position,
    radius = config_get('talk_radius'),
    hear_when_look = true,
    ic = true
  })

  Chatbox.add_text(nil, unpack(msg_table))

  Log:print(Chatbox.message_to_string(msg_table), 'player_ic')
end
