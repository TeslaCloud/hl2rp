Config.set('talk_radius', 350)

local ic_color = Color('khaki')
Config.set('chat_ic_color', ic_color)
Config.set('chat_whisper_color', ic_color:desaturate(40):darken(20))
Config.set('chat_yell_color', ic_color:saturate(30):lighten(15))
Config.set('chat_it_color', Color('lightblue'))
Config.set('chat_me_color', Color('lightgreen'))

function RPCommands.add_static_text(data)
  table.insert(RPCommands.texts, data)

  RPCommands:save()

  Cable.send(nil, 'fl_static_text_add', data)
end

function RPCommands.remove_static_text(id)
  table.remove(RPCommands.texts, id)

  RPCommands:save()

  Cable.send(nil, 'fl_static_text_remove', id)
end

function RPCommands:PlayerCanHearPlayersVoice(player, talker)
  if player:EyePos():Distance(talker:EyePos()) > Config.get('talk_radius') then
    return false
  end
end

function RPCommands:ChatboxAdjustPlayerSay(player, text, message_data)
  table.Empty(message_data)

  local msg_table = self:format_message(player, text)

  table.Merge(message_data, msg_table)
  Log:print(Chatbox.message_to_string(msg_table, ' '), 'player_ic')
end

function RPCommands:PlayerCanHear(player, message_data)
  if message_data.hear_when_look then
    local look_pos = player:GetEyeTraceNoCursor().HitPos

    return message_data.sender:GetPos():Distance(look_pos) <= message_data.radius
  end
end

function RPCommands:PlayerCanUseOOC(player)
  if (player:get_player_data('ooc_mute', 0) > CurTime()) then
    return false
  end
end

function RPCommands:LoadData()
  self:load()
end

function RPCommands:SaveData()
  self:save()
end

function RPCommands:save()
  Data.save_plugin('rptexts', RPCommands.texts)
end

function RPCommands:load()
  local texts = Data.load_plugin('rptexts', {})

  self.texts = texts
end

function RPCommands:PlayerInitialized(player)
  Cable.send(player, 'fl_static_text_set', self.texts)
end

function RPCommands:get_phrase_volume(text)
  local volume = 0

  if text:starts('(') then
    local count = text:match('^([(]+)'):len()
    local end_count = (text:match('([)]+)$') or ''):len()

    volume = volume - count

    text = text:sub(count + 1, -end_count - 1)
  elseif text:ends('!!') then
    volume = volume + text:match('([!]+)$'):len() - 1
  end

  volume = math.clamp(volume, -3, 3)

  text:trim()

  return text, volume
end

function RPCommands:get_phrase_table(text)
  local msg_table = {}
  local is_emote = text:starts('*')
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

    local part = v:trim()

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

function RPCommands:format_message(player, text)
  local text, volume = self:get_phrase_volume(text)
  local is_emote = text:starts('*')
  local color = Config.get(is_emote and 'chat_me_color' or 'chat_ic_color')

  local msg_table = {
    color,
    Config.get('default_font_size') + volume * 2,
    player, ' '
  }

  if !is_emote then
    table.add(msg_table, { volume == 0 and t'ui.chat.say' or (volume < 0 and t'ui.chat.whisper' or t'ui.chat.yell'), ': ' })

    if volume == 3 then
      text = text:utf8upper()
    end
  else
    if volume > 0 then
      text = text:sub(1, -text:match('([!]+)$'):len() - 1)
    end
  end

  table.add(msg_table, self:get_phrase_table(text))

  table.insert(msg_table, {
    sender = player,
    position = player:EyePos(),
    radius = Config.get('talk_radius') * (volume == 0 and 1 or (volume < 0 and (0.8 + volume * 0.2) or (1.2 + volume * 0.4))),
    ic = true
  })

  return msg_table
end

function RPCommands:NotifySelf(player, notification_color, message)
  Cable.send(player, 'fl_notify_self', player, notification_color, message)
end
