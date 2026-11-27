--- Humans of the city: the human species of Flux in the citizen models of the schema, with
-- random names from `SCHEMA.human_names`. A human who wears nothing that makes them a member of
-- another faction is a citizen.

SPECIES.default_faction = 'citizen'
SPECIES.random_names = SCHEMA.human_names

SPECIES.models.male = {
  'models/teslacloud/citizens/male01.mdl',
  'models/teslacloud/citizens/male02.mdl',
  'models/teslacloud/citizens/male03.mdl',
  'models/teslacloud/citizens/male04.mdl',
  'models/teslacloud/citizens/male05.mdl',
  'models/teslacloud/citizens/male06.mdl',
  'models/teslacloud/citizens/male07.mdl',
  'models/teslacloud/citizens/male08.mdl',
  'models/teslacloud/citizens/male09.mdl',
  'models/teslacloud/citizens/male10.mdl'
}

SPECIES.models.female = {
  'models/teslacloud/citizens/female01.mdl',
  'models/teslacloud/citizens/female02.mdl',
  'models/teslacloud/citizens/female03.mdl',
  'models/teslacloud/citizens/female04.mdl',
  'models/teslacloud/citizens/female05.mdl',
  'models/teslacloud/citizens/female06.mdl',
  'models/teslacloud/citizens/female07.mdl'
}
