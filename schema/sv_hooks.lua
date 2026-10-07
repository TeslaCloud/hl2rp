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

--[[
  Head - x4
  Torso - x1
  Limbs - x0.5
--]]

function SCHEMA:ScaleEntityDamage(entity, hitgroup, damage_info)
  local limbgroup = self:hitgroup_to_limb(hitgroup)

  if limbgroup != LIMBGROUP_TORSO then
    damage_info:ScaleDamage(2)
  end
end

function SCHEMA:ScalePlayerDamage(victim, hitgroup, damage_info)
  hook.Run('ScaleEntityDamage', victim, hitgroup, damage_info)
end

function SCHEMA:ScaleNPCDamage(entity, hitgroup, damage_info)
  hook.Run('ScaleEntityDamage', entity, hitgroup, damage_info)
end

local weapon_scales = {
  ['weapon_357'] = 0.67, -- 50
  ['weapon_ar2'] = 3.1, -- 33
  ['weapon_crowbar'] = 0.6, -- 15
  ['weapon_pistol'] = 2.1, -- 25
  ['weapon_shotgun'] = 3, -- 84 (12x7)
  ['weapon_smg1'] = 2.1, -- 25
  ['weapon_stunstick'] = 0.3 -- 12
}

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

function SCHEMA:PlayerOneSecond(actor)
  if actor:Alive() and actor:is_human() and actor:Health() < 50 then
    local cur_time = CurTime()

    if !actor.next_moan or actor.next_moan <= cur_time then
      actor:EmitSound('vo/npc/'..actor:get_gender()..'01/moan0'..math.random(1, 5)..'.wav')

      actor.next_moan = cur_time + math.max(actor:Health(), 15)
    end
  end
end

function SCHEMA:PlayerUseDoor(activator, entity)
  if entity:is_combine_door() and activator:has_item('card_cp') or activator:has_item('card_cp_officer') then
    entity:Fire('Open')
  end
end

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
