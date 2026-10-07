if !ItemUsable then
  require_relative 'sh_item_usable'
end

class 'ItemMedical' extends 'ItemUsable'

ItemMedical.name = 'Medical Base'
ItemMedical.description = 'An item that can be used to heal or relieve.'
ItemMedical.category = 'item.category.medical'
ItemMedical.use_text = 'item.action.apply'

--- Heals the player over time, refusing if they are at full health or already healing.
-- @param actor [Player player using the item]
-- @return [Boolean false if the item was not used, nil otherwise]
function ItemMedical:on_use(actor)
  local player_health = actor:Health()
  local max_health = actor:GetMaxHealth()
  local missing_health = max_health - player_health
  local health_regen = self.health_regen

  local max_msg_table = {
    Color('pink'),
    { icon = 'fa-heartbeat', size = 16, margin = 8, is_data = true },
    'You are already full health.',
    { sender = actor }
  }

  local exist_msg_table = {
    Color('pink'),
    { icon = 'fa-heartbeat', size = 16, margin = 8, is_data = true },
    'You are already healing.',
    { sender = actor }
  }

  if self.health_regen > missing_health then
    health_regen = missing_health
  end

  if player_health >= max_health then
    Chatbox.add_text(actor, unpack(max_msg_table))
    return false
  end

  if !timer.Exists('health_replenish') then
    timer.Create('health_replenish', self.health_delay, self.health_ticks, function()
      if actor:Health() < actor:GetMaxHealth() then
        actor:SetHealth(actor:Health() + self.health_regen)
      else
        actor:SetHealth(actor:GetMaxHealth())
      end
    end)
  else
    Chatbox.add_text(actor, unpack(exist_msg_table))
    return false
  end

  if !timer.Exists('health_sanity_check') then
    timer.Create('health_sanity_check', (self.health_delay * self.health_ticks) + 1, 1, function()
      if actor:Health() > actor:GetMaxHealth() then
        actor:SetHealth(actor:GetMaxHealth())
      end
    end)
  end
end
