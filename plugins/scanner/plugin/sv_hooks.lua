--- Server-side hooks of the Scanner plugin: taking control of a spawned scanner, leaving it on
-- death or disconnect, its controls, and steering it.

--- Puts the player in control of a scanner they spawn.
-- @param actor [Player player that spawned the NPC]
-- @param entity [NPC spawned NPC]
function Scanner:PlayerSpawnedNPC(actor, entity)
  if entity:GetClass() == 'npc_cscanner' then
    actor:control_scanner(entity)
  end
end

--- Takes a player who dies while piloting a scanner out of it. The weapons stored when they
-- took control are dropped, since they respawn with their loadout.
-- @param victim [Player player that died]
-- @param _inflictor [Entity]
-- @param _attacker [Entity]
function Scanner:PlayerDeath(victim, _inflictor, _attacker)
  if victim:controls_scanner() then
    victim.weapons = nil
    victim:exit_scanner()
  end
end

--- Releases the scanner of a player who disconnects while piloting it.
-- @param actor [Player player that is disconnecting]
function Scanner:PlayerDisconnected(actor)
  if actor:controls_scanner() then
    actor.weapons = nil
    actor:exit_scanner()
  end
end

local light_mat = Material('effects/flashlight001')

--- Handles scanner controls: mouse 1 takes a photo, F toggles the spotlight and E exits the scanner.
-- @param actor [Player player that pressed the button]
-- @param button [Number BUTTON_CODE of the pressed button]
function Scanner:PlayerButtonDown(actor, button)
  if actor:controls_scanner() then
    local cur_time = CurTime()
    local scanner = actor:get_scanner()

    if button == MOUSE_FIRST and (!scanner.next_flash or scanner.next_flash < cur_time) then
      scanner:EmitSound('npc/scanner/scanner_photo1.wav')
      Cable.send(nil, 'fl_scanner_flash', scanner)
      scanner.next_flash = cur_time + 1
    end

    if button == KEY_F and (!scanner.next_switch or scanner.next_switch < cur_time) then
      if scanner.flashlight then
        scanner.flashlight:Remove()
        scanner.flashlight = nil

        scanner:EmitSound('buttons/combine_button2.wav')

        scanner.next_switch = cur_time + 1
      else
        local att = scanner:GetAttachment(1)

        if !att then return end

        local pos, ang = WorldToLocal(att.Pos, att.Ang, scanner:GetPos(), scanner:GetAngles())

        scanner.flashlight = ents.Create('env_projectedtexture')
        scanner.flashlight:SetParent(scanner)
        scanner.flashlight:SetLocalPos(pos)
        scanner.flashlight:SetLocalAngles(ang)
        scanner.flashlight:SetKeyValue('enableshadows', 1)
        scanner.flashlight:SetKeyValue('nearz', 1)
        scanner.flashlight:SetKeyValue('lightfov', 75)
        scanner.flashlight:SetKeyValue('farz', 512)
        scanner.flashlight:SetKeyValue('lightcolor', '255 240 210 255')
        scanner.flashlight:Spawn()
        scanner.flashlight:Input('SpotlightTexture', NULL, NULL, light_mat:GetString('$basetexture'))

        scanner:EmitSound('buttons/button1.wav')

        scanner.next_switch = cur_time + 1
      end
    end

    if button == KEY_E then
      actor:exit_scanner()
    end
  end
end

--- Keeps a controlled scanner following its marker.
-- @param actor [Player player being checked]
function Scanner:PlayerOneSecond(actor)
  if actor:controls_scanner() then
    local scanner = actor:get_scanner()

    scanner:Fire('SetFollowTarget', scanner.target_name)
  end
end

const mouse_sensitivity = 0.022

--- Moves the scanner's marker according to the player's movement and mouse input and blocks
-- their own movement. The mouse deltas of every command turn the aim angle kept on the
-- scanner, by 0.022 degrees per unit as the view of a player turns, and the marker is placed
-- ahead of the scanner in the direction of that angle.
-- @param actor [Player player controlling the scanner]
-- @param cmd [CUserCmd command being processed]
function Scanner:StartCommand(actor, cmd)
  if actor:controls_scanner() then
    local scanner = actor:get_scanner()
    local marker = scanner.marker
    local aim_angle = scanner.aim_angle

    if IsValid(scanner) and IsValid(marker) and aim_angle then
      if cmd:KeyDown(IN_JUMP) then
        cmd:SetUpMove(10_000)
      elseif cmd:KeyDown(IN_DUCK) then
        cmd:SetUpMove(-10_000)
      end

      local scanner_forward = scanner:GetForward()
      local scanner_up = scanner:GetUp()
      local pos = scanner:GetPos() + scanner_up * -67 + scanner_forward * 64
      local speed = 0.0064
      local forward = scanner_forward * cmd:GetForwardMove() * speed
      local right = scanner:GetRight() * cmd:GetSideMove() * speed
      local up = scanner_up * cmd:GetUpMove() * speed

      aim_angle.y -= cmd:GetMouseX() * mouse_sensitivity
      aim_angle.p = math.Clamp(aim_angle.p + cmd:GetMouseY() * mouse_sensitivity, -89, 89)
      aim_angle:Normalize()

      local aim = aim_angle:Forward() * 32 + forward + right + up

      marker:SetPos(pos + aim)
    end

    cmd:ClearMovement()
    cmd:ClearButtons()
  end
end
