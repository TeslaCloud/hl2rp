--- The Civil Protection uniform: a wearable item that puts whoever wears it into the model of the
-- same name in the `cca` model folder and makes them a member of the Civil Protection, at the
-- rank kept on the uniform.

ITEM:base_off 'wearable'
ITEM.name = 'item.cca_uniform.print_name'
ITEM.description = 'item.cca_uniform.description'
ITEM.model = 'models/props_junk/cardboard_box003a.mdl'
ITEM.model_group = 'cca'
ITEM.valid_model_group = 'teslacloud/citizens/'
ITEM.equip_model_classes = { male = 'metrocop', female = 'female' }
ITEM.equip_inv = 'equipment_torso'
ITEM.faction = 'cca'
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
