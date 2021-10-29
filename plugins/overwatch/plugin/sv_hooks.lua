Cable.receive('fl_punch_cable', function(player)
  local team_name = _team.GetName(player:Team())

  if (team_name == 'faction.combine.overwatch.title') then
    Cable.send(player, 'fl_punch_animation', player)
    if (player:GetEyeTrace()) then
      local target = player:GetEyeTrace().Entity
      if (target:IsPlayer()) then
        local distance = player:GetPos():Distance(target:GetPos())
        if (!target:is_ragdolled() and (distance < 50)) then
          target:set_ragdoll_state(RAGDOLL_FALLENOVER)
        end
      end
    end
  else
    player:notify('punch.error.wrong_faction')
  end
end)
