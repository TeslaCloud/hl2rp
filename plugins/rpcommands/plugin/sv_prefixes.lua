Prefixes:add('ooc', {
  prefix = { '//', '/ooc' },
  callback = function(actor, text, team_chat)
    if hook.Run('PlayerCanUseOOC', actor) == false then
      actor:notify('notification.mute', { time = math.round(actor:get_player_data('ooc_mute') - CurTime()) })

      return
    end

    local msg_table = {
      hook.Run('ChatboxGetPlayerIcon', actor, text, team_chat) or {},
      Color('red'), '[OOC] ',
      hook.Run('ChatboxGetPlayerColor', actor, text, team_chat) or team.GetColor(actor:Team()),
      actor:steam_name(),
      hook.Run('ChatboxGetMessageColor', actor, text, team_chat) or Color(255, 255, 255),
      ': ',
      text:chomp(' '),
      { sender = actor }
    }

    Chatbox.add_text(nil, unpack(msg_table))
    Log:print(Chatbox.message_to_string(msg_table), 'player_ooc')
  end
})

Prefixes:add('looc', {
  prefix = { './/', '[[', '/looc' },
  callback = function(actor, text, team_chat)
    if hook.Run('PlayerCanUseOOC', actor) == false then
      actor:notify('notification.mute', { time = math.round(actor:get_player_data('ooc_mute') - CurTime()) })

      return
    end

    local msg_table = {
      hook.Run('ChatboxGetPlayerIcon', actor, text, team_chat) or {},
      Color('red'):lighten(100), '[LOOC] ',
      hook.Run('ChatboxGetPlayerColor', actor, text, team_chat) or team.GetColor(actor:Team()),
      actor:Nick(),
      ': ',
      Color('white'),
      text:chomp(' '),
      {
        sender = actor,
        position = actor:GetPos(),
        radius = Config.get('talk_radius'),
        ic = true
      }
    }

    if team.GetName(actor:Team()) == 'faction.combine.overwatch.title' then
      msg_table[5] = 'Overwatch Soldier'
    end

    Chatbox.add_text(nil, unpack(msg_table))
    Log:print(Chatbox.message_to_string(msg_table), 'player_ooc')
  end
})
