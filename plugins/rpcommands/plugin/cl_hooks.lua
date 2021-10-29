function RPCommands:HUDPaint()
  if IsValid(PLAYER) then
    for k, v in pairs(RPCommands.texts) do
      local client_pos = EyePos()

      if client_pos:Distance(v.pos) <= 300 and !util.vector_obstructed(client_pos, v.pos, { PLAYER }) then
        local scrw = ScrW()
        local pos = v.pos:ToScreen()
        local cx, cy = ScrC()
        local cam_mult = (1 - math.Distance(cx, cy, pos.x, pos.y) / scrw * 1.5)
        local distance_mult = (1 - client_pos:Distance(v.pos) / 300)
        local alpha = 255 * cam_mult * distance_mult
        local col1, col2 = Color(255, 255, 255, alpha), Color(0, 0, 0, alpha)
        local font = Theme.get_font('menu_small')
        local full_w, full_h = util.text_size(v.text, font)
        local lines = util.wrap_text(v.text, font, scrw / 4, cx - full_w / 2)

        if input.IsKeyDown(KEY_LALT) then
          if PLAYER:is_assistant() then
            table.insert(lines, v.name..' ('..v.steamid..')')
            table.insert(lines, v.time)
          end
        end

        local offset = 4
        local cur_y = pos.y - ((full_h + offset) * #lines) / 2

        for k1, v1 in pairs(lines) do
          local w, h = util.text_size(v1, font)

          draw.SimpleTextOutlined(v1, font, pos.x - w / 2, cur_y, col1, nil, nil, 1, col2)

          cur_y = cur_y + h + offset
        end
      end
    end
  end
end

function RPCommands:DisplayTypingTextType(player, text)
  if text:starts('/me') or text:starts('*') then
    return t'ui.hud.display_typing.performing'
  elseif text:starts('/w') or text:starts('(') then
    return t'ui.hud.display_typing.whispering'
  elseif text:starts('/y') or text:ends('!!') then
    return t'ui.hud.display_typing.yelling'
  elseif !text:is_command() then
    return t'ui.hud.display_typing.talking'
  end
end

function RPCommands:DisplayTypingAdjustFadeoffMultiplier(player, text)
  if text:starts('/w') or text:starts('(') then
    return 0.025
  elseif text:starts('/y') or text:ends('!!') then
    return 1.75
  end
end

Cable.receive('fl_static_text_add', function(data)
  table.insert(RPCommands.texts, data)
end)

Cable.receive('fl_static_text_set', function(data)
  RPCommands.texts = data
end)

Cable.receive('fl_static_text_remove', function(id)
  table.remove(RPCommands.texts, id)
end)

Cable.receive('fl_notify_self', function(player, notification_color, message)
  chat.AddText(notification_color, message)
end)
