function PlayerSearch:start(player, target)
  target.requested_search = nil

  player:open_player_inventory(target)

  target.searcher = player
  player.search_target = target
end

function PlayerSearch:stop(player, target)
  if IsValid(player) then
    player.search_target = nil

    Cable.send(player, 'fl_inventory_close')
  end

  if IsValid(target) then
    target.searcher = nil
  end
end

function PlayerSearch:OnInventoryClosed(player, inventory)
  local target = inventory.owner

  if IsValid(target) and target:IsPlayer() and target != player
  and player.search_target == target and target.searcher == player then
    self:stop(player, target)
  end
end

function PlayerSearch:PlayerOneSecond(player)
  local target = player.search_target

  if target then
    local success, error_text = hook.run('CanSearch', player, target)

    if success == false then
      player:notify(error_text)
      self:stop(player, target)
    end
  end

  if !IsValid(player.searcher) then
    self:stop(nil, player)
  end
end

function PlayerSearch:CanStartSearch(player, target)
  local cur_time = CurTime()

  if player.next_search and player.next_search > cur_time then
    return false, 'error.search.too_often'
  end

  if target.next_search and target.next_search > cur_time then
    return false, 'error.cant_now'
  end

  if target.requested_search then
    return false, 'error.search.request'
  end

  if IsValid(target.searcher) and target.searcher != player then
    return false, 'error.search.already'
  end

  local success, error_text = hook.run('CanSearch', player, target)

  if success == false then
    return false, error_text
  end
end

function PlayerSearch:CanSearch(player, target)
  if target:facing(player) then
    return false, 'error.must_not_look'
  end

  if player:GetPos():Distance(target:GetPos()) > 100 then
    return false, 'error.too_far'
  end
  
  if !IsValid(target) then
    return false, 'error.invalid_entity'
  end

  if target:IsBot() then
    return false, 'error.invalid_entity'
  end
end

Cable.receive('fl_request_player_search', function(player, target)
  local success, error_text = hook.run('CanStartSearch', player, target)

  if success != false then
    target.requested_search = true

    Cable.send(target, 'fl_request_player_search', player)
  else
    player:notify(error_text)
  end

  local cur_time = CurTime()

  player.next_search = (!player.next_search or player.next_search < cur_time) and cur_time + 1 or player.next_search + 10
  target.next_search = cur_time + 1
end)

Cable.receive('fl_resist_player_search', function(target, player)
  player:notify('notification.search.resist', { player = target })

  target.requested_search = false

  local cur_time = CurTime()

  player.next_search = player.next_search and player.next_search + 5 or cur_time + 5
end)

Cable.receive('fl_start_player_search', function(target, player)
  PlayerSearch:start(player, target)
end)
