CMD.name = 'Itsremove'
CMD.description = 'command.itsremove.description'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = {
  'removedescribe',
  'describeremove',
  'actionremove',
  'removeaction',
  'itstaticremove',
  'removeits',
  'removeitstatic'
}

--- Removes the static text the player is looking at if they placed it or are staff.
-- @param actor [Player player running the command]
function CMD:on_run(actor)
  local trace = actor:GetEyeTraceNoCursor()

  for k, v in pairs(RPCommands.texts) do
    if trace.Hit and trace.HitPos:Distance(v.pos) <= 50 and (v.steamid == actor:SteamID() or actor:is_assistant()) then
      RPCommands.remove_static_text(k)
      actor:notify('notification.static_text.removed')

      Log:print(
        actor:Name(true)..' ('..actor:SteamID()..') removed static text: '..text..'; pos: '..tostring(pos),
        'player_action'
      )

      return
    end
  end

  actor:notify('notification.static_text.not_found')
end
