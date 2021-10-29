local PANEL = {}
PANEL.cur_panel = nil
PANEL.panels = {}

function PANEL:Init()
  local scrw, scrh = ScrW(), ScrH()
  local width, height = self:get_menu_size()

  self:SetTitle(t'ui.datafile.title')
  self:SetSize(width, height)
  self:SetPos(scrw * 0.5 - width * 0.5, scrh * 0.5 - height * 0.5)

  self.sidebar = vgui.Create('fl_sidebar', self)
  self.sidebar:SetSize(width / 5 - 8, height)
  self.sidebar:SetPos(0, 0)
  self.sidebar.Paint = function(pnl, w, h) end

end

function PANEL:Paint(w, h)
  DisableClipping(true)

  draw.box_outlined(0, -4, -4, w + 8, h + 24, 2, Theme.get_color('background'))

  DisableClipping(false)

  draw.RoundedBox(0, 0, 0, w, h, Theme.get_color('background'):alpha(150))
end


function PANEL:get_menu_size()
  return math.scale(1280), math.scale(900)
end

vgui.Register('fl_datafile_panel', PANEL, 'fl_base_panel')
