CMD.name = 'Me'
CMD.description = 'command.me.description'
CMD.syntax = 'command.me.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = { 'e', 'action', 'perform' }
CMD.arguments = 1

--- Says the text as an emote.
-- @param actor [Player player running the command]
function CMD:on_run(actor, ...)
  local text = table.concat({ ... }, ' ')

  Chatbox.player_say(actor, '*'..text..'*')
end
