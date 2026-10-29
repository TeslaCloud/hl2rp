--- Server hooks of the schema: pain, death and moaning sounds, the Combine doors, and the
-- name Overwatch soldiers are shown under in the local OOC chat.
--
-- The schema does not scale damage itself. The damage of a hit is rolled by the D20 plugin
-- from the dice of the weapon or of the attacker, and the hit location multipliers of players
-- and NPCs are the `damage_scale_*` configs of the Damage plugin, which hl2rp.yml sets to
-- double the damage of the head, the arms and the legs, for NPCs too (`damage_scale_npcs`).
-- The D20 plugin applies the multipliers to the rolled damage again. Limb damage is worked
-- out from the health a player has lost after every multiplier.

local random = math.random

--- Plays a pain sound for the hurt player at most once a second, picked by faction, gender and hit limb.
-- @param victim [Player player that was hurt]
-- @param _attacker [Entity entity that dealt the damage]
function SCHEMA:PlayerHurt(victim, _attacker)
  if victim:Alive() then
    local cur_time = CurTime()

    if !victim.next_sound or victim.next_sound <= cur_time then
      local faction = victim:get_faction_id()

      if victim:is_human() then
        local limb = victim:LastHitGroup()
        local gender = victim:get_gender()
        local sound_path

        if random(1, 3) == 1 then
          if limb == HITGROUP_LEFTARM or limb == HITGROUP_RIGHTARM then
            sound_path = 'vo/npc/'..gender..'01/myarm0'..random(1, 2)..'.wav'
          elseif limb == HITGROUP_LEFTLEG or limb == HITGROUP_RIGHTLEG then
            sound_path = 'vo/npc/'..gender..'01/myleg0'..random(1, 2)..'.wav'
          elseif limb == HITGROUP_STOMACH or limb == HITGROUP_GEAR then
            sound_path = 'vo/npc/'..gender..'01/mygut0'..random(1, 2)..'.wav'
          end
        end

        if !sound_path then
          sound_path = 'vo/npc/'..gender..'01/pain0'..random(1, 9)..'.wav'
        end

        victim:EmitSound(sound_path)
      elseif faction == 'cca' then
        victim:EmitSound('npc/metropolice/pain'..random(1, 4)..'.wav')
      elseif faction == 'overwatch' then
        victim:EmitSound('npc/combine_soldier/pain'..random(1, 3)..'.wav')
      end

      victim.next_sound = cur_time + 1
    end
  end
end

--- Plays a death sound for dying CCA and Overwatch players.
-- @param victim [Player player that died]
-- @param _inflictor [Entity entity that dealt the fatal damage]
-- @param _attacker [Entity entity responsible for the death]
function SCHEMA:PlayerDeath(victim, _inflictor, _attacker)
  local faction = victim:get_faction_id()

  if faction == 'cca' then
    victim:EmitSound('npc/metropolice/die'..random(1, 4)..'.wav')
  elseif faction == 'overwatch' then
    victim:EmitSound('npc/combine_soldier/die'..random(1, 3)..'.wav')
  end
end

--- Shows the members of the Overwatch faction as 'Overwatch Soldier' in the local OOC chat,
-- so that the line does not give away which soldier wrote it.
-- @param actor [Player player who writes]
-- @return [String 'Overwatch Soldier' for the Overwatch faction, nil for everyone else]
function SCHEMA:GetPlayerOOCName(actor)
  if actor:get_faction_id() == 'overwatch' then
    return 'Overwatch Soldier'
  end
end

--- Makes badly hurt human players moan, more often the lower their health is.
-- @param actor [Player player being checked]
function SCHEMA:PlayerOneSecond(actor)
  if !actor:Alive() or !actor:is_human() then return end

  local health = actor:Health()

  if health < 50 then
    local cur_time = CurTime()

    if !actor.next_moan or actor.next_moan <= cur_time then
      actor:EmitSound('vo/npc/'..actor:get_gender()..'01/moan0'..random(1, 5)..'.wav')

      actor.next_moan = cur_time + math.max(health, 15)
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
  for _k, v in ents.Iterator() do
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
