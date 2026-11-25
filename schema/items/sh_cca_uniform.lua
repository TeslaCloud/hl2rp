--- The Civil Protection uniform: a wearable item that puts whoever wears it into the model of the
-- same name in the `cca` model folder.

ITEM:base_off 'wearable'
ITEM.name = 'item.cca_uniform.print_name'
ITEM.description = 'item.cca_uniform.description'
ITEM.model = 'models/props_junk/cardboard_box003a.mdl'
ITEM.model_group = 'cca'
ITEM.equip_inv = 'equipment_torso'
ITEM.width = 3
ITEM.height = 4
ITEM.weight = 4
ITEM.icon_data = {
  origin = Vector(150, 1, 55),
  angles = Angle(5, 180, 0),
  fov    = 11
}

ITEM.disabled_inventories = {
  'equipment_helmet',
  'equipment_hands',
  'equipment_legs'
}
