local S = codeblock.S

-- Tools

minetest.register_tool("codeblock:drone_placer", {
    description = S("Drone Placer"),
    inventory_image = "drone_placer.png",
    range = 128,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        codeblock.events.handle_start_drone(user)
        return itemstack
    end,
    on_place = function(itemstack, placer, pointed_thing)
        codeblock.events.handle_place_drone(placer, pointed_thing)
        return itemstack
    end
})

minetest.register_tool("codeblock:drone_starter", {
    description = S("Drone Starter"),
    inventory_image = "drone_starter.png",
    range = 128,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        codeblock.events.handle_show_set_drone(user)
        return itemstack
    end,
    on_place = function(itemstack, placer, pointed_thing)
        -- codeblock.commands.remove_drone(user:get_player_name())
        return itemstack
    end
})

-- Entities

local DroneEntity = {
    initial_properties = {
        visual = "cube",
        visual_size = {x = 1.1, y = 1.1},
        textures = {
            "drone_top.png", "drone_side.png", "drone_side.png",
            "drone_side.png", "drone_side.png", "drone_side.png"
        },
        collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
        physical = false,
        static_save = false
    },
    on_rightclick = function(self, clicker) end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir) return {} end,
    on_blast = function(self, damage) return end,
    drone_owner = nil,
    nametag = '?'
}

function DroneEntity:set_drone_owner(name) self.drone_owner = name end

minetest.register_entity("codeblock:drone", DroneEntity)

minetest.register_on_joinplayer(function(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not minetest.mkdir(codeblock.datapath .. name) then
        minetest.chat_send_player(name, S('Cannot create @1', path))
    end

    player:get_meta():set_int('codeblock:last_index', 0)

end)

minetest.register_on_newplayer(function(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not minetest.mkdir(codeblock.datapath .. name) then
        minetest.chat_send_player(name, S('Cannot create @1', path))
    end

    for ename, content in pairs(codeblock.examples) do
        local file_path = path .. '/' .. ename .. '.lua'
        codeblock.filesystem.write(file_path, content)
    end

    player:get_meta():set_int('codeblock:last_index', 0)

end)

minetest.register_on_leaveplayer(function(player, timed_out)

    local name = player:get_player_name()
    codeblock.commands.remove_drone(name)

end)

-- Events

minetest.register_on_player_receive_fields(
    function(player, formname, fields)

        if formname == "codeblock:choose_file" then

            local name = player:get_player_name()
            local res = minetest.explode_textlist_event(fields.file)

            if res.type == "DCL" then

                minetest.close_formspec(name, 'codeblock:choose_file')
                codeblock.commands.set_drone_file_from_index(name, res.index)

            end

        end

    end)
