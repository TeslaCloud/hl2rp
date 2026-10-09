--- The Recruit class: the default class of the Combine Civil Authority faction, held by
-- every unit that has just been enlisted. The file is loaded by the Classes plugin and does
-- nothing without it.

if !CLASS then return end

CLASS.name = 'class.recruit.title'
CLASS.description = 'class.recruit.desc'
CLASS.faction = 'cca'
CLASS.wage = 0
