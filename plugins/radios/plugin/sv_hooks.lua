Config.set('radio_chat_color', Color(100, 228, 100))

--- Returns the first enabled radio in a player's hotbar.
-- @param owner [Player player to check]
-- @return [Item enabled radio, nil if there is none]
function Communications.get_active_radio(owner)
  for k, v in pairs(owner:get_items('hotbar')) do
    if v:is('radio') and v:is_enabled() then
      return v
    end
  end
end

--- Sends a radio message on a frequency, heard by nearby players and anyone tuned to it.
-- @param speaker [Player player talking]
-- @param text [String message]
-- @param frequency [Number frequency to talk on]
function Communications.speak_radio(speaker, text, frequency)
  local color = Config.get('radio_chat_color')
  local msg_table = {
    color,
    Config.get('default_font_size'),
    speaker, ' talks on radio: "', text:chomp(' '):spelling(), '"',
    {
      sender = speaker,
      position = speaker:EyePos(),
      radius = Config.get('talk_radius') * 0.5,
      ic = true,
      frequency = frequency
    }
  }

  Chatbox.add_text(nil, unpack(msg_table))
end

--- Lets radio messages be heard only by the sender and players with an enabled radio on the same frequency.
-- @param listener [Player player that would hear the message]
-- @param message_data [Table message data, radio messages have a frequency field]
-- @return [Boolean whether the listener hears a radio message, nil for other messages]
function Communications:PlayerCanHear(listener, message_data)
  local frequency = message_data.frequency

  if frequency then
    if message_data.sender == listener then
      return true
    end

    for k, v in pairs(listener:get_items('hotbar')) do
      if v:is('radio') and v:is_enabled() and v:get_frequency() == frequency then
        return true
      end
    end

    return false
  end
end

Cable.receive('fl_set_radio_frequency', function(actor, instance_id, frequency)
  local item_obj = Item.find_instance_by_id(instance_id)

  if item_obj then
    item_obj:set_frequency(frequency)
  end
end)

Prefixes:add('radio', {
  prefix = { '/r ', '/radio', ';' },
  callback = function(actor, text, team_chat)
    local item_obj = Communications.get_active_radio(actor)

    if item_obj then
      local frequency = item_obj:get_frequency()

      Communications.speak_radio(actor, text, frequency)
    else
      actor:notify('notification.no_active_radio')
    end
  end
})
