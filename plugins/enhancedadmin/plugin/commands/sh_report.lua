CMD.name = 'Report'
CMD.description = 'command.report.description'
CMD.syntax = 'command.report.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 1
CMD.alias = 'help'

function CMD:on_run(player, ...)
  local text = table.concat({ ... }, ' ')

  local msg_table = {
    Color(184, 59, 94),
    '@report ',
    hook.run('ChatboxGetPlayerColor', player, text, team_chat) or _team.GetColor(player:Team()),
    get_player_name(player),
    hook.run('ChatboxGetMessageColor', player, text, team_chat) or Color(255, 255, 255),
    ': ',
    text:chomp(' '),
    { sender = player }
  }

  local recipients = Bolt:get_staff()

  if !table.HasValue(Bolt:get_staff(), player) then table.insert(recipients, player) end

  Chatbox.add_text(recipients, unpack(msg_table))
end
