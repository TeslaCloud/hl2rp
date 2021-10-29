Prefixes:add('ooc', {
  prefix = { '//', '/ooc' },
  callback = function(player, text, team_chat)
    if (hook.run('PlayerCanUseOOC', player) == false) then
      player:notify('notification.mute', { time = math.round(player:get_player_data('ooc_mute') - CurTime()) })

      return
    end

    local msg_table = {
      hook.run('ChatboxGetPlayerIcon', player, text, team_chat) or {},
      Color('red'), '[OOC] ',
      hook.run('ChatboxGetPlayerColor', player, text, team_chat) or _team.GetColor(player:Team()),
      player:steam_name(),
      hook.run('ChatboxGetMessageColor', player, text, team_chat) or Color(255, 255, 255),
      ': ',
      text:chomp(' '),
      { sender = player }
    }

    Chatbox.add_text(nil, unpack(msg_table))
    Log:print(Chatbox.message_to_string(msg_table), 'player_ooc')
  end
})

Prefixes:add('looc', {
  prefix = { './/', '[[', '/looc' },
  callback = function(player, text, team_chat)
    if (hook.run('PlayerCanUseOOC', player) == false) then
      player:notify('notification.mute', { time = math.round(player:get_player_data('ooc_mute') - CurTime()) })

      return
    end

    local msg_table = {
      hook.run('ChatboxGetPlayerIcon', player, text, team_chat) or {},
      Color('red'):lighten(100), '[LOOC] ',
      hook.run('ChatboxGetPlayerColor', player, text, team_chat) or _team.GetColor(player:Team()),
      player:Nick(),
      ': ',
      Color('white'),
      text:chomp(' '),
      {
        sender = player,
        position = player:GetPos(),
        radius = Config.get('talk_radius'),
        ic = true
      }
    }

    if (_team.GetName(player:Team()) == 'faction.combine.overwatch.title') then
      msg_table[5] = 'Overwatch Soldier'
    end

    Chatbox.add_text(nil, unpack(msg_table))
    Log:print(Chatbox.message_to_string(msg_table), 'player_ooc')
  end
})
