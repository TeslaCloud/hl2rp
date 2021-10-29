CMD.name = 'Ungag'
CMD.description = 'command.ungag.description'
CMD.syntax = 'command.ungag.syntax'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.administration'
CMD.arguments = 1
CMD.immunity = true
CMD.aliases = { 'unmuteooc', 'oocunmute', 'plyungag' }

function CMD:on_run(player, targets)
  for k, v in ipairs(targets) do
    v:set_player_data('ooc_mute', nil)
    v:notify('notification.unmuted')
  end

  self:notify_staff('command.ungag.message', {
    player = get_player_name(player),
    target = util.PlayerListToString(targets)
  })
end
