codeblock = {}
codeblock.modpath = minetest.get_modpath("codeblock")

-- load turtle resources
dofile(codeblock.modpath.."/t_api.lua") -- load turtle api
dofile(codeblock.modpath.."/turtles.lua") -- turtle register
