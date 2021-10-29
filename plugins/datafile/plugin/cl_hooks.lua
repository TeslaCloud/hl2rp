function Datafile:AddTabMenuItems(menu)
  menu:add_menu_item('datafile', {
    title = t'ui.datafile.title',
    panel = 'fl_datafile_panel',
    icon = 'fa-database',
    priority = 35
  })
end
