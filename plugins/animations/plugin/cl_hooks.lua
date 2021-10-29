function Animations:ContextMenuCreated(context_menu)
  if !Theme.initialized() then return end

  local panel = vgui.create('fl_base_panel', context_menu)
  panel:SetSize(math.scale_size(200, 224))
  panel:SetPos(math.scale_x(100), ScrH() * 0.7)
  panel:DockPadding(math.scale_x(4), math.scale(4), math.scale_x(4), math.scale(4))
  panel.Paint = function(pnl, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
  end

  local title = vgui.create('DLabel', panel)
  title:SetText(t'ui.animations.title')
  title:SetFont(Theme.get_font('text_normal'))
  title:SetColor(color_white)
  title:SetContentAlignment(5)
  title:SizeToContents()
  title:Dock(TOP)

  local list = vgui.create('DScrollPanel', panel)
  list:Dock(FILL)

  function panel:rebuild()
    list:Clear()

    for k, v in pairs(Animations:all()) do
      if v.enter and PLAYER:LookupSequence(v.enter) == -1
      or v.anim and PLAYER:LookupSequence(v.anim) == -1
      or v.exit and PLAYER:LookupSequence(v.exit) == -1 then continue end

      local line = vgui.create('fl_button', list)
      line:Dock(TOP)
      line:set_text(t(v.name))
      line:set_text_offset(math.scale_x(4))
      line.animation = v.id
      line.DoClick = function(pnl)
        PLAYER:play_animation(pnl.animation)
      end

      local preview_back = vgui.create('fl_base_panel')
      preview_back:SetSize(math.scale_size(150, 150))

      local preview_model = vgui.create('DModelPanel', preview_back)
      preview_model:Dock(FILL)
      preview_model:SetModel(PLAYER:GetModel())
      preview_model.Entity:SetSequence(v.anim)
      preview_model.LayoutEntity = function(pnl, entity)
        pnl:RunAnimation()
      end

      line:SetTooltipPanel(preview_back)

      list:AddItem(line)
    end
  end

  Flux.animations_panel = panel
end

function Animations:OnContextMenuOpen()
  Flux.animations_panel:rebuild()
end

function Animations:ShouldHUDPaintCrosshair()
  if PLAYER:get_nv('fl_animation') then
    return false
  end
end
