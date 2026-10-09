--- Server side of the RolePlay Commands plugin: the rules of who may speak in character and
-- out of character (the OOC mute, the OOC and LOOC cooldowns and the speaking veto), and the
-- OOC and LOOC chat lines that the chat prefixes send.

local cooldowns = {
  ooc = {
    config = 'ooc_interval',
    field = 'last_ooc_at',
    phrase = 'notification.cooldown.ooc'
  },
  looc = {
    config = 'looc_interval',
    field = 'last_looc_at',
    phrase = 'notification.cooldown.looc'
  }
}

--- Returns how long the OOC mute of a player still lasts. The end of a mute is kept in the
-- player data as a real time (`os.time`), so it carries over restarts and map changes.
-- @param target [Player]
-- @return [Number seconds left, 0 if the player is not muted]
function RPCommands:get_ooc_mute_left(target)
  local muted_until = tonumber(target:get_player_data('ooc_mute')) or 0

  return math.max(0, math.ceil(muted_until - os.time()))
end

--- Mutes a player in the OOC and LOOC chats, or lifts their mute.
-- @param target [Player]
-- @param duration=nil [Number seconds the mute lasts from now; nil or 0 lifts the mute]
function RPCommands:set_ooc_mute(target, duration)
  duration = tonumber(duration) or 0

  if duration > 0 then
    target:set_player_data('ooc_mute', os.time() + duration)
  else
    target:set_player_data('ooc_mute', nil)
  end
end

--- Checks the cooldown of the OOC or LOOC chat for a player and starts the next one if they
-- may write. The cooldown is the 'ooc_interval' or the 'looc_interval' config; players with
-- the 'bypass_chat_cooldown' permission have none. A player who has to wait is told for how
-- long.
-- @param actor [Player]
-- @param kind [String 'ooc' or 'looc']
-- @return [Boolean false if the player has to wait]
function RPCommands:check_ooc_cooldown(actor, kind)
  local cooldown = cooldowns[kind]

  if !cooldown then return true end

  local interval = tonumber(Config.get(cooldown.config)) or 0

  if interval <= 0 or actor:can('bypass_chat_cooldown') then return true end

  local cur_time = CurTime()
  local last_used = actor[cooldown.field]
  local time_left = last_used and (last_used + interval - cur_time) or 0

  if time_left > 0 then
    actor:notify(cooldown.phrase, { time = math.ceil(time_left) })

    return false
  end

  actor[cooldown.field] = cur_time

  return true
end

--- Checks whether a player may send a message to the OOC or LOOC chat right now: asks the
-- PlayerCanUseOOC hook, then checks the cooldown. A muted player is told how long their mute
-- still lasts.
-- @param actor [Player]
-- @param kind [String 'ooc' or 'looc']
-- @param text [String the message]
-- @return [Boolean]
function RPCommands:can_use_ooc(actor, kind, text)
  --- Decides whether a player may use the out of character chats. Called on the server
  -- before a message is sent to the OOC or the LOOC chat, ahead of the cooldown check. The
  -- plugin's own handler refuses players with an OOC mute, who are told how long it still
  -- lasts; any other handler that refuses should tell the player why.
  -- @param actor [Player the player who writes]
  -- @param kind [String 'ooc' for the chat that everyone reads, 'looc' for the local one]
  -- @param text [String the message without its prefix]
  -- @return [Boolean return false to refuse the message]
  if hook.Run('PlayerCanUseOOC', actor, kind, text) == false then
    local time_left = self:get_ooc_mute_left(actor)

    if time_left > 0 then
      actor:notify('notification.mute', { time = time_left })
    end

    return false
  end

  return self:check_ooc_cooldown(actor, kind)
end

