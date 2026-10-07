--- Registers the stats character creation panel with the theme.
-- @param current_theme [Theme theme that was loaded]
function Stats:OnThemeLoaded(current_theme)
  current_theme:add_panel('ui.char_create.stats', function(id, parent, ...)
    return vgui.Create('fl_character_creation_stats', parent)
  end)
end

--- Adds the stats stage to character creation.
-- @param panel [Panel character creation menu]
function Stats:AddCharacterCreationMenuStages(panel)
  panel:add_stage('ui.char_create.stats')
end

--- Returns the error text for characters whose attribute points do not add up.
-- @param success [Boolean whether the character was created]
-- @param status [Number CHAR_ERR_ status code]
-- @return [String error text, nil for other statuses]
function Stats:GetCharCreationErrorText(success, status)
  if status == CHAR_ERR_ATTRIBUTE_SUM then
    return t'error.attribute.sum'
  end
end
