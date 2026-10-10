local PANEL = {}
PANEL.cur_panel = nil
PANEL.panels = {}

--- Sets up the centered datafile window and its sidebar.
function PANEL:Init()
  local scrw, scrh = ScrW(), ScrH()
  local width, height = self:get_menu_size()

  self:SetTitle(t'ui.datafile.title')
  self:SetSize(width, height)
  self:SetPos(scrw * 0.5 - width * 0.5, scrh * 0.5 - height * 0.5)

  self.sidebar = vgui.Create('fl_sidebar', self)
  self.sidebar:SetSize(width * 0.2 - 8, height)
  self.sidebar:SetPos(0, 0)
  self.sidebar.Paint = function(pnl, w, h) end
end

--- Draws the outlined, translucent window background.
-- @param w [Number width of the panel]
-- @param h [Number height of the panel]
function PANEL:Paint(w, h)
  local background = Theme.get_color('background')

  DisableClipping(true)

  draw.box_outlined(0, -4, -4, w + 8, h + 24, 2, background)

  DisableClipping(false)

  draw.RoundedBox(0, 0, 0, w, h, background:alpha(150))
end

--- Returns the scaled size of the datafile window.
-- @return [Number width, Number height]
function PANEL:get_menu_size()
  return math.scale(1280), math.scale(900)
end

vgui.Register('fl_datafile_panel', PANEL, 'fl_base_panel')
