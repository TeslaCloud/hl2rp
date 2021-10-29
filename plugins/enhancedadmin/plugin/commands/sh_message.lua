CMD.name = 'Message'
CMD.description = 'command.message.description'
CMD.syntax = 'command.message.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 2
CMD.player_arg = 1
CMD.aliases = { 'pm', 'msg' }

function CMD:on_run(player, targets, ...)
  local text = table.concat({ ... }, ' ')
  local target = targets[1]

  local msg_table = {
    Color(0, 173, 181),
    { icon = 'fa-paper-plane', size = 16, margin = 12, is_data = true },
    get_player_name(target),
    ': ',
    hook.run('ChatboxGetMessageColor', player, text, team_chat) or Color(255, 255, 255),
    text:chomp(' '),
    { sender = player }
  }

  Chatbox.add_text(player, unpack(msg_table))

  msg_table[3] = get_player_name(player)

  Chatbox.add_text(target, unpack(msg_table))
end
