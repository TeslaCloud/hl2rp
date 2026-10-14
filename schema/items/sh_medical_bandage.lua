--- The Sterilized Bandage: a medical item that gives back 1 health a second for 4 seconds and,
-- when the Limbs plugin is loaded, takes 30 points of damage off every hurt limb.

ITEM:base_off 'medical'

ITEM.name = 'item.medical_bandage.print_name'
ITEM.print_name = 'item.medical_bandage.print_name'
ITEM.description = 'item.medical_bandage.description'
ITEM.model = 'models/pg_props/pg_obj/pg_bandage.mdl'
ITEM.weight = 1.5
ITEM.stackable = false
ITEM.max_stack = 1

ITEM.health_ticks = 4
ITEM.health_regen = 1
ITEM.health_delay = 1
ITEM.limb_heal = 30
