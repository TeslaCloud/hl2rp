--- Adds the Datafile entry to the tab menu.
-- @param menu [Panel tab menu]
function DataFile:AddTabMenuItems(menu)
  menu:add_menu_item('data_file', {
    title = t'ui.data_file.title',
    panel = 'fl_data_file_panel',
    icon = 'fa-database',
    priority = 35
  })
end
