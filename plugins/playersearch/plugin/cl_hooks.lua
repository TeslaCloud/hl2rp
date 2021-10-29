function PlayerSearch:CreatePlayerInteractions(menu, target)
  if !target:facing(PLAYER) then
    menu:AddOption(t'ui.search.title', function()
      Cable.send('fl_request_player_search', target)
    end):SetIcon('icon16/magnifier.png')
  end
end

Cable.receive('fl_request_player_search', function(player)
  if PLAYER:IsBot() then
    Cable.send('fl_start_player_search', player)

    return
  end

  if IsValid(Flux.tab_menu) then
    Flux.tab_menu:close_menu()
  end

  Derma_Query(t('ui.search.message', { player = player:name() }), t'ui.search.title',
  t'ui.search.allow', function()
    Cable.send('fl_start_player_search', player)
  end,
  t'ui.search.resist', function()
    Cable.send('fl_resist_player_search', player)
  end)
end)
