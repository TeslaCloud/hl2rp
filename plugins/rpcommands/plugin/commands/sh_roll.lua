CMD.name = 'Roll'
CMD.description = 'command.roll.description'
CMD.syntax = 'command.roll.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.arguments = 0

function CMD:on_run(player, range)
  range = math.max(1, tonumber(range) or 100)

  local msg_table = {
    Color('purple'):lighten(50),
    player,
    t('ui.chat.roll', { roll = math.random(1, range), max = range }),
    {
      sender = player,
      position = player:GetPos(),
      radius = Config.get('talk_radius'),
      hear_when_look = true,
      ic = true
    }
  }

  Chatbox.add_text(nil, unpack(msg_table))

  Log:print(Chatbox.message_to_string(msg_table), 'player_ic')
end
