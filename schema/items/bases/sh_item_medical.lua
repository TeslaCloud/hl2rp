if !ItemUsable then
  require_relative 'sh_item_usable'
end

class 'ItemMedical' extends 'ItemUsable'

ItemMedical.name = 'Medical Base'
ItemMedical.description = 'An item that can be used to heal or relieve.'
ItemMedical.category = 'item.category.medical'
ItemMedical.use_text = 'item.action.apply'

function ItemMedical:on_use(player)
  local player_health = player:Health()
  local max_health = player:GetMaxHealth()
  local missing_health = max_health - player_health
  local health_regen = self.health_regen

  local max_msg_table = {
    Color('pink'),
    { icon = 'fa-heartbeat', size = 16, margin = 8, is_data = true },
    'You are already full health.',
    { sender = player }
  }

  local exist_msg_table = {
    Color('pink'),
    { icon = 'fa-heartbeat', size = 16, margin = 8, is_data = true },
    'You are already healing.',
    { sender = player }
  }

  -- Sanity Check [ Limit to max_health ]
  if (self.health_regen > missing_health) then
    health_regen = missing_health
  end

  -- Sanity Check [ Disallow if at max_health ]
  if (player_health >= max_health) then
    Chatbox.add_text(player, unpack(max_msg_table))
    return false
  end

  if !timer.Exists('health_replenish') then
    timer.Create('health_replenish', self.health_delay, self.health_ticks, function()
      if player:Health() < player:GetMaxHealth() then
        player:SetHealth(player:Health() + self.health_regen)
      else
        player:SetHealth(player:GetMaxHealth())
      end
    end)
  else
    Chatbox.add_text(player, unpack(exist_msg_table))
    return false
  end

  if !timer.Exists('health_sanity_check') then
    timer.Create('health_sanity_check', (self.health_delay * self.health_ticks) + 1, 1, function()
      if player:Health() > player:GetMaxHealth() then
        player:SetHealth(player:GetMaxHealth())
      end
    end)
  end
end
