function Stats:OnThemeLoaded(current_theme)
  current_theme:add_panel('ui.char_create.stats', function(id, parent, ...)
    return vgui.Create('fl_character_creation_stats', parent)
  end)
end

function Stats:AddCharacterCreationMenuStages(panel)
  panel:add_stage('ui.char_create.stats')
end

function Stats:GetCharCreationErrorText(success, status)
  if status == CHAR_ERR_ATTRIBUTE_SUM then
    return t'error.attribute.sum'
  end
end
