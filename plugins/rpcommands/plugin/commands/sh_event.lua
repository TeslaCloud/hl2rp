CMD.name = 'Event'
CMD.description = 'command.event.description'
CMD.syntax = 'command.event.syntax'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.roleplay'
CMD.arguments = 1

function CMD:on_run(player, ...)
  local text = table.concat({ ... }, ' ')

  Chatbox.add_text(nil, Color('orange'):lighten(30), text)

  Log:print(text, 'event')
end
