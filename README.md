# Flux Half-Life 2 Roleplay

# Installation
Put this repository into `garrysmod/gamemodes` of the server, in a folder named `hl2rp`, run
`fpkg install` anywhere in the server folder to install Flux and the other packages of the schema
into its `packages` folder, and start the server with `+gamemode hl2rp`. The configuration of the
server goes into `gamemodes/hl2rp/config/`.

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
