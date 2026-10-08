Config.set('recog_must_see', true)

--- Networks the names a character recognizes others by once it is loaded.
-- @param owner [Player player the character belongs to]
-- @param character [Character loaded character]
function Recognizes:PostCharacterLoaded(owner, character)
  local recognizes = {}

  if character.recognizes then
    for k, v in pairs(character.recognizes) do
      recognizes[v.target_id] = v.name
    end
  end

  owner:set_nv('fl_recognizes', recognizes)
end

--- Prevents players from recognizing themselves or, if recog_must_see is set, players they cannot see.
-- @param actor [Player player introducing themselves]
-- @param target [Player player that would recognize them]
-- @return [Boolean false to prevent recognizing, nil otherwise]
function Recognizes:PlayerCanRecognize(actor, target)
  if actor == target then
    return false
  end

  if Config.get('recog_must_see') and util.vector_obstructed(actor:EyePos(), target:EyePos(), { actor, target }) then
    return false
  end
end

Cable.receive('fl_recognize', function(actor, type, name, target)
  local targets = {}

  name = name or actor:name(true)

  if type == 'target' then
    local target = target or actor:GetEyeTraceNoCursor().Entity

    if IsValid(target) and target:EyePos():Distance(actor:EyePos()) <= Config.get('talk_radius') * 4 then
      table.insert(targets, target)
    end
  else
    local ranges = {
      whisper = Config.get('talk_radius') * 0.25,
      talk = Config.get('talk_radius'),
      yell = Config.get('talk_radius') * 2
    }

    for k, v in player.Iterator() do
      if actor:EyePos():Distance(v:EyePos()) <= ranges[type] then
        table.insert(targets, v)
      end
    end
  end

  for k, v in ipairs(targets) do
    if hook.Run('PlayerCanRecognize', actor, v) != false then
      local is_known, known_name = v:recognizes(actor)

      if !v:knows_real_name(actor) then
        if !is_known then
          v:notify('notification.recognize.new_name', { name = name }, Color('green'):lighten(100))
        else
          v:notify('notification.recognize.change_name', { name = known_name, new_name = name }, Color('salmon'))
        end
      end

      v:add_recognize(actor, name)
    end
  end

  if name == actor:name(true) then
    actor:notify('notification.recognize.true_name', { name = name }, Color('green'):lighten(100))
  else
    actor:notify('notification.recognize.false_name', { name = name }, Color('salmon'))
  end
end)
