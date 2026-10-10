CMD.name = 'Report'
CMD.description = 'command.report.description'
CMD.syntax = 'command.report.syntax'
CMD.category = 'permission.categories.general'
CMD.arguments = 1
CMD.alias = 'help'

--- Sends a report message to all online staff and to the reporting player.
-- @param actor [Player player making the report]
function CMD:on_run(actor, ...)
  local text = table.concat({ ... }, ' ')

  local msg_table = {
    Color(184, 59, 94),
    '@report ',
    hook.Run('ChatboxGetPlayerColor', actor, text) or team.GetColor(actor:Team()),
    get_player_name(actor),
    hook.Run('ChatboxGetMessageColor', actor, text) or Color(255, 255, 255),
    ': ',
    text:chomp(' '),
    { sender = actor }
  }

  local recipients = Bolt:get_staff()

  if !table.HasValue(recipients, actor) then table.insert(recipients, actor) end

  Chatbox.add_text(recipients, unpack(msg_table))
end
