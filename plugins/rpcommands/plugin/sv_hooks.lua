Config.set('talk_radius', 350)

local ic_color = Color('khaki')
Config.set('chat_ic_color', ic_color)
Config.set('chat_whisper_color', ic_color:desaturate(40):darken(20))
Config.set('chat_yell_color', ic_color:saturate(30):lighten(15))
Config.set('chat_it_color', Color('lightblue'))
Config.set('chat_me_color', Color('lightgreen'))

--- Adds a static text, saves it and sends it to all players.
-- @param data [Table static text with pos, text, name, steamid and time fields]
function RPCommands.add_static_text(data)
  table.insert(RPCommands.texts, data)

  RPCommands:save()

  Cable.send(nil, 'fl_static_text_add', data)
end

--- Removes a static text, saves the change and removes it for all players.
-- @param id [Number index of the static text]
function RPCommands.remove_static_text(id)
  table.remove(RPCommands.texts, id)

  RPCommands:save()

  Cable.send(nil, 'fl_static_text_remove', id)
end

--- Limits voice chat to the talk radius.
-- @param listener [Player player that would hear the voice]
-- @param talker [Player player talking]
-- @return [Boolean false if the talker is out of range, nil otherwise]
function RPCommands:PlayerCanHearPlayersVoice(listener, talker)
  if listener:EyePos():Distance(talker:EyePos()) > Config.get('talk_radius') then
    return false
  end
end

--- Replaces regular chat messages with formatted in character speech and logs them.
-- @param actor [Player player that sent the message]
-- @param text [String message text]
-- @param message_data [Table message data, replaced in place]
function RPCommands:ChatboxAdjustPlayerSay(actor, text, message_data)
  table.Empty(message_data)

  local msg_table = self:format_message(actor, text)

  table.Merge(message_data, msg_table)
  Log:print(Chatbox.message_to_string(msg_table, ' '), 'player_ic')
end

--- Lets look-based messages be heard by players looking within the message radius of the sender.
-- @param listener [Player player that would hear the message]
-- @param message_data [Table chat message data]
-- @return [Boolean whether the listener hears a look-based message, nil for other messages]
function RPCommands:PlayerCanHear(listener, message_data)
  if message_data.hear_when_look then
    local look_pos = listener:GetEyeTraceNoCursor().HitPos

    return message_data.sender:GetPos():Distance(look_pos) <= message_data.radius
  end
end

--- Prevents gagged players from using OOC chat.
-- @param actor [Player player trying to use OOC]
-- @return [Boolean false while the player is gagged, nil otherwise]
function RPCommands:PlayerCanUseOOC(actor)
  if actor:get_player_data('ooc_mute', 0) > CurTime() then
    return false
  end
end

--- Loads the static texts with the rest of the server data.
function RPCommands:LoadData()
  self:load()
end

--- Saves the static texts with the rest of the server data.
function RPCommands:SaveData()
  self:save()
end

--- Saves the static texts to the plugin data.
function RPCommands:save()
  Data.save_plugin('rptexts', RPCommands.texts)
end

--- Loads the static texts from the plugin data.
function RPCommands:load()
  local texts = Data.load_plugin('rptexts', {})

  self.texts = texts
end

--- Sends all static texts to a player once they have loaded in.
-- @param actor [Player player that has loaded in]
function RPCommands:PlayerInitialized(actor)
  Cable.send(actor, 'fl_static_text_set', self.texts)
end

--- Determines how loud a phrase is from its leading parentheses or trailing exclamation marks.
-- @param text [String phrase]
-- @return [String phrase without the parentheses, Number volume from -3 to 3]
function RPCommands:get_phrase_volume(text)
  local volume = 0

  if text:start_with('(') then
    local count = text:match('^([(]+)'):len()
    local end_count = (text:match('([)]+)$') or ''):len()

    volume = volume - count

    text = text:sub(count + 1, -end_count - 1)
  elseif text:end_with('!!') then
    volume = volume + text:match('([!]+)$'):len() - 1
  end

  volume = math.clamp(volume, -3, 3)

  text:strip()

  return text, volume
end

--- Splits a phrase into alternating speech and asterisk emote parts with quotes and colors.
-- @param text [String phrase]
-- @return [Table chat message parts]
function RPCommands:get_phrase_table(text)
  local msg_table = {}
  local is_emote = text:start_with('*')
  local text_parts = {}

  for k, v in pairs(text:split('*')) do
    if v != '' and v:match('%S') then
      table.insert(text_parts, v)
    end
  end

  local count = #text_parts

  if !is_emote then
    table.insert(msg_table, '"')
  end

  for k, v in pairs(text_parts) do
    if k != 1 then
      if !is_emote then
        table.insert(msg_table, Config.get('chat_ic_color'))
      end

      table.insert(msg_table, is_emote and '" ' or ' "')
    end

    local part = v:strip()

    if is_emote then
      table.insert(msg_table, Config.get('chat_me_color'))

      if part:is_upper() then
        part = part:utf8lower()
      end
    end

    if k == 1 or k == count then
      part = part:spelling(is_emote, k == 1 and count != 1)
    end

    table.insert(msg_table, part)

    is_emote = !is_emote
  end

  if is_emote then
    table.insert(msg_table, '"')
  end

  return msg_table
end

--- Formats an in character message, scaling its font size, verb and hearing radius by the phrase volume.
-- @param speaker [Player player speaking]
-- @param text [String phrase]
-- @return [Table chat message parts ending with the message data]
function RPCommands:format_message(speaker, text)
  local text, volume = self:get_phrase_volume(text)
  local is_emote = text:start_with('*')
  local color = Config.get(is_emote and 'chat_me_color' or 'chat_ic_color')

  local msg_table = {
    color,
    Config.get('default_font_size') + volume * 2,
    speaker, ' '
  }

  if !is_emote then
    table.Add(msg_table, {
      volume == 0 and t'ui.chat.say' or (volume < 0 and t'ui.chat.whisper' or t'ui.chat.yell'),
      ': '
    })

    if volume == 3 then
      text = text:utf8upper()
    end
  else
    if volume > 0 then
      text = text:sub(1, -text:match('([!]+)$'):len() - 1)
    end
  end

  table.Add(msg_table, self:get_phrase_table(text))

  table.insert(msg_table, {
    sender = speaker,
    position = speaker:EyePos(),
    radius =
      Config.get('talk_radius') * (volume == 0 and 1 or (volume < 0 and (0.8 + volume * 0.2) or (1.2 + volume * 0.4))),
    ic = true
  })

  return msg_table
end

--- Sends a colored chat message to a single player.
-- @param receiver [Player player to send the message to]
-- @param notification_color [Color color of the message]
-- @param message [String message]
function RPCommands:NotifySelf(receiver, notification_color, message)
  Cable.send(receiver, 'fl_notify_self', receiver, notification_color, message)
end
