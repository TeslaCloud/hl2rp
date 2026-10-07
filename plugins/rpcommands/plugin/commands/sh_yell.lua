CMD.name = 'Yell'
CMD.description = 'command.yell.description'
CMD.syntax = 'command.yell.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = { 'y', 'shout', 's' }
CMD.arguments = 1

function CMD:on_run(actor, ...)
  local text = table.concat({...}, ' ')

  Chatbox.player_say(actor, text..'!!')
end
