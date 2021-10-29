CMD.name = 'SetArmor'
CMD.description = 'command.setarmor.description'
CMD.syntax = 'command.setarmor.syntax'
CMD.permission = 'moderator'
CMD.category = 'permission.categories.player_management'
CMD.arguments = 2
CMD.immunity = true
CMD.aliases = { 'plysetarmor', 'armor' }

function CMD:on_run(player, targets, ...)
  local value = tonumber(table.concat({ ... }, ' '))
  if value <= 0 then
    player:notify('error.setarmor.invalid_value', { armor = value })
    return
  end

  for k, v in ipairs(targets) do
    v:SetArmor(value)
    v:notify('command.setarmor.notification', { armor = value })
  end

  self:notify_staff('command.setarmor.message', {
    player = get_player_name(player),
    target = util.player_list_to_string(targets),
    armor = value
  })
end
