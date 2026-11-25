--- Shared hooks of the Force Fields plugin: on both realms, they keep what force fields decide
-- by up to date for every player and tell the physics engine when it changes.

--- Looks again once a second at what force fields decide by for every player.
function ForceFields:OneSecond()
  for _, target in player.Iterator() do
    self:update_collision_state(target)
  end
end

--- Tells the physics engine that a player who presses the use key collides with force fields.
-- @param actor [Player]
-- @param key [Number IN_ key that was pressed]
function ForceFields:KeyPress(actor, key)
  if key == IN_USE then
    actor:CollisionRulesChanged()
  end
end

--- Tells the physics engine that a player who lets go of the use key goes by the mode of force
-- fields again.
-- @param actor [Player]
-- @param key [Number IN_ key that was released]
function ForceFields:KeyRelease(actor, key)
  if key == IN_USE then
    actor:CollisionRulesChanged()
  end
end
