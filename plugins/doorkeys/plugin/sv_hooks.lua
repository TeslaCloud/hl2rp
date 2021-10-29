function PLUGIN:PlayerCanLockDoor(player, entity)
  local keys = player:find_items('key')

  if keys then
    for k, v in pairs(keys) do
      if table.has_value(v:get_data('doors', {}), entity:MapCreationID()) then
        return true
      end
    end
  end
end

Cable.receive('fl_key_create', function(player, entity)
  local doors = {
    entity:MapCreationID()
  }

  local item_table = Item.create('key')
  item_table:set_data('doors', doors)

  player:give_item_by_id(item_table.instance_id)
  player:notify('notification.key.create')
end)

Cable.receive('fl_key_copy', function(player, instance_id)
  local source_item = Item.find_instance_by_id(instance_id)
  local item_table = Item.create('key')
  item_table:set_data('doors', source_item:get_data('doors'))

  hook.run('OnKeyCopy', player, item_table, source_item)

  player:give_item_by_id(item_table.instance_id)
  player:take_item('key_blank')
  player:notify('notification.key.create')
end)

Cable.receive('fl_key_remove', function(player, instance_id, entity)
  local door_id = entity:MapCreationID()
  local item_table = Item.find_instance_by_id(instance_id)
  local doors = item_table:get_data('doors', {})

  table.remove_by_value(doors, door_id)

  item_table:set_data('doors', doors)
  player:notify('notification.key.remove')
end)

Cable.receive('fl_key_add', function(player, instance_id, entity)
  local door_id = entity:MapCreationID()
  local item_table = Item.find_instance_by_id(instance_id)
  local doors = item_table:get_data('doors', {})

  if !table.has_value(doors, door_id) then
    table.insert(doors, door_id)
  end

  item_table:set_data('doors', doors)
  player:notify('notification.key.add')
end)

Cable.receive('fl_key_show_list', function(player, entity)
  local door_id = entity:MapCreationID()
  local keys = {}
  local instances = Item.find_all_instances('key')

  if instances then
    for k, v in pairs(instances) do
      if table.has_value(v:get_data('doors', {}), door_id) then
        Item.network_item(player, k)
        table.insert(keys, k)
      end
    end
  end

  Cable.send(player, 'fl_key_show_list', keys, entity)
end)
