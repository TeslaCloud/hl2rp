CMD.name = 'Whisper'
CMD.description = 'command.whisper.description'
CMD.syntax = 'command.whisper.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.alias = 'w'
CMD.arguments = 1

function CMD:on_run(player, ...)
  local text = table.concat({...}, ' ')

  Chatbox.player_say(player, '('..text..')')
end
