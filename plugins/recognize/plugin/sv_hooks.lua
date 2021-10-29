Config.set('recog_must_see', true)

function Recognizes:PostCharacterLoaded(player, character)
  local recognizes = {}

  if character.recognizes then
    for k, v in pairs(character.recognizes) do
      recognizes[v.target_id] = v.name
    end
  end

  player:set_nv('fl_recognizes', recognizes)
end

function Recognizes:PlayerCanRecognize(player, target)
  if player == target then
    return false
  end

  if Config.get('recog_must_see') and util.vector_obstructed(player:EyePos(), target:EyePos(), { player, target }) then
    return false
  end
end

Cable.receive('fl_recognize', function(player, type, name, target)
  local targets = {}

  name = name or player:name(true)

  if type == 'target' then
    local target = target or player:GetEyeTraceNoCursor().Entity

    if IsValid(target) and target:EyePos():Distance(player:EyePos()) <= Config.get('talk_radius') * 4 then
      table.insert(targets, target)
    end
  else
    local ranges = {
      whisper = Config.get('talk_radius') * 0.25,
      talk = Config.get('talk_radius'),
      yell = Config.get('talk_radius') * 2
    }

    for k, v in ipairs(_player.all()) do
      if player:EyePos():Distance(v:EyePos()) <= ranges[type] then
        table.insert(targets, v)
      end
    end
  end

  for k, v in ipairs(targets) do
    if hook.run('PlayerCanRecognize', player, v) != false then
      local is_known, known_name = v:recognizes(player)

      if !v:knows_real_name(player) then
        if !is_known then
          v:notify('notification.recognize.new_name', { name = name }, Color('green'):lighten(100))
        else
          v:notify('notification.recognize.change_name', { name = known_name, new_name = name }, Color('salmon'))
        end
      end

      v:add_recognize(player, name)
    end
  end

  if name == player:name(true) then
    player:notify('notification.recognize.true_name', { name = name }, Color('green'):lighten(100))
  else
    player:notify('notification.recognize.false_name', { name = name }, Color('salmon'))
  end
end)
