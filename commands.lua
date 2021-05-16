codeblock.commands = {}

local S = default.get_translator

function codeblock.commands.add_drone(pos, dir, name, file)
    local drone = codeblock.Drone:new(pos, dir, name, file) -- TODO: Change this later
    codeblock.drones[name] = drone

    local drone_entity = minetest.add_entity(pos, "codeblock:drone", nil)
    drone_entity:set_rotation({x = 0, y = dir, z = 0})
    drone_entity:get_luaentity():set_drone_owner(name)

    codeblock.drone_entities[name] = drone_entity

    return drone
end

function codeblock.commands.remove_drone(name)

    local drone_entity = codeblock.drone_entities[name];
    drone_entity:remove()
    codeblock.drones[name] = nil;
    codeblock.drone_entities[name] = nil;

end

function codeblock.commands.test_sequence(name)

    for l = 1, 10 do
        for k = 1, 5 do
            for j = 1, 4 do
                for i = 1, 10 do
                    codeblock.commands.drone_forward(name, 1)
                    codeblock.commands.drone_place_block(name, "default:stone")
                end
                codeblock.commands.drone_turn_right(name)
            end
            codeblock.commands.drone_up(name, 1)
        end
        codeblock.commands.drone_right(name, 1)
        codeblock.commands.drone_back(name, 1)
    end
end

function codeblock.commands.drone_forward(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.z = drone.z + n
    elseif angle == 1 then
        drone.x = drone.x - n
    elseif angle == 2 then
        drone.z = drone.z - n
    elseif angle == 3 then
        drone.x = drone.x + n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_right(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.x = drone.x + n
    elseif angle == 1 then
        drone.z = drone.z + n
    elseif angle == 2 then
        drone.x = drone.x - n
    elseif angle == 3 then
        drone.z = drone.z - n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_left(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.x = drone.x - n
    elseif angle == 1 then
        drone.z = drone.z - n
    elseif angle == 2 then
        drone.x = drone.x + n
    elseif angle == 3 then
        drone.z = drone.z + n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_back(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.z = drone.z - n
    elseif angle == 1 then
        drone.x = drone.x + n
    elseif angle == 2 then
        drone.z = drone.z + n
    elseif angle == 3 then
        drone.x = drone.x - n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_up(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.y = drone.y + n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.y = drone.y - n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_left(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.dir = (drone.dir + math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_right(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.dir = (drone.dir - math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_place_block(name, block)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        block)

end

--
--

function codeblock.commands.run_safe(untrusted_code, name)

    local command_env = {
        forward = function(n)
            codeblock.commands.drone_forward(name, n)
            return
        end,
        back = function(n)
            codeblock.commands.drone_back(name, n)
            return
        end,
        left = function(n)
            codeblock.commands.drone_left(name, n)
            return
        end,
        right = function(n)
            codeblock.commands.drone_right(name, n)
            return
        end,
        up = function(n)
            codeblock.commands.drone_up(name, n)
            return
        end,
        down = function(n)
            codeblock.commands.drone_down(name, n)
            return
        end,
        turn_left = function()
            codeblock.commands.drone_turn_left(name)
            return
        end,
        turn_right = function()
            codeblock.commands.drone_turn_right(name)
            return
        end,
        place = function(block)
            codeblock.commands.drone_place_block(name, block)
            return
        end,
        blocks = {stone = 'stone', dirt = 'dirt', sand='sand'}
    }

    if untrusted_code:byte(1) == 27 then
        return nil, "binary bytecode prohibited"
    end
    local untrusted_function, message = loadstring(untrusted_code)
    if not untrusted_function then return nil, message end
    setfenv(untrusted_function, command_env)
    return pcall(untrusted_function)

end

--
--

function codeblock.commands.print_lists(name)

    local s_drones = "DRONES: "
    for k in pairs(codeblock.drones) do s_drones = s_drones .. k .. " " end

    local s_entities = "ENTITIES: "
    for k in pairs(codeblock.drone_entities) do
        s_entities = s_entities .. k .. " "

    end

    -- minetest.chat_send_player(name, dump(codeblock.drones))
    -- minetest.chat_send_player(name, dump(codeblock.drone_entities))

    minetest.chat_send_player(name, s_entities)
    minetest.chat_send_player(name, s_drones)

end
