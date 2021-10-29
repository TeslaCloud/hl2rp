function Scanners:PlayerSpawnedNPC(player, entity)
  if entity:GetClass() == 'npc_cscanner' then
    player:control_scanner(entity)
  end
end

local light_mat = Material('effects/flashlight001')

function Scanners:PlayerButtonDown(player, button)
  if player:controls_scanner() then
    local cur_time = CurTime()
    local scanner = player:get_scanner()
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

        scanner.flashlight = ents.create('env_projectedtexture')
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
      player:exit_scanner()
    end
  end
end

function Scanners:PlayerOneSecond(player)
  if player:controls_scanner() then
    local scanner = player:get_scanner()

    scanner:Fire('SetFollowTarget', scanner.target_name)
  end
end

function Scanners:StartCommand(player, cmd)
  if player:controls_scanner() then
    local scanner = player:get_scanner()
    local marker = scanner.marker

    if IsValid(scanner) and IsValid(marker) then
      if cmd:KeyDown(IN_JUMP) then
        cmd:SetUpMove(10000)
      elseif cmd:KeyDown(IN_DUCK) then
        cmd:SetUpMove(-10000)
      end

      local pos = scanner:GetPos() + scanner:GetUp() * -67 + scanner:GetForward() * 64
      local speed = 0.0064
      local forward = scanner:GetForward() * cmd:GetForwardMove() * speed
      local right = scanner:GetRight() * cmd:GetSideMove() * speed
      local up = scanner:GetUp() * cmd:GetUpMove() * speed
      local aim = util.AimVector(scanner:GetAimVector():Angle(), player:GetFOV(), cmd:GetMouseX(), cmd:GetMouseY(), 0, 0) * 32

      aim = aim + forward + right + up

      marker:SetPos(pos + aim)
    end

    cmd:ClearMovement()
    cmd:ClearButtons()
  end
end
