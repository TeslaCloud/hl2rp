if SERVER then
  function PLUGIN:PlayerSwitchFlashlight(player, on)
    if (on and !player:has_item_equipped('flashlight')) then
      return false
    end

    local hooked = hook.run('PlayerSwitchedFlashlight', player, on)

    if hooked != nil then
      return hooked
    end

    return true
  end

  function PLUGIN:ItemTransferred(item_table, new_inventory, old_inventory)
    if old_inventory then
      local player = old_inventory.owner

      if item_table.id == 'flashlight' and IsValid(player) and player:FlashlightIsOn()
      and !player:has_item_equipped('flashlight') then
        player:Flashlight(false)
      end
    end
  end
end
