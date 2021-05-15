codeblock.events = {}
local S = default.get_translator

--
-- FUNCTIONS
--

function codeblock.handle_update_drone_entity(drone)
    local name = drone.name
    local drone_entity = codeblock.drone_entities[name]

    if not drone_entity or not drone then error(S("drone does not exist")) end

    drone_entity:move_to({x = drone.x, y = drone.y, z = drone.z})
    drone_entity:set_rotation({x = 0, y = drone.dir, z = 0})

end

function codeblock.handle_start_drone(drone_luaentity, clicker)
    local name_clicker = clicker:get_player_name()
    local name = drone_luaentity.drone_owner
    if name_clicker ~= name then
        minetest.chat_send_player(name_clicker, S("not your drone"))
        return {}
    end

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    minetest.chat_send_player(name,
                              S("Starting drone @1/@2", drone.name, drone.file))
    codeblock.commands.test_sequence(name)

end

function codeblock.handle_place_drone(itemstack, placer, pointed_thing)
    local pos = minetest.get_pointed_thing_position(pointed_thing)
    local dir = math.floor((placer:get_look_horizontal() + math.pi / 4) /
                               math.pi * 2) * math.pi / 2
    local name = placer:get_player_name()
    local code = nil -- TODO

    if not pos then
        minetest.chat_send_player(name, S("Please target node"))
        return {}
    end

    local drone = codeblock.commands.add_drone(pos, dir, name, code)
    minetest.chat_send_player(name, S("@1 placing a drone at @2", name,
                                      minetest.pos_to_string(pos)))

end

--
-- REGISTER
--

minetest.register_tool("codeblock:drone_placer", {
    description = S("Drone Placer"),
    inventory_image = "default_tool_woodpick.png",
    range = 10,
    stack_max = 1,
    on_use = function(itemstack, placer, pointed_thing)
        -- if pointed_thing is a drone, remove it
    end,
    on_place = function(itemstack, placer, pointed_thing)
        codeblock.handle_place_drone(itemstack, placer, pointed_thing)
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
        codeblock.handle_start_drone(self, clicker)
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

