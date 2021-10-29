function Stats:AdjustMessageData(player, message_data)
  if message_data.ic then
    message_data.radius = message_data.radius + (player:get_attribute('perception'):m()) * 1.5
  end
end

function Stats:PlayerCreateCharacter(player, data)
  local max_points = self:default_attribute_points()
  local sum = 0

  for k, v in pairs(data.attributes) do
    sum = sum + v
  end

  if sum != max_points then
    return CHAR_ERR_ATTRIBUTE_SUM
  end
end
