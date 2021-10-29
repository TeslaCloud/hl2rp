local player_meta = FindMetaTable('Player')

function player_meta:play_animation(animation)
  if CLIENT then
    Cable.send('fl_animation_start', animation)
  end

  local animation_table = Animations:get(animation)

  if !animation_table then return end
  if self:get_nv('fl_animation') then return end

  local anim_duration = animation_table.duration
  local full_duration = 0
  local enter = animation_table.enter
  local anim = animation_table.anim
  local exit = animation_table.exit

  if SERVER then
    self:set_nv('fl_animation', animation)
    self:set_nv('fl_animation_angle', self:GetAngles())
    self:set_nv('fl_third_person', true)

    self:freeze_move()
    self:freeze_gun()
  end

  if enter then
    local sequence, duration = self:LookupSequence(enter)

    if sequence != -1 then
      self:set_animation(enter, 0)

      full_duration = duration
    end
  end

  if anim then
    local sequence, duration = self:LookupSequence(anim)

    if sequence != -1 then
      timer.simple(full_duration, function()
        if IsValid(self) then
          self:set_animation(anim, 0)
        end
      end)
    end
  end

  if anim_duration > 0 then
    timer.simple(full_duration + anim_duration, function()
      if IsValid(self) then
        self:leave_animation()
      end
    end)
  end
end

function player_meta:leave_animation()
  if self.leaving_animation then return end

  local animation_table = Animations:get(self:get_nv('fl_animation'))
  local exit = animation_table.exit
  local sequence, duration = self:LookupSequence(exit)

  self.leaving_animation = true

  if sequence != -1 then
    self:set_animation(exit)
  else
    duration = 0
  end

  timer.simple(duration, function()
    if IsValid(self) then
      self:stop_animation()
      self.leaving_animation = nil

      if SERVER then
        self:set_nv('fl_animation_angle', nil)
        self:set_nv('fl_animation', nil)
        self:set_nv('fl_third_person', false)

        self:unfreeze_move()
        self:unfreeze_gun()
      end
    end
  end)
end
