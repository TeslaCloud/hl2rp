CMD.name = 'Itsremove'
CMD.description = 'command.itsremove.description'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = { 'removedescribe', 'describeremove', 'actionremove', 'removeaction', 'itstaticremove', 'removeits', 'removeitstatic' }

function CMD:on_run(player)
  local trace = player:GetEyeTraceNoCursor()

  for k, v in pairs(RPCommands.texts) do
    if trace.Hit and trace.HitPos:Distance(v.pos) <= 50 and (v.steamid == player:SteamID() or player:is_assistant()) then
      RPCommands.remove_static_text(k)
      player:notify('notification.static_text.removed')

      Log:print(player:Name(true)..' ('..player:SteamID()..') removed static text: '..text..'; pos: '..tostring(pos), 'player_action')

      return
    end
  end

  player:notify('notification.static_text.not_found')
end
