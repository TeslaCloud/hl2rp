CMD.name = 'SetHealth'
CMD.description = 'command.sethealth.description'
CMD.syntax = 'command.sethealth.syntax'
CMD.permission = 'moderator'
CMD.category = 'permission.categories.player_management'
CMD.arguments = 2
CMD.immunity = true
CMD.aliases = { 'plysethealth', 'hp' }

function CMD:on_run(player, targets, ...)
  local value = tonumber(table.concat({ ... }, ' '))
  if value <= 0 then
    player:notify('error.sethealth.invalid_value', { health = value })
    return
  end

  for k, v in ipairs(targets) do
    v:SetHealth(value)
    v:notify('command.sethealth.notification', { health = value })
  end

  self:notify_staff('command.sethealth.message', {
    player = get_player_name(player),
    target = util.player_list_to_string(targets),
    health = value
  })
end
