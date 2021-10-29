do
  local player_meta = FindMetaTable('Player')

  function player_meta:recognizes(target)
    if !IsValid(target) or self == target or !self:get_character() or target:IsBot() or
    self:GetMoveType() == MOVETYPE_NOCLIP then
      return true, target:name(true)
    end

    local recognizes_override, name_override = hook.run('PlayerRecognizeTarget', player, target)

    if recognizes_override then
      return true, name_override or target:name(true)
    end

    local recognizes = self:get_nv('fl_recognizes', {})
    local char_id = target:get_character_id()
    local known_name = recognizes[char_id]

    if known_name then
      return true, known_name
    end

    return false
  end

  function player_meta:knows_real_name(target)
    local is_known, known_name = self:recognizes(target)

    return (is_known and known_name == target:name(true))
  end

  if SERVER then
    function player_meta:add_recognize(target, name)
      if !IsValid(target) or self:IsBot() then return end

      local char_id = target:get_character_id()

      if !char_id or self == target then return end

      local is_known, known_name = self:recognizes(target)
      local real_name = target:name(true)

      if is_known and known_name == real_name then return end

      name = name or real_name

      if is_known then
        for k, v in pairs(self:get_character().recognizes) do
          if v.target_id == char_id then
            v.name = name

            break
          end
        end
      else
        local recognize = Recognize.new()
          recognize.target_id = char_id
          recognize.name = name
        table.insert(self:get_character().recognizes, recognize)
      end

      local recognizes = self:get_nv('fl_recognizes', {})
        recognizes[char_id] = name
      self:set_nv('fl_recognizes', recognizes)
    end

    function player_meta:remove_recognize(target)
      if !IsValid(target) then return end

      local char_id = target:get_character_id()

      if !char_id or self == target then return end

      local is_known, known_name = self:recognizes(target)

      if !is_known then return end

      for k, v in pairs(self:get_character().recognizes) do
        if v.target_id == char_id then
          v:destroy()

          break
        end
      end

      local recognizes = self:get_nv('fl_recognizes', {})
        recognizes[char_id] = nil
      self:set_nv('fl_recognizes', recognizes)
    end
  end
end
