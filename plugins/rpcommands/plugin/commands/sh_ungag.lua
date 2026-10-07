CMD.name = 'Ungag'
CMD.description = 'command.ungag.description'
CMD.syntax = 'command.ungag.syntax'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.administration'
CMD.arguments = 1
CMD.immunity = true
CMD.aliases = { 'unmuteooc', 'oocunmute', 'plyungag' }

--- Lifts the OOC mute of the target players and notifies the staff.
-- @param actor [Player player running the command]
-- @param targets [List<Player> players to ungag]
function CMD:on_run(actor, targets)
  for k, v in ipairs(targets) do
    v:set_player_data('ooc_mute', nil)
    v:notify('notification.unmuted')
  end

  self:notify_staff('command.ungag.message', {
    player = get_player_name(actor),
    target = util.player_list_to_string(targets)
  })
end
