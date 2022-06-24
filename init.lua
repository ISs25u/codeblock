codeblock = {
    modpath = minetest.get_modpath('codeblock'),
    is_vector3_enabled = (minetest.get_modpath('vector3') ~= nil),
    is_worldedit_enabled = (minetest.get_modpath('worldedit') ~= nil),
    is_wool_enabled = (minetest.get_modpath('wool') ~= nil)
}

dofile(codeblock.modpath .. "/lib/intl.lua")
dofile(codeblock.modpath .. "/lib/config.lua")
dofile(codeblock.modpath .. "/lib/utils.lua")
dofile(codeblock.modpath .. "/lib/pathjoin.lua")
dofile(codeblock.modpath .. "/lib/filesystem.lua")
dofile(codeblock.modpath .. "/lib/examples.lua")
--
codeblock.examples.load_examples() -- read at init time
--
dofile(codeblock.modpath .. "/lib/commands.lua")
dofile(codeblock.modpath .. "/lib/sandbox.lua")
dofile(codeblock.modpath .. "/lib/drone.lua")
dofile(codeblock.modpath .. "/lib/drone_entity.lua")
dofile(codeblock.modpath .. "/lib/formspecs.lua")
dofile(codeblock.modpath .. "/lib/register.lua")

if not minetest.mkdir(codeblock.filesystem.data_path) then
    error("[editor] failed to create directory!")
end