--- Checks whether a player may say a phrase in character: speech, whispers, yells and
-- actions alike. The PlayerCanSayIC hook decides; when no handler does, players who are dead
-- or knocked out are refused and told so, while players who have merely fallen over may speak.
-- @param actor [Player]
-- @param text [String the phrase, with its markup]
-- @return [Boolean]
function RPCommands:can_say_ic(actor, text)
  --- Decides whether a player may say something in character. Called on the server for
  -- every phrase that is about to become in character speech or an action, which includes
  -- the `me`, `whisper` and `yell` commands; out of character chat does not ask it.
  -- @param actor [Player the speaker]
  -- @param text [String the phrase as it was typed, with its markup: `*action*`, `(whisper)`
  --   and `yell!!`]
  -- @return [Boolean return false to refuse the phrase (the handler should tell the player
  --   why), true to allow it even for a dead or knocked out player. When nothing is
  --   returned, players who are dead or knocked out are refused]
  local allowed = hook.Run('PlayerCanSayIC', actor, text)

  if allowed != nil then
    return allowed != false
  end

  if !actor:Alive() then
    actor:notify('error.speak.dead')

    return false
  end

  if isfunction(actor.is_knocked_out) and actor:is_knocked_out() then
    actor:notify('error.speak.knocked_out')

    return false
  end

  return true
end

--- Checks whether a phrase has anything to say once its markup is taken away, so that an
-- empty whisper or a lone asterisk does not become an empty chat line.
-- @param text [String the phrase]
-- @return [Boolean]
function RPCommands:has_phrase_content(text)
  local phrase, volume = self:get_phrase_volume(text)

  if volume > 0 and phrase:start_with('*') then
    phrase = phrase:gsub('!+$', '')
  end

  return phrase:find('[^%s%*]') != nil
end

--- Sends a message to the OOC chat, which every player reads. The line shows the Steam name
-- of the player, with their Steam avatar if the 'ooc_avatars' config is enabled. An invalid
-- player stands for the server console, whose messages are neither muted nor held back.
-- @param actor [Player the player who writes, an invalid entity for the server console]
-- @param text [String the message]
-- @param team_chat=nil [Boolean whether the message was sent to the team chat]
function RPCommands:say_ooc(actor, text, team_chat)
  if !isstring(text) then return end

  text = text:chomp(' ')

  if text == '' then return end

  local msg_table

  if IsValid(actor) then
    if !actor:IsPlayer() or !self:can_use_ooc(actor, 'ooc', text) then return end

    msg_table = {
      hook.Run('ChatboxGetPlayerIcon', actor, text, team_chat) or {},
      Config.get('ooc_avatars') and Chatbox.avatar(actor) or {},
      Color('red'), '[OOC] ',
      hook.Run('ChatboxGetPlayerColor', actor, text, team_chat) or team.GetColor(actor:Team()),
      actor:steam_name(),
      hook.Run('ChatboxGetMessageColor', actor, text, team_chat) or Color(255, 255, 255),
      ': ',
      text,
      { sender = actor }
    }
  else
    msg_table = {
      Color('red'), '[OOC] ',
      Color(255, 90, 90),
      get_player_name(actor),
      Color(255, 255, 255),
      ': ',
      text
    }
  end

  Chatbox.add_text(nil, unpack(msg_table))
  Log:print(Chatbox.message_to_string(msg_table), 'player_ooc')
end

--- Sends a message to the LOOC chat, which is read by the players within the talk radius.
-- The line never shows a Steam avatar: it is tied to a character that the readers can see,
-- and the avatar would tell them who plays it.
-- @param actor [Player the player who writes]
-- @param text [String the message]
-- @param team_chat=nil [Boolean whether the message was sent to the team chat]
function RPCommands:say_looc(actor, text, team_chat)
  if !IsValid(actor) or !actor:IsPlayer() or !isstring(text) then return end

  text = text:chomp(' ')

  if text == '' or !self:can_use_ooc(actor, 'looc', text) then return end

  local msg_table = {
    hook.Run('ChatboxGetPlayerIcon', actor, text, team_chat) or {},
    Color('red'):lighten(100), '[LOOC] ',
    hook.Run('ChatboxGetPlayerColor', actor, text, team_chat) or team.GetColor(actor:Team()),
    actor:Nick(),
    ': ',
    Color('white'),
    text,
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
