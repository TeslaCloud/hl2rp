function SCHEMA:ShouldOpenWepselect(player, bind, pressed)
  if bind and bind:find('slot') and pressed and !player:KeyDown(IN_WALK) then
    return false
  end
end


do
  local default_npcs = {
    ['npc_crow'] = 'npc.hl2.crow',
    ['npc_monk'] = 'npc.hl2.monk',
    ['npc_pigeon'] = 'npc.hl2.pigeon',
    ['npc_seagull'] = 'npc.hl2.seagull',
    ['npc_combine_camera'] = 'npc.hl2.combine_camera',
    ['npc_turret_ceiling'] = 'npc.hl2.turret_ceiling',
    ['npc_cscanner'] = 'npc.hl2.cscanner',
    ['npc_combinedropship'] = 'npc.hl2.combine_dropship',
    ['combineelite'] = 'npc.hl2.combine_elite',
    ['npc_combinegunship'] = 'npc.hl2.combine_gunship',
    ['npc_combine_s'] = 'npc.hl2.combine_soldier',
    ['npc_hunter'] = 'npc.hl2.hunter',
    ['npc_helicopter'] = 'npc.hl2.helicopter',
    ['npc_manhack'] = 'npc.hl2.manhack',
    ['npc_metropolice'] = 'npc.hl2.metropolice',
    ['combineprison'] = 'npc.hl2.prison_guard',
    ['prisonshotgunner'] = 'npc.hl2.prison_shotgunner',
    ['npc_rollermine'] = 'npc.hl2.rollermine',
    ['npc_clawscanner'] = 'npc.hl2.clawscanner',
    ['shotgunsoldier'] = 'npc.hl2.shotgun_soldier',
    ['npc_stalker'] = 'npc.hl2.stalker',
    ['npc_strider'] = 'npc.hl2.strider',
    ['npc_turret_floor'] = 'npc.hl2.turret_floor',
    ['npc_alyx'] = 'npc.hl2.alyx',
    ['npc_barney'] = 'npc.hl2.barney',
    ['npc_citizen'] = 'npc.hl2.citizen',
    ['npc_dog'] = 'npc.hl2.dog',
    ['npc_magnusson'] = 'npc.hl2.magnusson',
    ['npc_kleiner'] = 'npc.hl2.kleiner',
    ['npc_mossman'] = 'npc.hl2.mossman',
    ['npc_eli'] = 'npc.hl2.eli',
    ['npc_gman'] = 'npc.hl2.gman',
    ['medic'] = 'npc.hl2.medic',
    ['npc_odessa'] = 'npc.hl2.odessa',
    ['rebel'] = 'npc.hl2.rebel',
    ['refugee'] = 'npc.hl2.refugee',
    ['vortigaunturiah'] = 'npc.hl2.vortigaunturiah',
    ['npc_vortigaunt'] = 'npc.hl2.vortigaunt',
    ['vortigauntslave'] = 'npc.hl2.vortigauntslave',
    ['npc_breen'] = 'npc.hl2.breen',
    ['npc_antlion'] = 'npc.hl2.antlion',
    ['npc_antlion_grub'] = 'npc.hl2.antlion_grub',
    ['npc_antlionguard'] = 'npc.hl2.antlionguard',
    ['npc_antlionguardian'] = 'npc.hl2.antlionguardian',
    ['npc_antlion_worker'] = 'npc.hl2.antlion_worker',
    ['npc_barnacle'] = 'npc.hl2.barnacle',
    ['npc_headcrab_fast'] = 'npc.hl2.headcrab_fast',
    ['npc_fastzombie'] = 'npc.hl2.fastzombie',
    ['npc_fastzombie_torso'] = 'npc.hl2.fastzombie_torso',
    ['npc_headcrab'] = 'npc.hl2.headcrab',
    ['npc_headcrab_black'] = 'npc.hl2.headcrab_black',
    ['npc_poisonzombie'] = 'npc.hl2.poisonzombie',
    ['npc_zombie'] = 'npc.hl2.zombie',
    ['npc_zombie_torso'] = 'npc.hl2.zombie_torso',
    ['npc_zombine'] = 'npc.hl2.zombine'
  }

  function SCHEMA:GetEntityName(entity)
    local class = entity:GetClass():lower()
    local name = default_npcs[class]

    if name then
      return t(name)
    end
  end
end
