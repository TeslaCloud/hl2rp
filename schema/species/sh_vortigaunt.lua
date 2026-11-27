--- Vortigaunts, the aliens from Xen: without a gender, in the vortigaunt model, with random
-- names from `SCHEMA.vortigaunt_names`. Every vortigaunt is a member of the vortigaunt faction,
-- which is whitelisted, so only whitelisted players are offered the species.

SPECIES.name = 'species.vortigaunt.name'
SPECIES.description = 'species.vortigaunt.description'
SPECIES.has_gender = false
SPECIES.default_faction = 'vortigaunt'
SPECIES.random_names = SCHEMA.vortigaunt_names
SPECIES.models.universal = { 'models/teslacloud/vortigaunt.mdl' }
SPECIES.model_classes = { universal = 'vortigaunt' }
