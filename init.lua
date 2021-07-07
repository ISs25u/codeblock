codeblock = {}

codeblock.modpath = minetest.get_modpath("codeblock")
codeblock.datapath = minetest.get_worldpath() .. "/codeblock_lua_files/"

if not minetest.mkdir(codeblock.datapath) then
    error("[editor] failed to create directory!")
end

codeblock.drones = {}
codeblock.drone_entities = {}
codeblock.max_calls = 1e7
codeblock.max_volume = 1e7
codeblock.max_commands = 1e6
codeblock.max_place_value = 300 * 300
codeblock.S = minetest.get_translator("codeblock")

dofile(codeblock.modpath .. "/utils.lua")
dofile(codeblock.modpath .. "/drone.lua")
dofile(codeblock.modpath .. "/drone_entity.lua")
dofile(codeblock.modpath .. "/register.lua")
dofile(codeblock.modpath .. "/commands.lua")
dofile(codeblock.modpath .. "/sandbox.lua")
dofile(codeblock.modpath .. "/formspecs.lua")
dofile(codeblock.modpath .. "/filesystem.lua")
dofile(codeblock.modpath .. "/examples.lua")
