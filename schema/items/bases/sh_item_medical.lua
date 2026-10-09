--- ItemMedical is the base class for items that treat wounds, such as bandages and first aid
-- kits. Using one heals the player over time: `health_regen` health every `health_delay`
-- seconds, `health_ticks` times. Every player has a healing timer of their own, so any number
-- of players can be healing at once, but one player cannot stack two treatments. The healing
-- stops when the player dies or switches to another character.
--
-- When the Limbs plugin is loaded, the item also takes `limb_heal` points of damage off every
-- hurt limb of the player at the moment it is used. An item whose `limb_heal` is 0 leaves the
-- limbs alone, and without the Limbs plugin the field does nothing.
--
-- The item is refused, and kept, when the player has nothing it could treat or is still being
-- healed by another medical item.

if !ItemUsable then
  require_relative 'sh_item_usable'
end

class 'ItemMedical' extends 'ItemUsable'

ItemMedical.name = 'Medical Base'
ItemMedical.description = 'An item that can be used to heal or relieve.'
ItemMedical.category = 'item.category.medical'
ItemMedical.use_text = 'item.action.apply'
ItemMedical.health_regen = 0
ItemMedical.health_ticks = 0
ItemMedical.health_delay = 1
ItemMedical.limb_heal = 0

--- Returns the name of the timer that heals a player over time. It is built from the user
-- ID of the player, which no two connected players share, bots included.
-- @param actor [Player]
-- @return [String timer name]
function ItemMedical:get_heal_timer(actor)
  return 'fl_medical_heal_'..actor:UserID()
end

--- Checks whether a player is still being healed by a medical item. The healing timers only
-- exist on the server, so this is always false on the client.
-- @param actor [Player]
-- @return [Boolean]
function ItemMedical:is_healing(actor)
  return timer.Exists(self:get_heal_timer(actor))
end

--- Checks whether the item would heal the player over time: it has to give health at all, and
-- the player has to be below their maximum health.
-- @param actor [Player]
-- @return [Boolean]
function ItemMedical:can_heal(actor)
  return self.health_regen > 0 and self.health_ticks > 0 and actor:Health() < actor:GetMaxHealth()
end

--- Checks whether the item would treat the limbs of the player: its `limb_heal` has to be
-- above 0, the Limbs plugin has to be loaded with limb damage turned on, and the player has
-- to have a hurt limb. On the client only the limbs of the local player are known.
-- @param actor [Player]
-- @return [Boolean]
function ItemMedical:can_treat_limbs(actor)
  return self.limb_heal > 0 and Limbs != nil and Limbs:is_any_damaged(actor)
end

--- Called by ItemUsable:on_use before the item is used. Refuses the item and notifies the
-- player if neither their health nor their limbs need what the item gives, or if they are
-- still being healed by another medical item.
-- @param actor [Player]
-- @return [Boolean false to prevent the use, nil otherwise]
function ItemMedical:can_use(actor)
  if !self:can_heal(actor) and !self:can_treat_limbs(actor) then
    actor:notify('error.item.nothing_to_treat', nil, Color('pink'))

    return false
  end

  if self:is_healing(actor) then
    actor:notify('error.item.already_healing', nil, Color('pink'))

    return false
  end
end

--- Called by ItemUsable:on_use when the item is used. Treats the hurt limbs of the player if
-- the Limbs plugin is loaded, then starts healing the player over time.
-- @param actor [Player]
function ItemMedical:use(actor)
  if self:can_treat_limbs(actor) then
    Limbs:heal_all(actor, self.limb_heal)
  end

  self:start_healing(actor)
end

--- Starts the timer that heals the player over time, unless the item gives no health or the
-- player is at their maximum health already. Every tick gives `health_regen` health, never
-- above the maximum health of the player; health that is above the maximum for another reason
-- is left alone. The timer removes itself when the player leaves, dies or switches to another
-- character. Server only.
-- @param actor [Player]
function ItemMedical:start_healing(actor)
  if !self:can_heal(actor) then return end

  local timer_name = self:get_heal_timer(actor)
  local character_id = actor:get_character_id()
  local health_regen = self.health_regen

  timer.Create(timer_name, self.health_delay, self.health_ticks, function()
    if !IsValid(actor) or !actor:Alive() or actor:get_character_id() != character_id then
      timer.Remove(timer_name)

      return
    end

    local health, max_health = actor:Health(), actor:GetMaxHealth()

    if health < max_health then
      actor:SetHealth(math.min(health + health_regen, max_health))
    end
  end)
end
