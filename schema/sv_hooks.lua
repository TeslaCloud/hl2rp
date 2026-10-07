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
-- @param attacker [Entity entity responsible for the death]
function SCHEMA:PlayerDeath(victim, attacker)
  if victim:Alive() then
    local faction = victim:get_faction_id()

    if faction == 'cca' then
      victim:EmitSound('npc/metropolice/die'..math.random(1, 4)..'.wav')
    elseif faction == 'overwatch' then
      victim:EmitSound('npc/combine_soldier/die'..math.random(1, 3)..'.wav')
    end
  end
end

--- Doubles damage dealt to any limb other than the torso.
-- @param entity [Entity entity being damaged]
-- @param hitgroup [Number HITGROUP_ enum of the hit body part]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:ScaleEntityDamage(entity, hitgroup, damage_info)
  local limbgroup = self:hitgroup_to_limb(hitgroup)

  if limbgroup != LIMBGROUP_TORSO then
    damage_info:ScaleDamage(2)
  end
end

--- Scales damage dealt to players through the ScaleEntityDamage hook.
-- @param victim [Player player being damaged]
-- @param hitgroup [Number HITGROUP_ enum of the hit body part]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:ScalePlayerDamage(victim, hitgroup, damage_info)
  hook.Run('ScaleEntityDamage', victim, hitgroup, damage_info)
end

--- Scales damage dealt to NPCs through the ScaleEntityDamage hook.
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

--- Scales damage dealt by players according to the weapon they are holding.
-- @param entity [Entity entity being damaged]
-- @param damage_info [CTakeDamageInfo damage being dealt]
function SCHEMA:EntityTakeDamage(entity, damage_info)
  local attacker = damage_info:GetAttacker()

  if IsValid(attacker) and attacker:IsPlayer() then
    local attacker_weapon = attacker:GetActiveWeapon()

    if IsValid(attacker_weapon) then
      local weapon_class = attacker_weapon:GetClass():lower()

      if attacker:IsPlayer() then
        local scale = weapon_scales[weapon_class] or 1

        damage_info:ScaleDamage(scale)
      end
    end
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

--- Opens combine doors for players carrying a CP card.
-- @param activator [Player player using the door]
-- @param entity [Entity door being used]
function SCHEMA:PlayerUseDoor(activator, entity)
  if entity:is_combine_door() and activator:has_item('card_cp') or activator:has_item('card_cp_officer') then
    entity:Fire('Open')
  end
end

--- Makes every combine door require the CP officer card and saves the doors.
function SCHEMA:InitialDoorsLoad()
  for k, v in ipairs(ents.GetAll()) do
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
