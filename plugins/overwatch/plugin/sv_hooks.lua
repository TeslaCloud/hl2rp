Cable.receive('fl_punch_cable', function(actor)
  local team_name = team.GetName(actor:Team())

  if team_name == 'faction.combine.overwatch.title' then
    actor:play_gesture(ACT_MELEE_ATTACK1)

    local trace = actor:GetEyeTrace()

    if trace then
      local target = trace.Entity

      if target:IsPlayer() then
        local distance_sqr = actor:GetPos():DistToSqr(target:GetPos())

        if !target:is_ragdolled() and distance_sqr < 2500 then
          target:set_ragdoll_state(RAGDOLL_FALLENOVER)
        end
      end
    end
  else
    actor:notify('punch.error.wrong_faction')
  end
end)
