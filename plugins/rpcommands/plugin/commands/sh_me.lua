CMD.name = 'Me'
CMD.description = 'command.me.description'
CMD.syntax = 'command.me.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = { 'e', 'action', 'perform' }
CMD.arguments = 1

function CMD:on_run(player, ...)
  local text = table.concat({...}, ' ')

  Chatbox.player_say(player, '*'..text..'*')
end
