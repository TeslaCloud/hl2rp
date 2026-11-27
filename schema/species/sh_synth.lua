--- Synths, the transhuman soldiers of the Combine: without a gender and without a name of their
-- own, in the Overwatch model. Every synth is a member of the Overwatch faction, which is
-- whitelisted, so only whitelisted players are offered the species. The real name of a synth
-- is its unit number.

SPECIES.name = 'species.synth.name'
SPECIES.description = 'species.synth.description'
SPECIES.has_gender = false
SPECIES.has_name = false
SPECIES.default_faction = 'overwatch'
SPECIES.models.universal = { 'models/teslacloud/overwatch/overwatch.mdl' }
SPECIES.model_classes = { universal = 'combine_soldier' }

--- Names a new synth with a random unit number from 100 to 999.
-- @param _gender [Number CHAR_GENDER_* value]
-- @return [String the unit number]
function SPECIES:get_random_name(_gender)
  return tostring(math.random(100, 999))
end
