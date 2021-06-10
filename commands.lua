codeblock.commands = {}

local S = codeblock.S

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local floor = math.floor
local pi = math.pi

-------------------------------------------------------------------------------
-- utilities
-------------------------------------------------------------------------------

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

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.remove_drone(name)

    local drone_entity = codeblock.drone_entities[name];
    if drone_entity then drone_entity:remove() end
    codeblock.drones[name] = nil;
    codeblock.drone_entities[name] = nil;

end

-------------------------------------------------------------------------------
-- movements
-------------------------------------------------------------------------------

function codeblock.commands.drone_move(name, nx, ny, nz)

    local nx = nx or 0
    local ny = ny or 0
    local nz = nz or 0

    local drone = codeblock.drones[name]

    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

    if angle == 0 then
        drone.x = drone.x + nx
        drone.y = drone.y + ny
        drone.z = drone.z + nz
    elseif angle == 1 then
        drone.x = drone.x - nz
        drone.y = drone.y + ny
        drone.z = drone.z + nx
    elseif angle == 2 then
        drone.x = drone.x - nx
        drone.y = drone.y + ny
        drone.z = drone.z - nz
    elseif angle == 3 then
        drone.x = drone.x + nz
        drone.y = drone.y + ny
        drone.z = drone.z - nx
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_forward(name, n)

    local n = n or 1

    local drone = codeblock.drones[name]

    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

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

    local n = n or 1

    codeblock.commands.drone_forward(name, -n)

end

function codeblock.commands.drone_right(name, n)

    local n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

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

    local n = n or 1

    codeblock.commands.drone_right(name, -n)

end

function codeblock.commands.drone_up(name, n)

    local n = n or 1

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone.y = drone.y + n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    local n = n or 1

    codeblock.commands.drone_up(name, -n)

end

function codeblock.commands.drone_turn_left(name)

    codeblock.commands.drone_turn(name, 1)

end

function codeblock.commands.drone_turn_right(name)

    codeblock.commands.drone_turn(name, -1)

end

function codeblock.commands.drone_turn(name, quarters)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    local quarters = quarters or 0

    drone.dir = (drone.dir + floor(quarters) * pi * 0.5) % (2 * pi)

    codeblock.events.handle_update_drone_entity(drone)

end

-------------------------------------------------------------------------------
-- blocks
-------------------------------------------------------------------------------

function codeblock.commands.drone_place_block(name, block_identifier)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone
    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block_name)

end

function codeblock.commands.drone_place_relative(name, x, y, z,
                                                 block_identifier,
                                                 checkpoint_name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone
    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    local cp_name = checkpoint_name or 'start'
    if not drone.checkpoints[cp_name] then
        codeblock.commands.drone_save_checkpoint(name, cp_name)
    end

    local cp = drone.checkpoints[cp_name]

    local angle = 2 / pi * (drone.dir % (2 * pi))

    if angle == 0 then
        drone.x = cp.x + (x or 0)
        drone.y = cp.y + (y or 0)
        drone.z = cp.z + (z or 0)
        drone.dir = cp.dir
    elseif angle == 1 then
        drone.x = cp.x - (z or 0)
        drone.y = cp.y + (y or 0)
        drone.z = cp.z + (x or 0)
        drone.dir = cp.dir
    elseif angle == 2 then
        drone.x = cp.x - (x or 0)
        drone.y = cp.y + (y or 0)
        drone.z = cp.z - (z or 0)
        drone.dir = cp.dir
    elseif angle == 3 then
        drone.x = cp.x + (z or 0)
        drone.y = cp.y + (y or 0)
        drone.z = cp.z - (x or 0)
        drone.dir = cp.dir
    end

    codeblock.events.handle_update_drone_entity(drone)
    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block_name)

end

function codeblock.commands.drone_place_cube(name, w, h, l, block_identifier,
                                             hollow)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone
    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

    local hollow = hollow and true or false
    local w = w or 10
    local h = h or 10
    local l = l or 10
    local x
    local y
    local z

    if angle == 0 then
        w, l = w, l
        x = drone.x + floor(w * 0.5)
        y = drone.y
        z = drone.z + floor(l * 0.5)
    elseif angle == 1 then
        w, l = l, w
        x = drone.x - floor((w - 1) * 0.5)
        y = drone.y
        z = drone.z - floor((l - 1) * 0.5) + l - 1
    elseif angle == 2 then
        w, l = w, l
        x = drone.x - floor((w - 1) * 0.5)
        y = drone.y
        z = drone.z - floor((l - 1) * 0.5)
    elseif angle == 3 then
        w, l = l, w
        x = drone.x + floor(w * 0.5)
        y = drone.y
        z = drone.z + floor(l * 0.5) - l + 1
    end

    worldedit.cube({x = x, y = y, z = z}, w, h, l, real_block_name, hollow)

end

function codeblock.commands.drone_place_sphere(name, radius, block_identifier,
                                               hollow)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone
    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

    local hollow = hollow and true or false
    local radius = radius or 10
    local x
    local y
    local z

    if angle == 0 then
        x = drone.x + radius
        y = drone.y + radius + 1
        z = drone.z + radius
    elseif angle == 1 then
        x = drone.x - radius
        y = drone.y + radius + 1
        z = drone.z + radius
    elseif angle == 2 then
        x = drone.x - radius
        y = drone.y + radius + 1
        z = drone.z - radius
    elseif angle == 3 then
        x = drone.x + radius
        y = drone.y + radius + 1
        z = drone.z - radius
    end

    count = worldedit.sphere({x = x, y = y, z = z}, radius, real_block_name,
                             hollow)

end

function codeblock.commands.drone_place_cylinder(name, A, L, R,
                                                 block_identifier, hollow)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    block_identifier = block_identifier or codeblock.sandbox.cubes_names.stone
    local real_block_name = codeblock.sandbox.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    local angle = 2 / pi * (drone.dir % (2 * pi))

    local hollow = hollow and true or false
    local A = A or 'V'
    if (A == 'V') then
        A = 'y'
    elseif (A == 'H') then
        if angle == 0 then
            A = 'z'
        elseif angle == 1 then
            A = 'x'
        elseif angle == 2 then
            A = 'z'
        elseif angle == 3 then
            A = 'x'
        end
    else
        A = 'y'
    end

    local iX = (A == 'x' and 1 or 0)
    local iY = (A == 'y' and 1 or 0)
    local iZ = (A == 'z' and 1 or 0)

    local L = L or 10
    local R = R or 5

    local x
    local y
    local z

    if angle == 0 then
        x = drone.x + R
        y = drone.y + R * (1 - iY)
        z = drone.z + R * iY
    elseif angle == 1 then
        x = drone.x - R * iY - (L - 1) * iX
        y = drone.y + R * (1 - iY)
        z = drone.z + R
    elseif angle == 2 then
        x = drone.x - R
        y = drone.y + R * (1 - iY)
        z = drone.z - R * iY - (L - 1) * iZ
    elseif angle == 3 then
        x = drone.x + R * iY
        y = drone.y + R * (1 - iY)
        z = drone.z - R
    end

    count = worldedit.cylinder({x = x, y = y, z = z}, A, L, R, R,
                               real_block_name, hollow)

end

-------------------------------------------------------------------------------
-- checkpoints
-------------------------------------------------------------------------------

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

    drone.checkpoints[label] = {
        x = drone.x,
        y = drone.y,
        z = drone.z,
        dir = drone.dir
    }

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
    drone.dir = cp.dir

    codeblock.events.handle_update_drone_entity(drone)

end
