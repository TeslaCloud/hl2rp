--- The suit of the City Administrator: a wearable item that puts whoever wears it into the
-- model of the same name in the `cityadmin` model folder and makes them a member of the City
-- Administrator faction.

ITEM:base_off 'wearable'
ITEM.name = 'item.admin_suit.print_name'
ITEM.description = 'item.admin_suit.description'
ITEM.model = 'models/props_c17/suitcase_passenger_physics.mdl'
ITEM.model_group = 'cityadmin'
ITEM.valid_model_group = 'teslacloud/citizens/'
ITEM.equip_model_classes = { male = 'player', female = 'female' }
ITEM.equip_inv = 'equipment_torso'
ITEM.faction = 'admin'
ITEM.width = 3
ITEM.height = 4
ITEM.weight = 3
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
