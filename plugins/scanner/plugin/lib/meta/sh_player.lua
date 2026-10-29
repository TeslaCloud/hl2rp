--- Player extensions of the Scanner plugin: whether a player controls a scanner, and which.

local player_meta = FindMetaTable('Player')

--- Checks whether the player is controlling a scanner.
-- @return [Boolean whether the player controls a scanner]
function player_meta:controls_scanner()
  return self.scanner != nil
end

--- Returns the scanner the player is controlling.
-- @return [Entity scanner, nil if the player does not control one]
function player_meta:get_scanner()
  return self.scanner
end
