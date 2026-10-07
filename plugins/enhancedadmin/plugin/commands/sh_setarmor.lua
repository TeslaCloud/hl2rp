CMD.name = 'SetArmor'
CMD.description = 'command.setarmor.description'
CMD.syntax = 'command.setarmor.syntax'
CMD.permission = 'moderator'
CMD.category = 'permission.categories.player_management'
CMD.arguments = 2
CMD.immunity = true
CMD.aliases = { 'plysetarmor', 'armor' }

--- Sets the armor of the target players to a positive value and notifies them and the staff.
-- @param actor [Player player running the command]
-- @param targets [List<Player> players to set the armor of]
function CMD:on_run(actor, targets, ...)
  local value = tonumber(table.concat({ ... }, ' '))

  if value <= 0 then
    actor:notify('error.setarmor.invalid_value', { armor = value })
    return
  end

  for k, v in ipairs(targets) do
    v:SetArmor(value)
    v:notify('command.setarmor.notification', { armor = value })
  end

  self:notify_staff('command.setarmor.message', {
    player = get_player_name(actor),
    target = util.player_list_to_string(targets),
    armor = value
  })
end
