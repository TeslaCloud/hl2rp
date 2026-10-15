--- The `sethealth` staff command: `/sethealth <player> <value>` sets the health of the
-- targeted players to a positive value.

CMD.name = 'SetHealth'
CMD.description = 'command.sethealth.description'
CMD.syntax = 'command.sethealth.syntax'
CMD.category = 'permission.categories.player_management'
CMD.arguments = 2
CMD.arg_types = { 'player', 'number' }
CMD.immunity = true
CMD.aliases = { 'plysethealth', 'hp' }

--- Sets the health of the target players to a positive value and notifies them and the staff.
-- @param actor [Player player running the command]
-- @param targets [List<Player> players to set the health of]
-- @param text [String the new health, parsed with tonumber]
function CMD:on_run(actor, targets, text)
  local value = tonumber(text)

  if !value or value != value or value <= 0 then
    Flux.Player:notify(actor, 'error.sethealth.invalid_value', { health = text })

    return
  end

  for _, v in ipairs(targets) do
    v:SetHealth(value)
    v:notify('command.sethealth.notification', { health = value })
  end

  self:notify_staff('command.sethealth.message', {
    player = get_player_name(actor),
    target = util.player_list_to_string(targets),
    health = value
  })
end
