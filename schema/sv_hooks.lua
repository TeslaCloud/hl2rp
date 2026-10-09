--- Server hooks of the schema: pain, death and moaning sounds, the damage multipliers of hit
-- locations and weapons, and the Combine doors.
--
-- The damage handlers (`ScalePlayerDamage`, `ScaleNPCDamage`, `ScaleEntityDamage` and
-- `EntityTakeDamage`) change the damage in place and return nothing. Flux stops calling the
-- handlers of a hook at the first one that returns a value, and the schema is called after
-- every plugin and before the gamemode, so a value returned from here would keep the
-- gamemode from seeing the damage. The Damage and Limbs plugins hook the same events and
-- return nothing either, except that the Damage plugin blocks damage that a handler of its
-- PrePlayerTakeDamage hook has cancelled: their multipliers and those of the schema multiply,
-- and limb damage is worked out from the health a player has lost after all of them.

--- Plays a pain sound for the hurt player at most once a second, picked by faction, gender and hit limb.
-- @param victim [Player player that was hurt]
-- @param attacker [Entity entity that dealt the damage]
function SCHEMA:PlayerHurt(victim, attacker)
  if victim:Alive() then
    local cur_time = CurTime()

    if !victim.next_sound or victim.next_sound <= cur_time then
      local faction = victim:get_faction_id()

      if victim:is_human() then
        local limb = victim:LastHitGroup()
        local gender = victim:get_gender()
        local sound_path

        if math.random(1, 3) == 1 then
          if limb == HITGROUP_LEFTARM or limb == HITGROUP_RIGHTARM then
            sound_path = 'vo/npc/'..gender..'01/myarm0'..math.random(1, 2)..'.wav'
          elseif limb == HITGROUP_LEFTLEG or limb == HITGROUP_RIGHTLEG then
            sound_path = 'vo/npc/'..gender..'01/myleg0'..math.random(1, 2)..'.wav'
          elseif limb == HITGROUP_STOMACH or limb == HITGROUP_GEAR then
            sound_path = 'vo/npc/'..gender..'01/mygut0'..math.random(1, 2)..'.wav'
          end
        end

        if !sound_path then
          sound_path = 'vo/npc/'..gender..'01/pain0'..math.random(1, 9)..'.wav'
        end

        victim:EmitSound(sound_path)
      elseif faction == 'cca' then
        victim:EmitSound('npc/metropolice/pain'..math.random(1, 4)..'.wav')
      elseif faction == 'overwatch' then
        victim:EmitSound('npc/combine_soldier/pain'..math.random(1, 3)..'.wav')
      end

      victim.next_sound = cur_time + 1
    end
  end
end

--- Plays a death sound for dying CCA and Overwatch players.
-- @param victim [Player player that died]
-- @param inflictor [Entity entity that dealt the fatal damage]
-- @param attacker [Entity entity responsible for the death]
function SCHEMA:PlayerDeath(victim, inflictor, attacker)
  if victim:Alive() then
    local faction = victim:get_faction_id()

    if faction == 'cca' then
      victim:EmitSound('npc/metropolice/die'..math.random(1, 4)..'.wav')
    elseif faction == 'overwatch' then
      victim:EmitSound('npc/combine_soldier/die'..math.random(1, 3)..'.wav')
    end
  end
end

--- Doubles damage dealt to any limb other than the torso. The damage is scaled in place and
-- nothing is returned.
-- @param entity [Entity entity being damaged]
-- @param hitgroup [Number HITGROUP_ enum of the hit body part]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:ScaleEntityDamage(entity, hitgroup, damage_info)
  local limbgroup = self:hitgroup_to_limb(hitgroup)

  if limbgroup != LIMBGROUP_TORSO then
    damage_info:ScaleDamage(2)
  end
end

