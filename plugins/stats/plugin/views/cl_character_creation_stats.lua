local PANEL = {}
PANEL.id = 'stats'
PANEL.text = 'ui.char_create.stats'
PANEL.stats = {}

function PANEL:Init()
  self.start_points = Stats:default_attribute_points()
  self.points = self.points or self.start_points

  self:DockPadding(0, math.scale(48), 0, 0)
end

function PANEL:PaintOver(w, h)
  local text = t'ui.char_create.stats_points'..self.points
  local text_w, text_h = util.text_size(text, Theme.get_font('text_normal_large'))
  surface.DisableClipping(true)
    draw.SimpleText(text, Theme.get_font('text_normal_large'), w - text_w, h - text_h, Theme.get_color('schema_text'))
  surface.DisableClipping(false)
end

function PANEL:on_open(parent)
  local scrw, scrh = ScrW(), ScrH()
  local fa_icon_size = math.scale(16)
  local selected_attribute
  local stat_translate = {
    'superb',
    'great',
    'good',
    'fair',
    'mediocre',
    'poor',
    'terrible'
  }

  self.attributes_list = vgui.Create('DScrollPanel', self)
  self.attributes_list:SetSize(scrw * 0.15 - math.scale_x(4))
  self.attributes_list:DockMargin(0, 0, 0, math.scale(48))
  self.attributes_list:Dock(LEFT)
  self.attributes_list:GetCanvas():DockPadding(math.scale_x(4), math.scale(4), math.scale_x(4), math.scale(4))
  self.attributes_list.Paint = function(pnl, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
  end

  self.attribute_panel = vgui.Create('DScrollPanel', self)
  self.attribute_panel:SetSize(scrw * 0.35 - math.scale_x(4))
  self.attribute_panel:DockMargin(0, 0, 0, math.scale(48))
  self.attribute_panel:Dock(RIGHT)
  self.attribute_panel:GetCanvas():DockPadding(math.scale_x(48), math.scale(32), math.scale_x(48), math.scale(32))
  self.attribute_panel.Paint = function(pnl, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
  end

  self.attribute_panel.rebuild = function(pnl)
    if !selected_attribute then return end

    chat.PlaySound()
    
    pnl:Clear()

    local panel = vgui.create('DPanel', pnl)
    panel:SetDrawBackground(false)
    panel:Dock(TOP)

    local icon

    if selected_attribute.icon then
      local size = math.scale(48)

      icon = vgui.create('DImage', panel)
      icon:SetImage(selected_attribute.icon)
      icon:SetKeepAspect(true)
      icon:SetSize(size, size)
    end 

    local title = vgui.create('DLabel', panel)
    title:SetText(t(selected_attribute.name))
    title:SetFont(Font.size(Theme.get_font('text_bold'), math.scale(48)))
    title:SetColor(color_white)
    title:SetContentAlignment(9)
    title:SetPos(icon and icon:GetWide() + math.scale_x(16) or 0)
    title:SizeToContents()

    panel:SetTall(math.max(title:GetTall(), icon and icon:GetTall() or 0) + math.scale(16))

    local desc = vgui.create('DLabel', pnl)
    desc:SetText(t(selected_attribute.description))
    desc:SetFont(Theme.get_font('text_normal'))
    desc:SetColor(color_white)
    desc:SetWrap(true)
    desc:SetMultiline(true)
    desc:SetAutoStretchVertical(true)
    desc:Dock(TOP)

    local raw_value = self.stats[selected_attribute.attribute_id].counter:get_value()
    local value = 4 - raw_value
    local level = stat_translate[value]

    panel = vgui.create('DPanel', pnl)
    panel:SetDrawBackground(false)
    panel:Dock(TOP)

    local current_level = vgui.create('DLabel', panel)
    current_level:SetText(t('ui.char_create.cur_level')..': ')
    current_level:SetFont(Font.size(Theme.get_font('text_bold'), math.scale(32)))
    current_level:SetColor(color_white)
    current_level:SetContentAlignment(1)
    current_level:SizeToContents()

    local level_name = vgui.create('DLabel', panel)
    level_name:SetText(t('attribute.level.'..level))
    level_name:SetFont(Theme.get_font('text_normal_large'))
    level_name:SetColor(color_white)
    level_name:SetContentAlignment(2)
    level_name:SizeToContents()

    panel:SetTall(current_level:GetTall() + math.scale(32))
    current_level:SetPos(0, panel:GetTall() - current_level:GetTall() - math.scale(1))
    level_name:SetPos(current_level:GetWide(), panel:GetTall() - level_name:GetTall())

    local level_desc = vgui.create('DLabel', pnl)
    level_desc:SetText(t(selected_attribute.levels[level]))
    level_desc:SetFont(Theme.get_font('text_normal'))
    level_desc:SetColor(color_white)
    level_desc:SetWrap(true)
    level_desc:SetMultiline(true)
    level_desc:SetAutoStretchVertical(true)
    level_desc:Dock(TOP)

    local effects = selected_attribute.effects

    if selected_attribute.effects then
      local effect_title = vgui.create('DLabel', pnl)
      effect_title:SetText(t('ui.char_create.effects'))
      effect_title:SetFont(Font.size(Theme.get_font('text_bold'), math.scale(32)))
      effect_title:SetColor(color_white)
      effect_title:SetContentAlignment(1)
      effect_title:SizeToContents()
      effect_title:Dock(TOP)
      effect_title:SetTall(effect_title:GetTall() + math.scale(32))

      for k, v in pairs(effects) do
        local effect = vgui.create('DLabel', pnl)
        effect:SetText(t(v.text)..' '..t(v.get_value(raw_value)))
        effect:SetFont(Theme.get_font('text_normal'))
        effect:SetColor(v.get_color(raw_value))
        effect:SizeToContents()
        effect:Dock(TOP)
      end
    end
  end

  for k, v in pairs(Attributes.get_by_type(ATTRIBUTE_STAT)) do
    local stat_line = vgui.create('DPanel', self.attributes_list)
    stat_line:SetTall(math.scale(64))
    stat_line:Dock(TOP)
    stat_line:DockMargin(0, 0, 0, math.scale(4))
    stat_line.attribute_table = v
    stat_line.Paint = function(pnl, w, h)
      if selected_attribute and selected_attribute.attribute_id == pnl.attribute_table.attribute_id then
        draw.box_outlined(0, 0, 0, w, h, 2, Theme.get_color('accent'), 0)
      end
    end

    stat_line.OnMousePressed = function(pnl)
      if selected_attribute != v then
        selected_attribute = v

        self.attribute_panel:rebuild()
      end
    end

    local counter = vgui.create('fl_counter', stat_line)
    counter:Dock(RIGHT)
    counter:set_value(v.default)
    counter:set_min_max(v.min, v.max)
    counter:set_font(Theme.get_font('main_menu_titles'))
    counter.on_click = function(btn, new_value, old_value)
      local diff = new_value - old_value

      if selected_attribute != v then
        selected_attribute = v
      end

      if self.points - diff < 0 then
        return false
      else
        surface.PlaySound('buttons/blip1.wav')

        self.points = self.points - diff
      end
    end

    counter.post_click = function(pnl)
      self.attribute_panel:rebuild()
    end

    local icon

    if v.icon then
      local size = stat_line:GetTall() * 0.75

      icon = vgui.create('DImage', stat_line)
      icon:SetImage(v.icon)
      icon:SetSize(size, size)
      icon:SetPos(math.scale_x(4), stat_line:GetTall() * 0.5 - size * 0.5)
    end

    local title = vgui.create('DLabel', stat_line)
    title:SetText(t(v.name))
    title:SetFont(Theme.get_font('main_menu_titles'))
    title:SetColor(color_white)
    title:SetPos(icon and icon:GetWide() + math.scale_x(24) or 0, stat_line:GetTall() * 0.5 - title:GetTall() * 0.5)
    title:SizeToContents()

    stat_line.level_info = level_info
    stat_line.counter = counter
    self.stats[k] = stat_line
  end

  self.random = vgui.Create('fl_button', self)
  self.random:SetSize(self.attributes_list:GetWide(), Theme.get_option('menu_sidebar_button_height'))
  self.random:SetPos(math.scale_x(8), scrh * 0.5 - self.random:GetTall())
  self.random:set_icon('fa-random')
  self.random:set_icon_size(fa_icon_size)
  self.random:SetFont(Theme.get_font('text_normal'))
  self.random:SetTitle(t'ui.char_create.stats_random')
  self.random:SetDrawBackground(false)
  self.random.DoClick = function(btn)
    local cur_time = CurTime()

    if !self.random.next_click or self.random.next_click <= cur_time then
      for k, v in pairs(self.stats) do
        local number = v.counter:get_value()

        if number > v.attribute_table.min then
          self.points = self.points + (number - v.attribute_table.min)
          v.counter:set_value(v.attribute_table.min)
        end
      end

      while self.points > 0 do
        local stat = table.random(self.stats)
        local number = stat.counter:get_value()

        if number < stat.attribute_table.max then
          number = number + 1
          stat.counter:set_value(number)

          self.points = self.points - 1
        end
      end

      surface.PlaySound('buttons/button4.wav')
      self.attribute_panel:rebuild()
      self.random.next_click = cur_time + 1
    end
  end

  local pool = parent.char_data.attribute_pool

  if pool then
    self.points = pool
  end

  if parent.char_data.attributes then
    for k, v in pairs(parent.char_data.attributes) do
      self.stats[k].counter:set_value(v)
    end
  end
end

function PANEL:on_close(parent)
  local stats_table = {}

  for k, v in pairs(self.stats) do
    stats_table[k] = v.counter:get_value()
  end

  parent:collect_data({
    attributes = stats_table,
    attribute_pool = self.points
  })
end

function PANEL:on_validate()
  local sum = 0

  for k, v in pairs(self.stats) do
    sum = sum + v.counter:get_value()
  end

  if self.points < 0 or sum > self.start_points then
    return false, t'ui.char_create.invalid_points'
  end

  if self.points > 0 then
    return false, t'ui.char_create.excess_points'
  end
end

vgui.Register('fl_character_creation_stats', PANEL, 'fl_character_creation_base')
