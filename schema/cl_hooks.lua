local blur_texture = Material('pp/blurscreen')
local texture = GetRenderTarget('fl_rt_'..os.time(), ScrW(), ScrH(), false)
local mat = CreateMaterial('fl_mat_'..os.time(), 'UnlitGeneric', {
  ['$basetexture'] = texture
})
local alpha_text_color = Color(255, 0, 0, 75)

function SCHEMA:HUDPaint()
  local w, h = ScrW(), ScrH()
  local text_offset = math.scale(90)

  enable_color_mod()
  Flux.set_color_mod('color', 0.85)
  Flux.set_color_mod('addb', 0.015)

  surface.SetDrawColor(255, 255, 255, 255)
  surface.SetMaterial(util.get_material('materials/flux/hl2rp/vignette.png'))
  surface.DrawTexturedRect(0, 0, w, h)

  local tw, th = draw.SimpleText(t'ui.hud.alpha.flux_alpha', Theme.get_font('text_large'), w - 16, h - text_offset, alpha_text_color, TEXT_ALIGN_RIGHT)
  draw.SimpleText(t'ui.hud.alpha.subtext', Theme.get_font('text_normal'), w - 16, h - text_offset + th, alpha_text_color, TEXT_ALIGN_RIGHT)
end

function SCHEMA:FirstCharacterCreated(char)
  surface.PlaySound('ambient/alarms/train_horn2.wav')
end