--- Scales damage dealt to players through the ScaleEntityDamage hook. Returns nothing, so
-- that the gamemode still applies its own multipliers afterward. The multipliers of the
-- Damage plugin and the hit location that the Damage and Limbs plugins remember have been
-- handled by then, as plugins are called before the schema.
-- @param victim [Player player being damaged]
-- @param hitgroup [Number HITGROUP_ enum of the hit body part]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:ScalePlayerDamage(victim, hitgroup, damage_info)
  --- Called on the server when a bullet or melee hit on a player or an NPC is scaled by hit
  -- location, from the schema's `ScalePlayerDamage` and `ScaleNPCDamage` handlers. Scale the
  -- damage in place; the return value is ignored, and a handler that returns one keeps the
  -- handlers after it from being called.
  -- @param entity [Entity The player or NPC that was hit]
  -- @param hitgroup [Number HITGROUP_ enum of the hit body part]
  -- @param damage_info [CTakeDamageInfo The damage being dealt]
  hook.Run('ScaleEntityDamage', victim, hitgroup, damage_info)
end

--- Scales damage dealt to NPCs through the ScaleEntityDamage hook. Returns nothing, so that
-- the gamemode still handles the hit afterward.
-- @param entity [NPC NPC being damaged]
-- @param hitgroup [Number HITGROUP_ enum of the hit body part]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:ScaleNPCDamage(entity, hitgroup, damage_info)
  hook.Run('ScaleEntityDamage', entity, hitgroup, damage_info)
end

local weapon_scales = {
  ['weapon_357'] = 0.67,
  ['weapon_ar2'] = 3.1,
  ['weapon_crowbar'] = 0.6,
  ['weapon_pistol'] = 2.1,
  ['weapon_shotgun'] = 3,
  ['weapon_smg1'] = 2.1,
  ['weapon_stunstick'] = 0.3
}

--- Scales damage dealt by players according to the weapon they are holding. The damage is
-- scaled in place and nothing is returned: a returned value would block the damage or keep
-- the gamemode from handling it. The schema is called after every plugin, so the
-- PrePlayerTakeDamage hook of the Damage plugin sees the damage before this multiplier, and
-- its PostPlayerTakeDamage hook and the Limbs plugin see what was dealt in the end. A plugin
-- that returns a value from its own handler keeps this one from being called.
-- @param entity [Entity entity being damaged]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:EntityTakeDamage(entity, damage_info)
  local attacker = damage_info:GetAttacker()

  if !IsValid(attacker) or !attacker:IsPlayer() then return end

  local attacker_weapon = attacker:GetActiveWeapon()

  if !IsValid(attacker_weapon) then return end

  local scale = weapon_scales[attacker_weapon:GetClass():lower()]

  if scale then
    damage_info:ScaleDamage(scale)
  end
end

--- Makes badly hurt human players moan, more often the lower their health is.
-- @param actor [Player player being checked]
function SCHEMA:PlayerOneSecond(actor)
  if actor:Alive() and actor:is_human() and actor:Health() < 50 then
    local cur_time = CurTime()

    if !actor.next_moan or actor.next_moan <= cur_time then
      actor:EmitSound('vo/npc/'..actor:get_gender()..'01/moan0'..math.random(1, 5)..'.wav')

      actor.next_moan = cur_time + math.max(actor:Health(), 15)
    end
  end
end

--- Opens combine doors for players carrying a CP card or a CP officer card. Other doors are
-- left to the Doors plugin, whichever card the player carries.
-- @param activator [Player player using the door]
-- @param entity [Entity door being used]
function SCHEMA:PlayerUseDoor(activator, entity)
  if !entity:is_combine_door() then return end

  if activator:has_item('card_cp') or activator:has_item('card_cp_officer') then
    entity:Fire('Open')
  end
end

--- Makes every combine door require the CP officer card to lock and unlock it, and saves the
-- doors. Runs once per map, when the Doors plugin finds no saved doors.
function SCHEMA:InitialDoorsLoad()
  for k, v in ents.Iterator() do
    if v:is_combine_door() then
      v.conditions = { {
        id = 'has_item',
        childs = {},
        data = {
          item_id  = 'card_cp_officer',
          operator = 'equal'
        }
      } }
    end
  end

  Doors:save()
end
