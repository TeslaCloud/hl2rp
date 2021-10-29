CMD.name = 'It'
CMD.description = 'command.it.description'
CMD.syntax = 'command.it.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.alias = 'do'
CMD.arguments = 1

function CMD:on_run(player, ...)
  local text, volume = RPCommands:get_phrase_volume(table.concat({...}, ' '):spelling())
  local msg_table = {
    Config.get('chat_it_color'):saturate(volume * 10):lighten(volume * 10),
    Config.get('default_font_size'),
    '(', player, ') ', text
  }

  table.insert(msg_table, {
    sender = player,
    position = player:EyePos(),
    radius = Config.get('talk_radius') * (volume == 0 and 1 or (volume < 0 and (0.8 + volume * 0.2) or (1.2 + volume * 0.4))),
    hear_when_look = true,
    ic = true
  })

  Chatbox.add_text(nil, unpack(msg_table))
  Log:print(Chatbox.message_to_string(msg_table, ' '), 'player_ic')
end
