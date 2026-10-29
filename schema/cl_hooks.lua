local alpha_text_color = Color(255, 0, 0, 75)
local vignette_material = util.get_material('materials/flux/hl2rp/vignette.png')

--- Turns on the desaturated color grading once the local player exists.
function SCHEMA:PostInitPostEntity()
  enable_color_mod()
  Flux.set_color_mod('color', 0.85)
  Flux.set_color_mod('addb', 0.015)
end

--- Draws the vignette and the alpha version notice.
function SCHEMA:HUDPaint()
  local w, h = ScrW(), ScrH()
  local text_offset = math.scale(90)

  surface.SetDrawColor(255, 255, 255, 255)
  surface.SetMaterial(vignette_material)
  surface.DrawTexturedRect(0, 0, w, h)

  local _tw, th = draw.SimpleText(
    t'ui.hud.alpha.flux_alpha',
    Theme.get_font('text_large'),
    w - 16,
    h - text_offset,
    alpha_text_color,
    TEXT_ALIGN_RIGHT
  )
  draw.SimpleText(
    t'ui.hud.alpha.subtext',
    Theme.get_font('text_normal'),
    w - 16,
    h - text_offset + th,
    alpha_text_color,
    TEXT_ALIGN_RIGHT
  )
end

--- Plays a train horn when the player creates their first character.
-- @param _char [Character created character]
function SCHEMA:FirstCharacterCreated(_char)
  surface.PlaySound('ambient/alarms/train_horn2.wav')
end
