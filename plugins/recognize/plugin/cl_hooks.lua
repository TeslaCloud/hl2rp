function Recognizes:PlayerBindPress(player, bind, pressed)
  if bind:find('gm_showteam') then
    local recognize_menu = vgui.create('fl_recognize')
    recognize_menu:MakePopup()
    recognize_menu:SetPos(ScrW() * 0.5 - recognize_menu:GetWide() * 0.5, ScrH() * 0.6)
  end
end

function Recognizes:PreDrawPlayerInfo(target, x, y, distance, lines)
  if !PLAYER:recognizes(target) and lines['name'] then
    lines['name'].text = target:get_gender() == 'female' and t'ui.hud.stranger_female' or t'ui.hud.stranger_male'
  end
end

function Recognizes:GetPlayerName(target)
  local is_known, known_name = PLAYER:recognizes(target)

  if is_known then
    return known_name
  else
    return '['..target:get_phys_desc():utf8sub(1, 32)..'...]'
  end
end

function Recognizes:ShouldProcessPlayerName(player, message_data)
  if !message_data.ic then
    return false
  end
end

function Recognizes:IsCharacterCardVisible(card, target)
  if !PLAYER:recognizes(target) then
    return false
  end
end

function Recognizes:CreatePlayerInteractions(menu, target)
  local recognize_menu, recognize_menu_option = menu:AddSubMenu(t'ui.recognize.title')
  recognize_menu_option:SetIcon('icon16/user_comment.png')

  recognize_menu:AddOption(t'ui.recognize.character_name', function()
    surface.PlaySound('buttons/blip1.wav')

    Cable.send('fl_recognize', 'target', false, target)
  end):SetIcon('icon16/emoticon_grin.png')

  local history = Data.load('name_history/'..PLAYER:name(true), {})

  local fake_name, fake_name_option = recognize_menu:AddSubMenu(t'ui.recognize.fake_name')
  fake_name_option:SetIcon('icon16/emoticon_evilgrin.png')

  fake_name:AddOption(t'ui.recognize.enter_fake_name', function()
    Derma_StringRequest(t'ui.recognize.enter_fake_name', t'ui.recognize.message', PLAYER:name(), function(text)
      surface.PlaySound('buttons/blip1.wav')

      if text and text != '' then
        Cable.send('fl_recognize', 'target', text, target)

        if text != PLAYER:name(true) and !table.has_value(history, text) then
          table.insert(history, 1, text)

          if #history > 5 then
            table.remove(history, 6)
          end

          Data.save('name_history/'..PLAYER:name(true), history)
        end
      end
    end)
  end)

  for k, v in pairs(history) do
    fake_name:AddOption(v, function()
      Cable.send('fl_recognize', 'target', v, target)
    end)
  end
end

function Recognizes:PreRebuildFactionCategories(players_table)
  local players_online = {}

  for k, v in pairs(players_table) do
    for k1, v1 in pairs(v) do
      if !PLAYER:recognizes(v1) then
        table.insert(players_online, v1)
        v[k1] = nil
      end
    end
  end

  players_table['players_online'] = players_online
end
