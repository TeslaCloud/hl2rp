class 'ItemRadio' extends 'ItemEquipable'

ItemRadio.name = 'item.radio.name'
ItemRadio.description = 'item.radio.description'
ItemRadio.weight = 0.2
ItemRadio.category = 'item.category.communication'
ItemRadio.model = 'models/gibs/shield_scanner_gib1.mdl'
ItemRadio.equip_slot = 'item.slot.communication'

ItemRadio:set_action_sound('on_toggle', 'buttons/button17.wav')
ItemRadio:set_action_sound('set_frequency', 'buttons/button18.wav')

ItemRadio:add_button('toggle', {
  get_name = function(item_obj) return item_obj:is_enabled() and 'item.option.disable' or 'item.option.enable' end,
  get_icon = function(item_obj) return item_obj:is_enabled() and 'icon16/lightning_delete.png' or 'icon16/lightning_add.png' end,
  callback = 'on_toggle'
})

ItemRadio:add_button('frequency', {
  name = 'item.option.frequency',
  icon = 'icon16/control_equalizer_blue.png',
  callback = 'change_frequency',
  on_show = function(item_obj)
    return item_obj:is_enabled()
  end
})

function ItemRadio:is_enabled()
  return self:get_data('enabled', true)
end

function ItemRadio:on_toggle(player)
  self:set_data('enabled', !self:is_enabled())
end

function ItemRadio:get_frequency()
  return self:get_data('frequency', self.frequency or 100.1)
end

function ItemRadio:set_frequency(frequency)
  self:set_data('frequency', frequency)
  self:play_sound('set_frequency')
end

function ItemRadio:change_frequency(player)
  Cable.send(player, 'fl_get_radio_frequency', self.instance_id, self:get_frequency())
end
