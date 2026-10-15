--- The `setarmor` staff command: `/setarmor <player> <value>` sets the armor of the
-- targeted players to a positive value.

CMD.name = 'SetArmor'
CMD.description = 'command.setarmor.description'
CMD.syntax = 'command.setarmor.syntax'
CMD.category = 'permission.categories.player_management'
CMD.arguments = 2
CMD.arg_types = { 'player', 'number' }
CMD.immunity = true
CMD.aliases = { 'plysetarmor', 'armor' }

--- Sets the armor of the target players to a positive value and notifies them and the staff.
-- @param actor [Player player running the command]
-- @param targets [List<Player> players to set the armor of]
-- @param text [String the new armor, parsed with tonumber]
function CMD:on_run(actor, targets, text)
  local value = tonumber(text)

  if !value or value != value or value <= 0 then
    Flux.Player:notify(actor, 'error.setarmor.invalid_value', { armor = text })

    return
  end

  for _, v in ipairs(targets) do
    v:SetArmor(value)
    v:notify('command.setarmor.notification', { armor = value })
  end

  self:notify_staff('command.setarmor.message', {
    player = get_player_name(actor),
    target = util.player_list_to_string(targets),
    armor = value
  })
end
