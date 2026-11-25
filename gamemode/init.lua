--- Server entry point of the gamemode.
-- Sends the client entry point to clients and boots Flux from the `flux` package in the
-- `packages` folder of the gamemode. When Flux is not installed there, or the server runs the
-- stock Lua library, which cannot run Flux, it says so in the console and boots nothing. The
-- file is written in the syntax the stock library reads, so that it can tell.

resource.AddWorkshop('1657745375')
resource.AddWorkshop('1867886909')
resource.AddWorkshop('1867887605')

AddCSLuaFile 'cl_init.lua'

local schema = engine.ActiveGamemode()
local boot_file = schema..'/packages/flux/boot.lua'

if !file.Exists(boot_file, 'LUA') then
  ErrorNoHalt('Flux is not installed: gamemodes/'..boot_file..' is missing. Run `fpkg install` in '..
    'garrysmod/gamemodes/'..schema..' to install it.\n')

  return
end

if !isfunction(CompileString('local a = 0 a += 1', 'flux_vm_check', false)) then
  ErrorNoHalt('This server runs the stock lua_shared library, and Flux needs its own build of it. The readme '..
    'of the flux package, gamemodes/'..schema..'/packages/flux/readme.md, says where to get it.\n')

  return
end

include(boot_file)
