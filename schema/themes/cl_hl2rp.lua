THEME.author = 'TeslaCloud Studios'
THEME.id = 'hl2rp'
THEME.parent = 'factory'

function THEME:on_loaded()
  local scrw, scrh = ScrW(), ScrH()
  local accent_color = Color(58, 87, 167)

  self:set_color('accent', accent_color)
  self:set_color('accent_dark', accent_color:darken(20))
  self:set_color('accent_light', accent_color:lighten(20))
  self:set_color('menu_background', Color(0, 0, 0, 100))

  self:set_option('menu_sidebar_width', scrw / 4)
  self:set_option('menu_sidebar_x', scrw * 0.5)
  self:set_option('menu_sidebar_y', scrh * 0.25 * 3)
  self:set_option('menu_sidebar_logo_space', 0)
  self:set_option('menu_sidebar_height', scrh * 0.25)
  self:set_option('menu_sidebar_button_centered', true)
  self:set_option('menu_sidebar_button_offset_x', 0)
  self:set_option('bar_height', 7)

  self:set_sound('menu_music', 'sound/teslacloud/triage_at_dawn.mp3')
  self:set_sound('button_click_success_sound', 'garrysmod/ui_click.wav')
  self:set_sound('button_click_danger_sound', 'buttons/button8.wav')

  self:set_material('schema_logo', 'materials/flux/hl2rp/logo.png')

  self:set_font('text_bar', self:get_font('main_font'), math.max(math.scale(14), 14), { weight = 600 })
end

function THEME:ChatboxPaintBackground(panel, width, height)
  DisableClipping(true)
    draw.box(0, -8, width, height - panel.text_entry:GetTall(), self:get_color('menu_background'))
  DisableClipping(false)
end

function THEME:PaintMainMenu(panel, width, height)
  local title, desc, author = SCHEMA:get_name()..' '..(SCHEMA.version or 'UNKNOWN'), SCHEMA:get_description(), t('ui.main_menu.developed_by', { author = SCHEMA:get_author() })
  local version = 'Flux '..(GAMEMODE.version or 'UNKNOWN')
  local logo = self:get_material('schema_logo')
  local title_w, title_h = util.text_size(title, self:get_font('main_menu_titles'))
  local desc_w, desc_h = util.text_size(desc, self:get_font('main_menu_titles'))
  local author_w, author_h = util.text_size(author, self:get_font('main_menu_titles'))
  local version_w, version_h = util.text_size(version, self:get_font('main_menu_titles'))
  local logo_offset = math.scale(panel.schema_logo_offset or 450)

  draw.blur_box(0, 0, width, height)

  surface.SetDrawColor(self:get_color('menu_background'):lighten(40))
  surface.DrawRect(0, logo_offset, width, height / 8)

  if logo then
    draw.textured_rect(logo, width * 0.5 - math.scale(200), logo_offset + 16, math.scale(400), math.scale(96), Color(255, 255, 255))
  end

  draw.SimpleText(desc, self:get_font('main_menu_titles'), 16, logo_offset + 128 - desc_h - 8, self:get_color('schema_text'))
  draw.SimpleText(author, self:get_font('main_menu_titles'), width - author_w - 16, logo_offset + 128 - author_h - 8, self:get_color('schema_text'))
  draw.SimpleText(title, self:get_font('main_menu_titles'), width - title_w - 8, logo_offset + height - title_h - 8, self:get_color('schema_text'))
  draw.SimpleText(version, self:get_font('main_menu_titles'), 8, logo_offset + height - version_h - 8, self:get_color('schema_text'))
end

function THEME:PaintCharPanel(panel, w, h)
  if panel.char_data then
    local char_data = panel.char_data
    local name_w, name_h = util.text_size(char_data.name, self:get_font('main_menu_titles'))

    draw.SimpleText(char_data.name, self:get_font('main_menu_titles'), w * 0.5 - name_w * 0.5, 4, self:get_color('schema_text'))

    if PLAYER:get_character_id() == char_data.id then
      surface.SetDrawColor(self:get_color('accent'))
      surface.DrawOutlinedRect(0, 0, w, h)
    end
  end
end

function THEME:PaintCharCreationMainPanel(panel, w, h)
  local title = t'ui.char_create.text'
  local title_w, title_h = util.text_size(title, Theme.get_font('main_menu_title'))
  draw.SimpleText(title, Theme.get_font('main_menu_title'), w * 0.5 - title_w * 0.5, h / 8)
end

function THEME:PaintCharCreationLoadPanel(panel, w, h)
  local title = t'ui.char_create.load'
  local title_w, title_h = util.text_size(title, Theme.get_font('main_menu_title'))
  draw.SimpleText(title, Theme.get_font('main_menu_title'), w * 0.5 - title_w * 0.5, h / 8)
end

function THEME:PaintCharCreationBasePanel(panel, w, h)
  if isstring(panel.text) then
    local text_w, text_h = util.text_size(t(panel.text), Theme.get_font('main_menu_large'))
    draw.SimpleText(t(panel.text), Theme.get_font('main_menu_large'), w * 0.5 - text_w * 0.5, 0, Theme.get_color('text'))
  end
end

function THEME:DrawBarBackground(bar_info)
  local height = self:get_option('bar_height')

  draw.box_outlined(4, bar_info.x, bar_info.y + bar_info.height - height, bar_info.width, height, 1, self:get_color('accent'), 2)
end

function THEME:DrawBarHindrance(bar_info)
  local length = bar_info.width * (bar_info.hinder_value / bar_info.max_value)
  local bar_height = self:get_option('bar_height')
  local bar_y = bar_info.y + bar_info.height - (bar_height - 2)

  draw.RoundedBox(2, bar_info.x + bar_info.width - length, bar_y, length - 2, bar_height - 4, bar_info.hinder_color)
end

function THEME:DrawBarFill(bar_info)
  Flux.Bars:hinder_value('health', 30)

  local bar_height = self:get_option('bar_height')
  local barX = bar_info.x + 2
  local bar_y = bar_info.y + bar_info.height - (bar_height - 2)
  local height = bar_height - 4

  if (bar_info.real_fill_width < bar_info.fill_width) then
    draw.RoundedBox(2, barX, bar_y, (bar_info.fill_width or bar_info.width) - 4, height, bar_info.color)
    draw.RoundedBox(2, barX, bar_y, bar_info.real_fill_width - 4, height, self:get_color('accent'))
  elseif (bar_info.real_fill_width > bar_info.fill_width) then
    draw.RoundedBox(2, barX, bar_y, bar_info.real_fill_width - 4, height, bar_info.color)
    draw.RoundedBox(2, barX, bar_y, (bar_info.fill_width or bar_info.width) - 4, height, self:get_color('accent'))
  else
    draw.RoundedBox(2, barX, bar_y, (bar_info.fill_width or bar_info.width) - 4, height, self:get_color('accent'))
  end
end

function THEME:DrawBarTexts(bar_info)
  local font = Theme.get_font(bar_info.font)
  local accent_color = self:get_color('accent')

  draw.SimpleText(bar_info.text, font, bar_info.x, bar_info.y + bar_info.text_offset - 3, accent_color)

  if (bar_info.hinder_display and bar_info.hinder_display <= bar_info.hinder_value) then
    local width = bar_info.width
    local text_wide = util.text_size(bar_info.hinder_text, font)
    local length = width * (bar_info.hinder_value / bar_info.max_value)

    draw.SimpleText(bar_info.hinder_text, font, bar_info.x + width - text_wide, bar_info.y + bar_info.text_offset - 3, accent_color)
  end
end
