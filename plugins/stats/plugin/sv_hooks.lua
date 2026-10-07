--- Extends the hearing radius of in character messages by 1.5 meters per point of the listener's perception.
-- @param listener [Player player hearing the message]
-- @param message_data [Table chat message data]
function Stats:AdjustMessageData(listener, message_data)
  if message_data.ic then
    message_data.radius = message_data.radius + (listener:get_attribute('perception'):m()) * 1.5
  end
end

--- Rejects new characters whose attribute points do not add up to the default amount.
-- @param actor [Player player creating the character]
-- @param data [Table character creation data]
-- @return [Number CHAR_ERR_ATTRIBUTE_SUM if the sum is wrong, nil otherwise]
function Stats:PlayerCreateCharacter(actor, data)
  local max_points = self:default_attribute_points()
  local sum = 0

  for k, v in pairs(data.attributes) do
    sum = sum + v
  end

  if sum != max_points then
    return CHAR_ERR_ATTRIBUTE_SUM
  end
end
