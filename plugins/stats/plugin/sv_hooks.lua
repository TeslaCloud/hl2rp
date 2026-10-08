--- Extends the hearing radius of in character messages by 1.5 meters per point of the listener's perception.
-- @param listener [Player player hearing the message]
-- @param message_data [Table chat message data]
function Stats:AdjustMessageData(listener, message_data)
  if message_data.ic then
    message_data.radius = message_data.radius + (listener:get_attribute('perception'):m()) * 1.5
  end
end

--- Rejects new characters unless each stat has a whole level in its range and the levels add up to the default points.
-- @param actor [Player player creating the character]
-- @param data [Table character creation data]
-- @return [Number CHAR_ERR_ATTRIBUTE_SUM if the stat levels are not valid, nil otherwise]
function Stats:PlayerCreateCharacter(actor, data)
  local levels = data.attributes

  if !istable(levels) then
    return CHAR_ERR_ATTRIBUTE_SUM
  end

  local stats = Attributes.get_by_type(ATTRIBUTE_STAT)
  local sum = 0

  for k, v in pairs(levels) do
    if !stats[k] then
      return CHAR_ERR_ATTRIBUTE_SUM
    end
  end

  for k, v in pairs(stats) do
    local level = levels[k]

    if !isnumber(level) or level != math.floor(level) or level < v.min or level > v.max then
      return CHAR_ERR_ATTRIBUTE_SUM
    end

    sum = sum + level
  end

  if sum != self:default_attribute_points() then
    return CHAR_ERR_ATTRIBUTE_SUM
  end
end
