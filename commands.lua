codeblock.commands = {}

local S = default.get_translator

function codeblock.commands.add_drone(pos, dir, name, file)
    local drone = codeblock.Drone:new(pos, dir, name, file or 'temp.lua') -- TODO: Change this later
    codeblock.drones[name] = drone

    local drone_entity = minetest.add_entity(pos, "codeblock:drone", nil)
    drone_entity:set_rotation({x = 0, y = dir, z = 0})
    drone_entity:get_luaentity():set_drone_owner(name)

    codeblock.drone_entities[name] = drone_entity

    return drone
end

function codeblock.commands.test_sequence(name)

    minetest.chat_send_player(name, "Starting testing sequence")

    for i = 1, 10 do
        codeblock.commands.drone_forward(name, 5)
        codeblock.commands.drone_turn_left(name)
    end

end

function codeblock.commands.drone_forward(name, n)

    minetest.chat_send_player(name, " > Drone Forward " .. n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(player, S("drone does not exist"))
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

    codeblock.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_up(name, n)

    minetest.chat_send_player(name, " > Drone Up " .. n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(player, S("drone does not exist"))
    end

    drone.y = drone.y + n

    codeblock.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    minetest.chat_send_player(name, " > Drone Down " .. n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(player, S("drone does not exist"))
    end

    drone.y = drone.y - n

    codeblock.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_left(name)

    minetest.chat_send_player(name, " > Drone Left")

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(player, S("drone does not exist"))
    end

    drone.dir = (drone.dir + math.pi / 2) % (2 * math.pi)

    codeblock.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_right(name)

    minetest.chat_send_player(name, " > Drone Right")

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(player, S("drone does not exist"))
    end

    drone.dir = (drone.dir - math.pi / 2) % (2 * math.pi)

    codeblock.handle_update_drone_entity(drone)

end

function codeblock.commands.print_lists(name)

    local s_drones = "DRONES: "
    for k in pairs(codeblock.drones) do s_drones = s_drones .. k .. " " end

    local s_entities = "ENTITIES: "
    for k in pairs(codeblock.drone_entities) do
        s_entities = s_entities .. k .. " "

    end

    minetest.chat_send_player(name, s_entities)
    minetest.chat_send_player(name, s_drones)

end
