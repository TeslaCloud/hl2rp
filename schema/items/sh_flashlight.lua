--- The Flashlight: an equipable item that players need to have equipped on their hotbar to turn
-- their flashlight on, as the `shared_flashlight_item` value of the schema config sets. With
-- the flashlight in the hands, primary attack switches the light the way the flashlight key
-- does.

ITEM:base_off 'equipable'
ITEM.name = 'item.flashlight.print_name'
ITEM.print_name = 'item.flashlight.print_name'
ITEM.description = 'item.flashlight.description'
ITEM.model = 'models/lamps/torch.mdl'
ITEM.weight = 0.5

if CLIENT then
  --- Switches the flashlight of the local player on or off when they click primary attack
  -- while the flashlight is in their hands on the hotbar, by sending the impulse of the
  -- flashlight key.
  -- @param _client [Player the local player]
  function ITEM:on_hotbar_use(_client)
    RunConsoleCommand('impulse', '100')
  end
end
