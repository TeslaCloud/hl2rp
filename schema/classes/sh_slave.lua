--- The Enslaved Vortigaunt class of the Vortigaunt faction, for the vortigaunts that the
-- Combine keeps in shackles. Players cannot pick it themselves: staff put a character into it
-- with the SetClass command. Its ID does not contain the ID of the Vortigaunt class, so that
-- a search for 'vortigaunt' finds only that one. The file is loaded by the Classes plugin and
-- does nothing without it.

if !CLASS then return end

CLASS.name = 'class.slave.title'
CLASS.description = 'class.slave.desc'
CLASS.faction = 'vortigaunt'
CLASS.wage = 0
CLASS.selectable = false
CLASS.priority = 1
