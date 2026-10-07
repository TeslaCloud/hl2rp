local LOG_DAMAGE = { '[DAMAGE]', Color(255, 0, 0) }

--- Sends a log line to admins and prints it to the server console with its tag color.
-- @param type [Table log type with the tag text at index 1 and its Color at index 2]
-- @param text [String log message]
function Logging:print_admin_log(type, text)
  Cable.send(nil, 'AdminLog', type, text)
  MsgC(type[2], type[1]..' ', Color(255, 255, 255), text..'\n')
end

hook.Add('PlayerHurt', 'Damage_Log', function(target, attacker, health, damage)
  local text = (target:GetName()..' has taken '..math.Round(damage)..' damage from '..attacker:GetName())
  Logging:print_admin_log(LOG_DAMAGE, text)
end)
