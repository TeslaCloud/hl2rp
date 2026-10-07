CMD.name = 'Whisper'
CMD.description = 'command.whisper.description'
CMD.syntax = 'command.whisper.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.alias = 'w'
CMD.arguments = 1

--- Says the text as a whisper.
-- @param actor [Player player running the command]
function CMD:on_run(actor, ...)
  local text = table.concat({ ... }, ' ')

  Chatbox.player_say(actor, '('..text..')')
end
