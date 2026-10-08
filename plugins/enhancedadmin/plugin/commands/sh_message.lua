CMD.name = 'Message'
CMD.description = 'command.message.description'
CMD.syntax = 'command.message.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 2
CMD.player_arg = 1
CMD.aliases = { 'pm', 'msg' }

--- Sends a private message to a player and echoes it back to the sender.
-- @param actor [Player player sending the message]
-- @param targets [List<Player> recipients, only the first one is used]
function CMD:on_run(actor, targets, ...)
  local text = table.concat({ ... }, ' ')
  local target = targets[1]

  local msg_table = {
    Color(0, 173, 181),
    { icon = 'fa-paper-plane', size = 16, margin = 12, is_data = true },
    get_player_name(target),
    ': ',
    hook.Run('ChatboxGetMessageColor', actor, text) or Color(255, 255, 255),
    text:chomp(' '),
    { sender = actor }
  }

  Chatbox.add_text(actor, unpack(msg_table))

  msg_table[3] = get_player_name(actor)

  Chatbox.add_text(target, unpack(msg_table))
end
