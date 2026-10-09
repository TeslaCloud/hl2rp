if SERVER then
  --- Only lets players turn on their flashlight while they have a flashlight item equipped.
  -- The engine always asks to turn its flashlight on while the shared flashlight stands in
  -- for it, so a lit flashlight is let through: the toggle is turning it off.
  -- @param actor [Player player toggling the flashlight]
  -- @param on [Boolean whether the flashlight is being turned on]
  -- @return [Boolean whether the flashlight can be toggled]
  function PLUGIN:PlayerSwitchFlashlight(actor, on)
    if on and !actor:is_flashlight_on() and !actor:has_item_equipped('flashlight') then
      return false
    end

    local hooked = hook.Run('PlayerSwitchedFlashlight', actor, on)

    if hooked != nil then
      return hooked
    end

    return true
  end

  --- Turns off the previous owner's flashlight when their flashlight item leaves their inventory.
  -- @param item_table [Item transferred item]
  -- @param new_inventory [Inventory inventory the item was moved to]
  -- @param old_inventory [Inventory inventory the item was moved from]
  function PLUGIN:ItemTransferred(item_table, new_inventory, old_inventory)
    if old_inventory then
      local owner = old_inventory.owner

      if item_table.id == 'flashlight' and IsValid(owner) and owner:is_flashlight_on()
      and !owner:has_item_equipped('flashlight') then
        owner:set_flashlight(false)
      end
    end
  end
end
