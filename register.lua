
local S = default.get_translator

minetest.register_tool("codeblock:drone_placer", {
    description = S("Drone Placer"),
    inventory_image = "default_tool_woodpick.png",
    range = 10,
    stack_max = 1,
    on_use = function()
        -- if node is a drone, remove it
        return
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local pos = minetest.get_pointed_thing_position(pointed_thing)
        local name = placer:get_player_name()
        minetest.chat_send_player(name, S("@1 placing a drone at @2", name, minetest.pos_to_string(pos))) 
        local dr1 = codeblock.drone:new({x=pos.x, y=pos.y, z=pos.z})
    end
})
   
minetest.register_node("codeblock:drone", {
    drawtype = "nodebox",
    description = S("Drone"),
    tiles = {
		"drone_top.png",
		"drone_bottom.png",
		"drone_right.png",
		"drone_left.png",
		"drone_back.png",
		"drone_front.png"
	},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.43, -0.37, -0.43, 0.43, 0.4375, 0.43},
            {-0.3125, -0.42, -0.3125, 0.3125, -0.3, 0.3125},
            {-0.3125, 0.0625, 0.375, 0.3125, 0.375, 0.5},
        }
    }
})