--- Puts the player in control of a scanner they spawn.
-- @param actor [Player player that spawned the NPC]
-- @param entity [NPC spawned NPC]
function Scanners:PlayerSpawnedNPC(actor, entity)
  if entity:GetClass() == 'npc_cscanner' then
    actor:control_scanner(entity)
  end
end

local light_mat = Material('effects/flashlight001')

--- Handles scanner controls: mouse 1 takes a photo, F toggles the spotlight and E exits the scanner.
-- @param actor [Player player that pressed the button]
-- @param button [Number BUTTON_CODE of the pressed button]
function Scanners:PlayerButtonDown(actor, button)
  if actor:controls_scanner() then
    local cur_time = CurTime()
    local scanner = actor:get_scanner()
    local marker = scanner.marker

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
function Scanners:PlayerOneSecond(actor)
  if actor:controls_scanner() then
    local scanner = actor:get_scanner()

    scanner:Fire('SetFollowTarget', scanner.target_name)
  end
end

--- Moves the scanner's marker according to the player's movement and mouse input and blocks their own movement.
-- @param actor [Player player controlling the scanner]
-- @param cmd [CUserCmd command being processed]
function Scanners:StartCommand(actor, cmd)
  if actor:controls_scanner() then
    local scanner = actor:get_scanner()
    local marker = scanner.marker

    if IsValid(scanner) and IsValid(marker) then
      if cmd:KeyDown(IN_JUMP) then
        cmd:SetUpMove(10000)
      elseif cmd:KeyDown(IN_DUCK) then
        cmd:SetUpMove(-10000)
      end

      local scanner_forward = scanner:GetForward()
      local scanner_up = scanner:GetUp()
      local pos = scanner:GetPos() + scanner_up * -67 + scanner_forward * 64
      local speed = 0.0064
      local forward = scanner_forward * cmd:GetForwardMove() * speed
      local right = scanner:GetRight() * cmd:GetSideMove() * speed
      local up = scanner_up * cmd:GetUpMove() * speed
      local aim =
        util.AimVector(scanner:GetAimVector():Angle(), actor:GetFOV(), cmd:GetMouseX(), cmd:GetMouseY(), 0, 0) * 32

      aim = aim + forward + right + up

      marker:SetPos(pos + aim)
    end

    cmd:ClearMovement()
    cmd:ClearButtons()
  end
end
