function CombatSystem:PostDrawTranslucentRenderables(depth, skybox)
  if depth or skybox then return end

  local pos = PLAYER.walk_pos

  if pos then
    local turns = PLAYER:get_turns(TURN_MOVE)
    local walk_speed, run_speed = PLAYER:GetWalkSpeed() * turns, PLAYER:GetRunSpeed() * turns
    local trace = util.TraceLine({
      start = pos,
      endpos = pos + Vector(0, 0, -100),
      filter = PLAYER
    })

    cam.Start3D2D(pos + Vector(0, 0, 5), trace.HitNormal:Angle() + Angle(90, 0, 0), 1)
      surface.SetDrawColor(35, 210, 250)
      surface.draw_circle_outline(0, 0, walk_speed, 3, 50)

      if run_speed > walk_speed then
        surface.SetDrawColor(255, 220, 75)
        surface.draw_circle_outline(0, 0, run_speed, 3, 50)
      end
    cam.End3D2D()
  end
end

function CombatSystem:CanPlayerAttack()
  local weapon = PLAYER:GetActiveWeapon()

  if IsValid(weapon) and PLAYER:IsFrozen() then
    return false
  end
end

function CombatSystem:StartCommand(player, user_cmd)
  local weapon = PLAYER:GetActiveWeapon()

  if IsValid(weapon) and PLAYER:IsFrozen() then
    user_cmd:RemoveKey(IN_RELOAD)
  end
end

function CombatSystem:HUDPaint()
  if PLAYER:in_combat() and !PLAYER:IsFrozen() then
    local turns = PLAYER:get_nv('fl_combat_turns', {})
    local scrw, scrh = ScrC()
    local x, y = scrw, scrh
    local gx, gy = Flux.global_ui_offset()
    local color = Color('aqua'):alpha(200)
    local color_outline = color_black:alpha(200)
    local icon_size = 32
    local icon_w, icon_h = FontAwesome:get_icon_size('fa-crosshairs', icon_size)

    x, y = x + gx, y + gy

    local icon_x, icon_y = x - icon_w * 8, y + icon_h * 6
    local icon_x_right = icon_x + icon_w * 15

    FontAwesome:draw('fa-crosshairs', icon_x, icon_y, icon_size, color, nil, nil, 1, color_outline)
    FontAwesome:draw('fa-shoe-prints', icon_x_right, icon_y, icon_size, color, nil, nil, 1, color_outline)

    local text = turns[TURN_ATTACK]
    local font = Theme.get_font('menu_large')
    local text_w, text_h = util.text_size(text, font)

    draw.SimpleTextOutlined(text, font, icon_x + text_w * 0.5, icon_y + text_h + math.scale(4), color, nil, nil, 1, color_outline)

    text = turns[TURN_MOVE]
    text_w, text_h = util.text_size(text, font)

    draw.SimpleTextOutlined(text, font, icon_x_right + text_w * 0.5, icon_y + text_h + math.scale(4), color, nil, nil, 1, color_outline)

    local cur_time = CurTime()

    if PLAYER.turn_end and PLAYER.turn_end > cur_time then
      text = math.round(PLAYER.turn_end - cur_time, 1)
      text_w, text_h = util.text_size(text, font)
      draw.SimpleTextOutlined(text, font, gx + scrw - text_w * 0.5, icon_y + text_h + math.scale(4), color, nil, nil, 1, color_outline)
    end

    font = Theme.get_font('menu_small')
    text = t'ui.hud.skip'
    text_w, text_h = util.text_size(text, font)
    draw.SimpleTextOutlined(text, font, gx + scrw - text_w * 0.5, icon_y + text_h * 3, color, nil, nil, 1, color_outline)
  end
end

function CombatSystem:create_notify(text)
  if IsValid(Flux.combat_notify) then
    Flux.combat_notify:safe_remove()
  end

  local notify = vgui.create('DNotify')
  notify:SetLife(2)

  local label = vgui.create('DLabel', notify)
  label:Dock(FILL)
  label:SetText(text)
  label:SetTextColor(color_white)
  label:SetFont(Theme.get_font('main_menu_title'))
  label:SizeToContents()

  notify:AddItem(label)
  notify:SetSize(label:GetSize())
  notify:SetPos(ScrW() * 0.5 - notify:GetWide() * 0.5, ScrH() * 0.2)

  Flux.combat_notify = notify
end

function CombatSystem:create_message(text, arguments)
  local color = Color('lightgray')

  if arguments then
    if text:find('success') and arguments.attacker and arguments.attacker == PLAYER
    or text:find('fail') and arguments.target == PLAYER then
      color = Color('aqua')
    elseif text:find('success') and arguments.target and arguments.target == PLAYER
    or text:find('fail') and arguments.attacker == PLAYER then
      color = Color('orangered')
    elseif arguments.entity and arguments.entity == PLAYER then
      color = Color('gold')
    end

    for k, v in pairs(arguments) do
      if isstring(v) then
        arguments[k] = t(v)
      elseif isentity(v) and IsValid(v) then
        if v:IsPlayer() then
          arguments[k] = hook.run('GetPlayerName', v) or v:name()
        else
          arguments[k] = hook.run('GetEntityName', v) or tostring(v) or v:GetClass()
        end
      end
    end
  end

  chat.AddText(16, color, t(text, arguments))
end

Cable.receive('fl_combat_notify_turn', function(entity)
  local text = t('notification.combat.turn', { entity = t(entity:get_name()) })
  local sound = 'ui/freeze_cam.wav'

  if entity == PLAYER then
    text = t'notification.combat.your_turn'
    sound = 'ui/achievement_earned.wav'
  end

  PLAYER:EmitSound(sound, 75, 100, 0.5)
  CombatSystem:create_notify(text)
end)

Cable.receive('fl_combat_notify_finish', function()
  PLAYER:EmitSound('ui/achievement_earned.wav', 75, 100, 0.5)
  CombatSystem:create_notify(t('notification.combat.finish'))
end)

Cable.receive('fl_combat_message', function(text, arguments)
  CombatSystem:create_message(text, arguments)
end)

Cable.receive('fl_combat_turn_order', function(order)
  timer.simple(0, function()
    CombatSystem:create_message('notification.combat.turn_order')

    for k, v in pairs(order) do
      timer.simple(0, function()
        CombatSystem:create_message('{entity} - {initiative}', { entity = v.entity, initiative = v.initiative })
      end)
    end
  end)
end)

Cable.receive('fl_combat_update_pos', function(pos)
  PLAYER.walk_pos = pos
  chat.PlaySound()
end)

Cable.receive('fl_combat_end_turn', function()
  PLAYER.walk_pos = nil
  PLAYER.turn_end = nil
end)

Cable.receive('fl_combat_start_turn', function(pos)
  PLAYER.walk_pos = pos
  PLAYER.turn_end = CurTime() + 60
end)
