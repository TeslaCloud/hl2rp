--- The First Aid Kit: a medical item that gives back 100 health over 50 seconds and, when the
-- Limbs plugin is loaded, heals every hurt limb completely.

ITEM:base_off 'medical'

ITEM.name = 'item.medical_fak.print_name'
ITEM.print_name = 'item.medical_fak.print_name'
ITEM.description = 'item.medical_fak.description'
ITEM.model = 'models/items/healthkit.mdl'
ITEM.weight = 1.5
ITEM.stackable = false
ITEM.max_stack = 1

ITEM.health_ticks = 50
ITEM.health_regen = 2
ITEM.health_delay = 1
ITEM.limb_heal = 100
