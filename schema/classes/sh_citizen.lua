--- The Citizen class: the default class of the Citizen faction, held by every ordinary
-- resident of the city. The file is loaded by the Classes plugin and does nothing without it.

if !CLASS then return end

CLASS.name = 'class.citizen.title'
CLASS.description = 'class.citizen.desc'
CLASS.faction = 'citizen'
CLASS.wage = 0
