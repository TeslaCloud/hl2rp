Cable.receive('fl_get_radio_frequency', function(instance_id, frequency)
  Derma_StringRequest(t'ui.radio.frequency', t'ui.radio.frequency_message', frequency, 
  function(text)
    local number = tonumber(text)

    if number and string.find(text, '^%d%d%d.%d$') then
      Cable.send('fl_set_radio_frequency', instance_id, frequency)
    else
      PLAYER:notify('error.frequency')
    end
  end, nil, t'ui.radio.set', t'ui.cancel')
end)
