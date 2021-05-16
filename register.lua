local S = default.get_translator

-- Drone Placer

minetest.register_tool("codeblock:drone_placer", {
    description = S("Drone Placer"),
    inventory_image = "drone_placer.png",
    range = 32,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        -- 
    end,
    on_place = function(itemstack, placer, pointed_thing)
        codeblock.events.handle_place_drone(placer, pointed_thing)
        return itemstack
    end
})

minetest.register_tool("codeblock:drone_starter", {
    description = S("Drone Starter"),
    inventory_image = "drone_starter.png",
    range = 0,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        codeblock.events.handle_start_drone(user)
    end,
    on_place = function(itemstack, placer, pointed_thing)
        --
        return itemstack
    end
})

-- Drone Entity

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
    on_rightclick = function(self, clicker)
        -- codeblock.events.handle_start_drone(self.drone_owner, clicker)
        -- TODO set code
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir) return {} end,
    on_blast = function(self, damage) return false, false, {} end,
    drone_owner = nil
}

function DroneEntity:set_drone_owner(name) self.drone_owner = name end

minetest.register_entity("codeblock:drone", DroneEntity)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    -- il_editor:create_player(name) -- 
end)
