Cable.receive('fl_voice_line_say', function(actor, category_id, line_id)
  VoiceLines:say(actor, category_id, line_id)
end)
