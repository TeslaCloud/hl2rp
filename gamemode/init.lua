--- Server entry point of the gamemode.
-- Adds the Workshop addons of the schema's content, sends the client entry point to clients
-- and boots Flux from the `flux` package in the `packages` folder of the gamemode.

resource.AddWorkshop('1657745375')
resource.AddWorkshop('1867886909')
resource.AddWorkshop('1867887605')

AddCSLuaFile 'cl_init.lua'

include(engine.ActiveGamemode()..'/packages/flux/boot.lua')
