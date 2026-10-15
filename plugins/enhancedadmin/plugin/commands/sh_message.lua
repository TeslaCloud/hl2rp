--- The `message` command: `/message <player> <text>` sends a private message to a player,
-- the one whose name is typed exactly or the first one a target selector finds.

CMD.name = 'Message'
CMD.description = 'command.message.description'
CMD.syntax = 'command.message.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 2
CMD.arg_types = { 'player', 'text' }
CMD.aliases = { 'pm', 'msg' }

--- Sends a private message to a player and echoes it back to the sender.
-- @param actor [Player player sending the message]
-- @param targets [List<Player> recipients, only the first one is used]
-- @param text [String the message, as it was typed]
function CMD:on_run(actor, targets, text)
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
