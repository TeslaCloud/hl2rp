CMD.name = 'Its'
CMD.description = 'command.its.description'
CMD.syntax = 'command.its.syntax'
CMD.category = 'permission.categories.roleplay'
CMD.aliases = { 'action', 'itstatic', 'describe' }
CMD.arguments = 1

function CMD:on_run(player, ...)
  local cur_time = CurTime()

  if player.next_its and player.next_its >= cur_time then
    player:notify('error.wait')

    return
  end

  local pos = player:GetPos()
  local text = table.concat({ ... }, ' '):chomp(' '):spelling()

  for k, v in pairs(RPCommands.texts) do
    if v.pos:Distance(pos) <= 50 then
      player:notify('error.its_too_close')

      return
    end
  end

  local data = {
    pos = pos + Vector(0, 0, 30),
    text = text,
    name = player:Name(true),
    steamid = player:SteamID(),
    time = to_datetime(os.time())
  }

  RPCommands.add_static_text(data)

  player.next_its = cur_time + 5
  player:notify('notification.static_text.added')

  Log:print(player:Name(true)..' ('..player:SteamID()..') added static text: '..text..'; pos: '..tostring(pos), 'player_action')
end
