if SERVER then
  function PLUGIN:PlayerSwitchFlashlight(actor, on)
    if (on and !actor:has_item_equipped('flashlight')) then
      return false
    end

    local hooked = hook.Run('PlayerSwitchedFlashlight', actor, on)

    if hooked != nil then
      return hooked
    end

    return true
  end

  function PLUGIN:ItemTransferred(item_table, new_inventory, old_inventory)
    if old_inventory then
      local owner = old_inventory.owner

      if item_table.id == 'flashlight' and IsValid(owner) and owner:FlashlightIsOn()
      and !owner:has_item_equipped('flashlight') then
        owner:Flashlight(false)
      end
    end
  end
end
