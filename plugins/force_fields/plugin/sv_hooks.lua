--- Server hooks of the Force Fields plugin: a player who changes faction or rank is looked at
-- again right away.

--- Looks again at a player who has been moved into another faction.
-- @param target [Player]
-- @param _faction_table [Faction]
-- @param _old_faction [Faction]
function ForceFields:PlayerFactionChanged(target, _faction_table, _old_faction)
  self:update_collision_state(target)
end

--- Looks again at a player whose rank has changed.
-- @param target [Player]
-- @param _rank [Number]
-- @param _old_rank [Number]
function ForceFields:PlayerRankChanged(target, _rank, _old_rank)
  self:update_collision_state(target)
end
