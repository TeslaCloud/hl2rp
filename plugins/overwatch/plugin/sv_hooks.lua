Cable.receive('fl_punch_cable', function(actor)
  local team_name = team.GetName(actor:Team())

  if (team_name == 'faction.combine.overwatch.title') then
    Cable.send(actor, 'fl_punch_animation', actor)
    if (actor:GetEyeTrace()) then
      local target = actor:GetEyeTrace().Entity
      if (target:IsPlayer()) then
        local distance = actor:GetPos():Distance(target:GetPos())
        if (!target:is_ragdolled() and (distance < 50)) then
          target:set_ragdoll_state(RAGDOLL_FALLENOVER)
        end
      end
    end
  else
    actor:notify('punch.error.wrong_faction')
  end
end)
