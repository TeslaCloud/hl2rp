# Flux Half-Life 2 Roleplay

# Installation

A server needs, in this order:

1. The `x86-64` branch of the Garry's Mod dedicated server:
   `steamcmd +login anonymous +force_install_dir ./flux_server +app_update 4020 -beta x86-64 validate +quit`.
2. Flux's build of the server's Lua library in place of the stock one: on Linux, replace
   `bin/linux64/lua_shared.so` of the server with https://data.nighty.cloud/gmod/lua_shared.so,
   as the readme of the `flux` package says. With the stock library the server only prints that
   Flux needs its build of `lua_shared`.
3. This repository in `garrysmod/gamemodes/hl2rp`, and the packages of the schema, which
   [fpkg](https://github.com/TeslaCloud/fpkg) installs from inside that folder:

   ```sh
   cd flux_server/garrysmod/gamemodes
   git clone https://github.com/TeslaCloud/hl2rp.git
   cd hl2rp
   fpkg install
   ```

   This puts Flux and the other packages into `packages/`, their content into `content/` and the
   `file` binary module into `garrysmod/lua/bin`. Until it has run, the server only prints that
   Flux is not installed.
4. The content of the schema mounted on the server. Its models and materials are in the Workshop
   items 1657745375, 1867886909 and 1867887605. `gamemode/init.lua` makes clients download them,
   but the server has to mount them itself: put them into a Workshop collection and start the
   server with `+host_workshop_collection <id of the collection>`.
5. The configuration, in `gamemodes/hl2rp/config/`. Copy the file you want to change from
   `packages/flux/config/` (`settings.yml`, `database.yml`, `profiles.yml` or `environment.lua`)
   into it and change the copy, which is read in place of the original. A `<name>.local.yml` next
   to it, such as `database.local.yml`, wins over both. Never edit the files in `packages`: fpkg
   verifies them and replaces them on the next install.

Then start the server with `+gamemode hl2rp`, for example
`./srcds_run_x64 +gamemode hl2rp +map gm_construct +host_workshop_collection <id of the collection>`.

For development, run `fpkg link ../flux-ce` in this checkout to use a checkout of Flux instead of
the published package, then `fpkg install` for the rest of the packages. To run the schema in a
container, see the "Docker (development)" section of the Flux readme.

Binary modules: `gmsv_file` is installed as a dependency of `flux`. A PostgreSQL server
uncomments `s.depends 'gmsv_pg'` in `packagespec.lua` and runs `fpkg install`. MySQL and MariaDB
need mysqloo, which you copy into `garrysmod/lua/bin` by hand from
https://github.com/TeslaCloud/flux-dependencies.

For other documentation please refer [to the main Flux repository](https://github.com/TeslaCloud/flux-ce).

# Credits
- Luna Fox (Lead Developer)
- AleXXX_007 (Co-lead developer)
- Other former members of TeslaCloud Studios (Zig, NightAngel, and others)
