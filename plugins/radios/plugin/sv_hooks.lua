Config.set('radio_chat_color', Color(100, 228, 100))

function Communications.get_active_radio(player)
  for k, v in pairs(player:get_items('hotbar')) do
    if v:is('radio') and v:is_enabled() then
      return v
    end
  end
end

function Communications.speak_radio(player, text, frequency)
  local color = Config.get('radio_chat_color')
  local msg_table = {
    color,
    Config.get('default_font_size'),
    player, ' talks on radio: "', text:chomp(' '):spelling(), '"',
    {
      sender = player,
      position = player:EyePos(),
      radius = Config.get('talk_radius') * 0.5,
      ic = true,
      frequency = frequency
    }
  }

  Chatbox.add_text(nil, unpack(msg_table))
end

function Communications:PlayerCanHear(player, message_data)
  local frequency = message_data.frequency

  if frequency then
    if message_data.sender == player then
      return true
    end

    for k, v in pairs(player:get_items('hotbar')) do
      if v:is('radio') and v:is_enabled() and v:get_frequency() == frequency then
        return true
      end
    end

    return false
  end
end

Cable.receive('fl_set_radio_frequency', function(player, instance_id, frequency)
  local item_obj = Item.find_instance_by_id(instance_id)

  if item_obj then
    item_obj:set_frequency(frequency)
  end
end)

Prefixes:add('radio', {
  prefix = { '/r ', '/radio', ';' },
  callback = function(player, text, team_chat)
    local item_obj = Communications.get_active_radio(player)

    if item_obj then
      local frequency = item_obj:get_frequency()

      Communications.speak_radio(player, text, frequency)
    else
      player:notify('notification.no_active_radio')
    end
  end
})
