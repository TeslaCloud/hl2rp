--- The First Aid Kit: a medical item that gives back 1d4 health a second for 5 seconds and,
-- when the Limbs plugin is loaded, heals every hurt limb completely.

ITEM:base_off 'medical'

ITEM.name = 'item.medical_fak.print_name'
ITEM.print_name = 'item.medical_fak.print_name'
ITEM.description = 'item.medical_fak.description'
ITEM.model = 'models/items/healthkit.mdl'
ITEM.weight = 1.5
ITEM.stackable = false
ITEM.max_stack = 1

ITEM.health_ticks = 5
ITEM.health_regen = '1d4'
ITEM.health_delay = 1
ITEM.limb_heal = 100
