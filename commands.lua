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
local Drone = codeblock.Drone
local csp = minetest.chat_send_player
local update_drone_entity = codeblock.events.handle_update_drone_entity

local function round(x) return floor(x + .5) end

local function check_volume(name, volume)

    assert(name)

    local drone = codeblock.drones[name]

    if not drone then
        error(S('drone does not exist'))
        return
    end

    if codeblock.max_volume ~= 0 then
        local volume = drone.volume + volume;
        if volume <= codeblock.max_volume then
            drone.volume = volume
        else
            error(S('out of available volume'));
            return false
        end
    end
end

-------------------------------------------------------------------------------
-- utilities
-------------------------------------------------------------------------------

function codeblock.commands.add_drone(pos, dir, name, file)

    local drone = Drone(pos, dir, name, file)
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
        csp(name, S("no file selected"))
        return
    end

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        csp(name, S('no files'))
        return
    end

    local file = files[index]

    if not file then
        csp(name, S('no file selected')) -- annoying
        return
    end

    minetest.get_player_by_name(name):get_meta():set_int('codeblock:last_index',
                                                         index)

    local drone = codeblock.drones[name]

    if not drone then
        csp(name, S("drone does not exist"))
        return
    end

    codeblock.drones[name].file = file

    update_drone_entity(drone)

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

    local nx = (type(nx) == 'number') and round(nx) or 0
    local ny = (type(ny) == 'number') and round(ny) or 0
    local nz = (type(nz) == 'number') and round(nz) or 0

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    -- check_volume(name, 1)

    local angle = drone:angle()

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

    update_drone_entity(drone)

end

function codeblock.commands.drone_forward(name, n)

    local n = (type(n) == 'number') and round(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    -- check_volume(name, 1)

    local angle = drone:angle()

    if angle == 0 then
        drone.z = drone.z + n
    elseif angle == 1 then
        drone.x = drone.x - n
    elseif angle == 2 then
        drone.z = drone.z - n
    elseif angle == 3 then
        drone.x = drone.x + n
    end

    update_drone_entity(drone)

end

function codeblock.commands.drone_back(name, n)

    local n = (type(n) == 'number') and round(n) or 1

    codeblock.commands.drone_forward(name, -n)

end

function codeblock.commands.drone_right(name, n)

    local n = (type(n) == 'number') and round(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    -- check_volume(name, 1)

    local angle = drone:angle()

    if angle == 0 then
        drone.x = drone.x + n
    elseif angle == 1 then
        drone.z = drone.z + n
    elseif angle == 2 then
        drone.x = drone.x - n
    elseif angle == 3 then
        drone.z = drone.z - n
    end

    update_drone_entity(drone)

end

function codeblock.commands.drone_left(name, n)

    local n = (type(n) == 'number') and round(n) or 1

    codeblock.commands.drone_right(name, -n)

end

function codeblock.commands.drone_up(name, n)

    local n = (type(n) == 'number') and round(n) or 1

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end
    -- check_volume(name, 1)

    drone.y = drone.y + n

    update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    local n = (type(n) == 'number') and round(n) or 1

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
    -- check_volume(name, 1)

    local quarters = (type(quarters) == 'number') and round(quarters) or 0

    drone.dir = (drone.dir + quarters * pi * 0.5) % (2 * pi)

    update_drone_entity(drone)

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

    check_volume(name, 1)

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block)

end

function codeblock.commands.drone_place_relative(name, x, y, z, block,
                                                 checkpoint_name)

    local x = (type(x) == 'number') and round(x) or 0
    local y = (type(y) == 'number') and round(y) or 0
    local z = (type(z) == 'number') and round(z) or 0

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

    check_volume(name, 1)

    local angle = drone:angle()
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

    update_drone_entity(drone)
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
    local w = (type(w) == 'number') and round(abs(w)) or 10
    local h = (type(h) == 'number') and round(abs(h)) or 10
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local x
    local y = drone.y
    local z

    check_volume(name, w * h * l)

    local angle = drone:angle()
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
    local w = (type(w) == 'number') and round(abs(w)) or 10
    local h = (type(h) == 'number') and round(abs(h)) or 10
    local l = (type(l) == 'number') and round(abs(l)) or 10

    check_volume(name, w * h * l)

    local angle = drone:angle()
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
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local x
    local y = drone.y + r
    local z

    check_volume(name, round(4 / 3 * pi * (r + 0.514) ^ 3))

    local angle = drone:angle()
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
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local pos = {x = round(drone.x), y = round(drone.y), z = round(drone.z)}

    check_volume(name, round(4 / 3 * pi * (r + 0.514) ^ 3))

    count = worldedit.sphere(pos, r, real_block, hollow)

end

function codeblock.commands.drone_place_dome(name, r, block, hollow)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    block = block or utils.cubes_names.stone
    local real_block = utils.blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local x
    local y = drone.y
    local z

    check_volume(name, round(2 / 3 * pi * (r + 0.514) ^ 3))

    local angle = drone:angle()
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
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local pos = {x = drone.x, y = drone.y, z = drone.z}

    check_volume(name, round(2 / 3 * pi * (r + 0.514) ^ 3))

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
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local r = (type(r) == 'number') and round(abs(r)) or 5

    check_volume(name, round((pi * l * (r + 0.514) ^ 2)))

    local axis
    local angle = drone:angle()
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
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local r = (type(r) == 'number') and round(abs(r)) or 5

    check_volume(name, round((pi * l * (r + 0.514) ^ 2)))

    local axis
    local x, y, z
    local angle = drone:angle()
    if (o == 'V') then
        axis = 'y'
        x = drone.x
        y = drone.y
        z = drone.z
    elseif (o == 'H') then
        if angle == 0 then
            axis = 'z'
            x = drone.x
            y = drone.y
            z = drone.z - floor(l / 2)
        elseif angle == 1 then
            axis = 'x'
            x = drone.x - floor(l / 2)
            y = drone.y
            z = drone.z
        elseif angle == 2 then
            axis = 'z'
            x = drone.x
            y = drone.y
            z = drone.z - floor(l / 2)
        elseif angle == 3 then
            axis = 'x'
            x = drone.x - floor(l / 2)
            y = drone.y
            z = drone.z
        end
    else
        axis = 'y'
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.cylinder(pos, axis, l, r, r, real_block, hollow)

end

-------------------------------------------------------------------------------
-- checkpoints
-------------------------------------------------------------------------------

function codeblock.commands.drone_save_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then error(S("drone does not exist")) end

    if type(label) ~= 'string' then error(S("no checkpoint name")) end

    -- check_volume(name, 1)

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

    -- check_volume(name, 1)

    local cp = drone.checkpoints[label]
    drone.x = cp.x
    drone.y = cp.y
    drone.z = cp.z
    drone.dir = cp.dir

    update_drone_entity(drone)

end
