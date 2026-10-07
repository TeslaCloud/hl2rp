function PlayerSearch:start(actor, target)
  target.requested_search = nil

  actor:open_player_inventory(target)

  target.searcher = actor
  actor.search_target = target
end

function PlayerSearch:stop(actor, target)
  if IsValid(actor) then
    actor.search_target = nil

    Cable.send(actor, 'fl_inventory_close')
  end

  if IsValid(target) then
    target.searcher = nil
  end
end

function PlayerSearch:OnInventoryClosed(actor, inventory)
  local target = inventory.owner

  if IsValid(target) and target:IsPlayer() and target != actor
  and actor.search_target == target and target.searcher == actor then
    self:stop(actor, target)
  end
end

function PlayerSearch:PlayerOneSecond(actor)
  local target = actor.search_target

  if target then
    local success, error_text = hook.Run('CanSearch', actor, target)

    if success == false then
      actor:notify(error_text)
      self:stop(actor, target)
    end
  end

  if !IsValid(actor.searcher) then
    self:stop(nil, actor)
  end
end

function PlayerSearch:CanStartSearch(actor, target)
  local cur_time = CurTime()

  if actor.next_search and actor.next_search > cur_time then
    return false, 'error.search.too_often'
  end

  if target.next_search and target.next_search > cur_time then
    return false, 'error.cant_now'
  end

  if target.requested_search then
    return false, 'error.search.request'
  end

  if IsValid(target.searcher) and target.searcher != actor then
    return false, 'error.search.already'
  end

  local success, error_text = hook.Run('CanSearch', actor, target)

  if success == false then
    return false, error_text
  end
end

function PlayerSearch:CanSearch(actor, target)
  if target:facing(actor) then
    return false, 'error.must_not_look'
  end

  if actor:GetPos():Distance(target:GetPos()) > 100 then
    return false, 'error.too_far'
  end
  
  if !IsValid(target) then
    return false, 'error.invalid_entity'
  end

  if target:IsBot() then
    return false, 'error.invalid_entity'
  end
end

Cable.receive('fl_request_player_search', function(actor, target)
  local success, error_text = hook.Run('CanStartSearch', actor, target)

  if success != false then
    target.requested_search = true

    Cable.send(target, 'fl_request_player_search', actor)
  else
    actor:notify(error_text)
  end

  local cur_time = CurTime()

  actor.next_search = (!actor.next_search or actor.next_search < cur_time) and cur_time + 1 or actor.next_search + 10
  target.next_search = cur_time + 1
end)

Cable.receive('fl_resist_player_search', function(target, actor)
  actor:notify('notification.search.resist', { player = target })

  target.requested_search = false

  local cur_time = CurTime()

  actor.next_search = actor.next_search and actor.next_search + 5 or cur_time + 5
end)

Cable.receive('fl_start_player_search', function(target, actor)
  PlayerSearch:start(actor, target)
end)
