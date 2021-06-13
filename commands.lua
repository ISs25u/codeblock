codeblock.commands = {}

local S = codeblock.S

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local floor = math.floor
local abs = math.abs
local pi = math.pi
local upper = string.upper
local utils = codeblock.utils

function codeblock.commands.check_operations(name, amount)

    assert(name)

    local drone = codeblock.drones[name]

    if not drone then
        error(S('drone does not exist'))
        return
    end

    if codeblock.max_operations ~= 0 then
        local operations = drone.operations + amount;
        if operations <= codeblock.max_operations then
            drone.operations = operations
        else
            error(S('out of available operations'));
            return false
        end
    end
end

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
        minetest.chat_send_player(name, S("no file selected"))
        return
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

    local nx = (type(nx) == 'number') and floor(nx) or 0
    local ny = (type(ny) == 'number') and floor(ny) or 0
    local nz = (type(nz) == 'number') and floor(nz) or 0

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    codeblock.commands.check_operations(name, 1)

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

    local n = (type(n) == 'number') and floor(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    codeblock.commands.check_operations(name, 1)

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

    local n = (type(n) == 'number') and floor(n) or 1

    codeblock.commands.drone_forward(name, -n)

end

function codeblock.commands.drone_right(name, n)

    local n = (type(n) == 'number') and floor(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    codeblock.commands.check_operations(name, 1)

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

    local n = (type(n) == 'number') and floor(n) or 1

    codeblock.commands.drone_right(name, -n)

end

function codeblock.commands.drone_up(name, n)

    local n = (type(n) == 'number') and floor(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    codeblock.commands.check_operations(name, 1)

    drone.y = drone.y + n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    local n = (type(n) == 'number') and floor(n) or 1

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
    if not drone then error(S("drone does not exist")) end
    codeblock.commands.check_operations(name, 1)

    local quarters = (type(quarters) == 'number') and floor(quarters) or 0

    drone.dir = (drone.dir + quarters * pi * 0.5) % (2 * pi)

    codeblock.events.handle_update_drone_entity(drone)

end

-------------------------------------------------------------------------------
-- blocks
-------------------------------------------------------------------------------

function codeblock.commands.drone_place_block(name, block)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or codeblock.utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    codeblock.commands.check_operations(name, 1)

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block)

end

function codeblock.commands.drone_place_relative(name, x, y, z, block,
                                                 checkpoint_name)

    local x = (type(x) == 'number') and floor(x) or 0
    local y = (type(y) == 'number') and floor(y) or 0
    local z = (type(z) == 'number') and floor(z) or 0

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    if (x * x + y * y + z * z > codeblock.max_place_value) then
        error(S('too far away'))
    end

    local cp_name = checkpoint_name or 'start'
    if not drone.checkpoints[cp_name] then
        codeblock.commands.drone_save_checkpoint(name, cp_name)
    end
    local cp = drone.checkpoints[cp_name]

    codeblock.commands.check_operations(name, 1)

    local angle = 2 / pi * (drone.dir % (2 * pi))
    if angle == 0 then
        drone.x = cp.x + x
        drone.y = cp.y + y
        drone.z = cp.z + z
        drone.dir = cp.dir
    elseif angle == 1 then
        drone.x = cp.x - z
        drone.y = cp.y + y
        drone.z = cp.z + x
        drone.dir = cp.dir
    elseif angle == 2 then
        drone.x = cp.x - x
        drone.y = cp.y + y
        drone.z = cp.z - z
        drone.dir = cp.dir
    elseif angle == 3 then
        drone.x = cp.x + z
        drone.y = cp.y + y
        drone.z = cp.z - x
        drone.dir = cp.dir
    end

    codeblock.events.handle_update_drone_entity(drone)
    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block)

end

-------------------------------------------------------------------------------
-- WorldEdit
-------------------------------------------------------------------------------

function codeblock.commands.drone_place_cube(name, w, h, l, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and floor(abs(w)) or 10
    local h = (type(h) == 'number') and floor(abs(h)) or 10
    local l = (type(l) == 'number') and floor(abs(l)) or 10
    local x
    local y = drone.y
    local z

    codeblock.commands.check_operations(name, w * h * l)

    local angle = 2 / pi * (drone.dir % (2 * pi))
    if angle == 0 then
        w, l = w, l
        x = drone.x + floor(w * 0.5)
        z = drone.z + floor(l * 0.5)
    elseif angle == 1 then
        w, l = l, w
        x = drone.x - floor((w - 1) * 0.5)
        z = drone.z - floor((l - 1) * 0.5) + l - 1
    elseif angle == 2 then
        w, l = w, l
        x = drone.x - floor((w - 1) * 0.5)
        z = drone.z - floor((l - 1) * 0.5)
    elseif angle == 3 then
        w, l = l, w
        x = drone.x + floor(w * 0.5)
        z = drone.z + floor(l * 0.5) - l + 1
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.cube(pos, w, h, l, real_block, hollow)

end

function codeblock.commands.drone_place_ccube(name, w, h, l, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and floor(abs(w)) or 10
    local h = (type(h) == 'number') and floor(abs(h)) or 10
    local l = (type(l) == 'number') and floor(abs(l)) or 10

    codeblock.commands.check_operations(name, w * h * l)

    local angle = 2 / pi * (drone.dir % (2 * pi))
    if angle == 0 then
        w, l = w, l
    elseif angle == 1 then
        w, l = l, w
    elseif angle == 2 then
        w, l = w, l
    elseif angle == 3 then
        w, l = l, w
    end

    local pos = {x = drone.x, y = drone.y, z = drone.z}

    count = worldedit.cube(pos, w, h, l, real_block, hollow)

end

function codeblock.commands.drone_place_sphere(name, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and floor(abs(r)) or 5
    local x
    local y = drone.y + r
    local z

    codeblock.commands.check_operations(name,
                                        floor(4 / 3 * pi * (r + 0.514) ^ 3))

    local angle = 2 / pi * (drone.dir % (2 * pi))
    if angle == 0 then
        x = drone.x + r
        z = drone.z + r
    elseif angle == 1 then
        x = drone.x - r
        z = drone.z + r
    elseif angle == 2 then
        x = drone.x - r
        z = drone.z - r
    elseif angle == 3 then
        x = drone.x + r
        z = drone.z - r
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.sphere(pos, r, real_block, hollow)

end

function codeblock.commands.drone_place_csphere(name, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and floor(abs(r)) or 5
    local pos = {x = floor(drone.x), y = floor(drone.y), z = floor(drone.z)}

    codeblock.commands.check_operations(name,
                                        floor(4 / 3 * pi * (r + 0.514) ^ 3))

    count = worldedit.sphere(pos, r, real_block, hollow)

end

function codeblock.commands.drone_place_dome(name, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and floor(abs(r)) or 5
    local x
    local y = drone.y
    local z

    codeblock.commands.check_operations(name,
                                        floor(2 / 3 * pi * (r + 0.514) ^ 3))

    local angle = 2 / pi * (drone.dir % (2 * pi))
    if angle == 0 then
        x = drone.x + r
        z = drone.z + r
    elseif angle == 1 then
        x = drone.x - r
        z = drone.z + r
    elseif angle == 2 then
        x = drone.x - r
        z = drone.z - r
    elseif angle == 3 then
        x = drone.x + r
        z = drone.z - r
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.dome(pos, r, real_block, hollow)

end

function codeblock.commands.drone_place_cdome(name, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and floor(abs(r)) or 5
    local pos = {x = drone.x, y = drone.y, z = drone.z}

    codeblock.commands.check_operations(name,
                                        floor(2 / 3 * pi * (r + 0.514) ^ 3))

    count = worldedit.dome(pos, r, real_block, hollow)

end

function codeblock.commands.drone_place_cylinder(name, o, l, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and floor(abs(l)) or 10
    local r = (type(r) == 'number') and floor(abs(r)) or 5

    codeblock.commands.check_operations(name, floor((pi * l * (r + 0.514) ^ 2)))

    local axis
    local angle = 2 / pi * (drone.dir % (2 * pi))
    if (o == 'V') then
        axis = 'y'
    elseif (o == 'H') then
        if angle == 0 then
            axis = 'z'
        elseif angle == 1 then
            axis = 'x'
        elseif angle == 2 then
            axis = 'z'
        elseif angle == 3 then
            axis = 'x'
        end
    else
        axis = 'y'
    end

    local iX = (axis == 'x' and 1 or 0)
    local iY = (axis == 'y' and 1 or 0)
    local iZ = (axis == 'z' and 1 or 0)
    local x
    local y
    local z

    if angle == 0 then
        x = drone.x + r
        y = drone.y + r * (1 - iY)
        z = drone.z + r * iY
    elseif angle == 1 then
        x = drone.x - r * iY - (l - 1) * iX
        y = drone.y + r * (1 - iY)
        z = drone.z + r
    elseif angle == 2 then
        x = drone.x - r
        y = drone.y + r * (1 - iY)
        z = drone.z - r * iY - (l - 1) * iZ
    elseif angle == 3 then
        x = drone.x + r * iY
        y = drone.y + r * (1 - iY)
        z = drone.z - r
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.cylinder(pos, axis, l, r, r, real_block, hollow)

end

function codeblock.commands.drone_place_ccylinder(name, o, l, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and floor(abs(l)) or 10
    local r = (type(r) == 'number') and floor(abs(r)) or 5

    codeblock.commands.check_operations(name, floor((pi * l * (r + 0.514) ^ 2)))

    local axis
    local angle = 2 / pi * (drone.dir % (2 * pi))
    if (o == 'V') then
        axis = 'y'
    elseif (o == 'H') then
        if angle == 0 then
            axis = 'z'
        elseif angle == 1 then
            axis = 'x'
        elseif angle == 2 then
            axis = 'z'
        elseif angle == 3 then
            axis = 'x'
        end
    else
        axis = 'y'
    end

    local pos = {x = drone.x, y = drone.y, z = drone.z}

    count = worldedit.cylinder(pos, axis, l, r, r, real_block, hollow)

end

-------------------------------------------------------------------------------
-- checkpoints
-------------------------------------------------------------------------------

function codeblock.commands.drone_save_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    if type(label) ~= 'string' then error(S("no checkpoint name")) end

    codeblock.commands.check_operations(name, 1)

    drone.checkpoints[label] = {
        x = drone.x,
        y = drone.y,
        z = drone.z,
        dir = drone.dir
    }

end

function codeblock.commands.drone_goto_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    if type(label) ~= 'string' or not drone.checkpoints[label] then
        error(S("no checkpoint @1", label or ""))
    end

    codeblock.commands.check_operations(name, 1)

    local cp = drone.checkpoints[label]
    drone.x = cp.x
    drone.y = cp.y
    drone.z = cp.z
    drone.dir = cp.dir

    codeblock.events.handle_update_drone_entity(drone)

end
