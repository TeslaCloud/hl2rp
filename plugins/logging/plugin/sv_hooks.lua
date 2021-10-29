local LOG_DAMAGE = {'[DAMAGE]', Color(255,0,0)}

function Logging:print_admin_log(type, text)
    Cable.send(nil, 'AdminLog', type, text)
    MsgC(type[2], type[1]..' ', Color(255,255,255), text..'\n')
end

-- Logs when damage is taken/given to another player.
hook.Add('PlayerHurt', 'Damage_Log', function(target, player, health, damage)
    local text = (target:GetName() .. ' has taken ' .. math.Round(damage) .. ' damage from ' .. player:GetName())
    Logging:print_admin_log(LOG_DAMAGE, text)
end)
