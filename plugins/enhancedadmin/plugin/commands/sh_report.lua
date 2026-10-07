CMD.name = 'Report'
CMD.description = 'command.report.description'
CMD.syntax = 'command.report.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 1
CMD.alias = 'help'

function CMD:on_run(actor, ...)
  local text = table.concat({ ... }, ' ')

  local msg_table = {
    Color(184, 59, 94),
    '@report ',
    hook.Run('ChatboxGetPlayerColor', actor, text, team_chat) or team.GetColor(actor:Team()),
    get_player_name(actor),
    hook.Run('ChatboxGetMessageColor', actor, text, team_chat) or Color(255, 255, 255),
    ': ',
    text:chomp(' '),
    { sender = actor }
  }

  local recipients = Bolt:get_staff()

  if !table.HasValue(Bolt:get_staff(), actor) then table.insert(recipients, actor) end

  Chatbox.add_text(recipients, unpack(msg_table))
end
