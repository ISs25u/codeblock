codeblock.commands = {}

local S = default.get_translator

function codeblock.commands.add_drone(pos, dir, name, file)

    local drone = codeblock.Drone:new(pos, dir, name, file)
    codeblock.drones[name] = drone

    local drone_entity = minetest.add_entity(pos, "codeblock:drone", nil)
    drone_entity:set_rotation({x = 0, y = dir, z = 0})
    drone_entity:get_luaentity():set_drone_owner(name)

    codeblock.drone_entities[name] = drone_entity

    return drone
end

function codeblock.commands.set_drone_file_from_index(name, index)

    local path = codeblock.datapath .. name

    if not path then
        return minetest.chat_send_player(name, S("no file selected"))
    end

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        minetest.chat_send_player(name, S('no files'))
        return
    end

    local file = files[index]

    if not file then
        minetest.chat_send_player(name, S('no file selected')) -- annoying
        return
    end

    minetest.get_player_by_name(name):get_meta():set_int('codeblock:last_index',
                                                         index)

    local drone = codeblock.drones[name]

    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    codeblock.drones[name]:set_file(file)

end

function codeblock.commands.remove_drone(name)

    local drone_entity = codeblock.drone_entities[name];
    if drone_entity then drone_entity:remove() end
    codeblock.drones[name] = nil;
    codeblock.drone_entities[name] = nil;

end

function codeblock.commands.drone_forward(name, n)

    n = n or 1

    local drone = codeblock.drones[name]

    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = (drone.dir % (2 * math.pi)) / (math.pi / 2)

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

function codeblock.commands.drone_back(name, n)

    n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = (drone.dir % (2 * math.pi)) / (math.pi / 2)

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

function codeblock.commands.drone_right(name, n)

    n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = (drone.dir % (2 * math.pi)) / (math.pi / 2)

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

    n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = (drone.dir % (2 * math.pi)) / (math.pi / 2)

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

function codeblock.commands.drone_up(name, n)

    n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone.y = drone.y + n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone.y = drone.y - n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_left(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone.dir = (drone.dir + math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_right(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone.dir = (drone.dir - math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_place_block(name, block_identifier)

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block_name)

end

function codeblock.commands.drone_save_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    if not label then
        minetest.chat_send_player(name, S("no checkpoint name"))
        return
    end

    drone.checkpoints[label] = {x = drone.x, y = drone.y, z = drone.z}

end

function codeblock.commands.drone_goto_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    if not label or not drone.checkpoints[label] then
        minetest.chat_send_player(name, S("no checkpoint @1", label or ""))
        return
    end

    local cp = drone.checkpoints[label]
    drone.x = cp.x
    drone.y = cp.y
    drone.z = cp.z

    codeblock.events.handle_update_drone_entity(drone)

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
