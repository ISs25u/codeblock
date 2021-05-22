codeblock = {}

codeblock.modpath = minetest.get_modpath("codeblock")
codeblock.datapath = minetest.get_worldpath() .. "/codeblock_lua_files/"

if not minetest.mkdir(codeblock.datapath) then
    error("[editor] failed to create directory!")
end

codeblock.drones = {}
codeblock.drone_entities = {}
codeblock.S = minetest.get_translator("codeblock")

dofile(codeblock.modpath .. "/register.lua")
dofile(codeblock.modpath .. "/drone.lua")
dofile(codeblock.modpath .. "/events.lua")
dofile(codeblock.modpath .. "/commands.lua")
dofile(codeblock.modpath .. "/sandbox.lua")
dofile(codeblock.modpath .. "/formspecs.lua")
dofile(codeblock.modpath .. "/filesystem.lua")
dofile(codeblock.modpath .. "/examples.lua")