--- Adds the VoiceLines command, which lists the voice lines of the character of the player, to
-- the `user` role, and through it to every role based on it.

--- Allows the VoiceLines command.
function ROLE:define_permissions()
  can 'voicelines'
end
