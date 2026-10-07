--- Opens the recognize menu when the show team key is pressed.
-- @param client [Player local player]
-- @param bind [String bind that was pressed]
-- @param pressed [Boolean whether the key was pressed or released]
function Recognizes:PlayerBindPress(client, bind, pressed)
  if bind:find('gm_showteam') then
    local recognize_menu = vgui.Create('fl_recognize')
    recognize_menu:MakePopup()
    recognize_menu:SetPos(ScrW() * 0.5 - recognize_menu:GetWide() * 0.5, ScrH() * 0.6)
  end
end

--- Replaces the name above players the local player does not recognize with a stranger label.
-- @param target [Player player whose info is drawn]
-- @param x [Number x position of the info]
-- @param y [Number y position of the info]
-- @param distance [Number distance to the player]
-- @param lines [Table info lines to draw, keyed by line ID]
function Recognizes:PreDrawPlayerInfo(target, x, y, distance, lines)
  if !PLAYER:recognizes(target) and lines['name'] then
    lines['name'].text = target:get_gender() == 'female' and t'ui.hud.stranger_female' or t'ui.hud.stranger_male'
  end
end

--- Returns the name the local player knows a player by, or the start of their physical description.
-- @param target [Player player to get the name of]
-- @return [String displayed name]
function Recognizes:GetPlayerName(target)
  local is_known, known_name = PLAYER:recognizes(target)

  if is_known then
    return known_name
  else
    return '['..target:get_phys_desc():utf8sub(1, 32)..'...]'
  end
end

--- Shows real names in out of character messages.
-- @param target [Player player whose name is processed]
-- @param message_data [Table chat message data]
-- @return [Boolean false for non-IC messages, nil otherwise]
function Recognizes:ShouldProcessPlayerName(target, message_data)
  if !message_data.ic then
    return false
  end
end

--- Hides the character card of players the local player does not recognize.
-- @param card [Panel character card]
-- @param target [Player player the card belongs to]
-- @return [Boolean false if the player is not recognized, nil otherwise]
function Recognizes:IsCharacterCardVisible(card, target)
  if !PLAYER:recognizes(target) then
    return false
  end
end

--- Adds a recognize submenu to introduce yourself to a player by real name, a new fake name or a recent one.
-- @param menu [Panel interaction menu]
-- @param target [Player player the menu was opened for]
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

        if text != PLAYER:name(true) and !table.HasValue(history, text) then
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

--- Moves players the local player does not recognize out of their faction into a players online category.
-- @param players_table [Table lists of players keyed by faction category]
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
