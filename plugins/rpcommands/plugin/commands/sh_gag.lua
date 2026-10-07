CMD.name = 'Gag'
CMD.description = 'command.gag.description'
CMD.syntax = 'command.gag.syntax'
CMD.permission = 'assistant'
CMD.category = 'permission.categories.administration'
CMD.arguments = 2
CMD.immunity = true
CMD.aliases = { 'muteooc', 'oocmute', 'plygag' }

function CMD:on_run(actor, targets, duration, ...)
  local reason = table.concat({ ... }, ' ')
  duration = Bolt:interpret_ban_time(duration)

  if !reason or reason == '' then
    reason = 'ui.no_reason'
  end

  if !isnumber(duration) then
    actor:notify('error.invalid_time', {
      time = tostring(duration)
    })

    return
  end

  for k, v in ipairs(targets) do
    v:set_player_data('ooc_mute', CurTime() + duration)
    v:notify('notification.muted', { time = Flux.Lang:nice_time(duration) })
  end

  self:notify_staff('command.gag.message', {
    admin = get_player_name(actor),
    target = util.player_list_to_string(targets),
    time = Flux.Lang:nice_time(duration),
    reason = reason
  })
end
