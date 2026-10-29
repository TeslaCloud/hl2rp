--- Server side of the schema: the punch of Overwatch soldiers.

const punch_range_sqr = 50 * 50

--- Makes an Overwatch soldier punch: they play their melee gesture and knock over the player
-- they look at within 50 units, unless that player is ragdolled already. A player tries to
-- punch once a second at most; a soldier does not punch while dead or ragdolled, and a player
-- of another faction is told that they may not punch. Does nothing without the Ragdoll plugin.
-- @param actor [Player the player who punches]
function SCHEMA:punch(actor)
  local cur_time = CurTime()

  if (actor.fl_next_punch or 0) > cur_time then return end

  actor.fl_next_punch = cur_time + 1

  if actor:get_faction_id() != 'overwatch' then
    actor:notify('error.punch.wrong_faction')

    return
  end

  if !Ragdoll or !actor:Alive() or actor:is_ragdolled() then return end

  actor:play_gesture(ACT_MELEE_ATTACK1)

  local target = actor:GetEyeTrace().Entity

  if IsValid(target) and target:IsPlayer() and target:Alive() and !target:is_ragdolled()
  and actor:GetPos():DistToSqr(target:GetPos()) < punch_range_sqr then
    target:set_ragdoll_state(RAGDOLL_FALLENOVER)
  end
end
