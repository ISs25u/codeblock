codeblock.commands = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local floor = math.floor
local abs = math.abs
local pi = math.pi
local upper = string.upper

local S = codeblock.S
local cubes_names = codeblock.utils.cubes_names
local blocks = codeblock.utils.blocks
local Drone = codeblock.Drone

local minetest_send_player = minetest.chat_send_player
local minetest_set_node = minetest.set_node

local tmp1 = 2 * pi
local tmp2 = pi / 2
local tmp3 = 4 / 3 * pi
local tmp4 = 2 / 3 * pi

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local function round(x) return floor(x + .5) end

--[[ 
    rounding and checking x,y,z are numbers should always be
    done before calling this method
 ]]
local function place_block(x, y, z, block)
    minetest_set_node({x = x, y = y, z = z}, {name = block})
end

local function check_volume(drone, volume)

    if codeblock.max_volume ~= 0 then
        local volume = drone.volume + volume;
        if volume <= codeblock.max_volume then
            drone.volume = volume
        else
            error(S('out of available volume'), 4);
            return false
        end
    end

end

local function check_and_yield(drone, type)

    -- TODO: temporary
    if type > 0 then
        return coroutine.yield()
    else
        return false
    end

end

-------------------------------------------------------------------------------
-- movements
-------------------------------------------------------------------------------

function codeblock.commands.drone_move(drone, x, y, z)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round(x) or 0
    local y = (type(y) == 'number') and round(y) or 0
    local z = (type(z) == 'number') and round(z) or 0

    local angle = drone:angle()

    if angle == 0 then
        drone.x = drone.x + x
        drone.y = drone.y + y
        drone.z = drone.z + z
    elseif angle == 1 then
        drone.x = drone.x - z
        drone.y = drone.y + y
        drone.z = drone.z + x
    elseif angle == 2 then
        drone.x = drone.x - x
        drone.y = drone.y + y
        drone.z = drone.z - z
    elseif angle == 3 then
        drone.x = drone.x + z
        drone.y = drone.y + y
        drone.z = drone.z - x
    end

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_forward(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

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

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_back(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

    local angle = drone:angle()

    if angle == 0 then
        drone.z = drone.z - n
    elseif angle == 1 then
        drone.x = drone.x + n
    elseif angle == 2 then
        drone.z = drone.z + n
    elseif angle == 3 then
        drone.x = drone.x - n
    end

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_right(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

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

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_left(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

    local angle = drone:angle()

    if angle == 0 then
        drone.x = drone.x - n
    elseif angle == 1 then
        drone.z = drone.z - n
    elseif angle == 2 then
        drone.x = drone.x + n
    elseif angle == 3 then
        drone.z = drone.z + n
    end

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_up(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

    drone.y = drone.y + n

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_down(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round(n) or 1

    drone.y = drone.y - n

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_turn_left(drone)

    assert(drone, S("drone does not exist"))

    drone.dir = (drone.dir + tmp2) % tmp1

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_turn_right(drone)

    assert(drone, S("drone does not exist"))

    drone.dir = (drone.dir - tmp2) % tmp1

    drone:update_entity()
    check_and_yield(drone, 0)

end

function codeblock.commands.drone_turn(drone, quarters)

    assert(drone, S("drone does not exist"))

    local quarters = (type(quarters) == 'number') and round(quarters) or 0

    drone.dir = (drone.dir + quarters * tmp2) % tmp1

    drone:update_entity()
    check_and_yield(drone, 0)

end

-------------------------------------------------------------------------------
-- blocks
-------------------------------------------------------------------------------

function codeblock.commands.drone_place_block(drone, block)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    check_volume(drone, 1)

    place_block(drone.x, drone.y, drone.z, real_block)
    check_and_yield(drone, 1)

end

function codeblock.commands.drone_place_relative(drone, x, y, z, block, chkpt)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round(x) or 0
    local y = (type(y) == 'number') and round(y) or 0
    local z = (type(z) == 'number') and round(z) or 0

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    if (x * x + y * y + z * z > codeblock.max_place_value) then
        error(S('too far away'))
    end

    local chkpt = (type(chkpt) == 'string') and chkpt or 'start'
    if not drone.checkpoints[chkpt] then error(S("no chkpt @1", chkpt)) end
    local cp = drone.checkpoints[chkpt]

    check_volume(drone, 1)

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

    drone:update_entity()
    place_block(drone.x, drone.y, drone.z, real_block)
    check_and_yield(drone, 1)

end

-------------------------------------------------------------------------------
-- WorldEdit
-------------------------------------------------------------------------------

function codeblock.commands.drone_place_cube(drone, w, h, l, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and round(abs(w)) or 10
    local h = (type(h) == 'number') and round(abs(h)) or 10
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local x
    local y = drone.y
    local z

    check_volume(drone, w * h * l)

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
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_ccube(drone, w, h, l, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and round(abs(w)) or 10
    local h = (type(h) == 'number') and round(abs(h)) or 10
    local l = (type(l) == 'number') and round(abs(l)) or 10

    check_volume(drone, w * h * l)

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
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_sphere(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local x
    local y = drone.y + r
    local z

    check_volume(drone, round(tmp3 * (r + 0.514) ^ 3))

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
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_csphere(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local pos = {x = round(drone.x), y = round(drone.y), z = round(drone.z)}

    check_volume(drone, round(tmp3 * (r + 0.514) ^ 3))

    count = worldedit.sphere(pos, r, real_block, hollow)
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_dome(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local x
    local y = drone.y
    local z

    check_volume(drone, round(tmp4 * (r + 0.514) ^ 3))

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
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_cdome(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round(abs(r)) or 5
    local pos = {x = drone.x, y = drone.y, z = drone.z}

    check_volume(drone, round(tmp4 * (r + 0.514) ^ 3))

    count = worldedit.dome(pos, r, real_block, hollow)
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_cylinder(drone, o, l, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local r = (type(r) == 'number') and round(abs(r)) or 5

    check_volume(drone, round((pi * l * (r + 0.514) ^ 2)))

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
    check_and_yield(drone, 2)

end

function codeblock.commands.drone_place_ccylinder(drone, o, l, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and round(abs(l)) or 10
    local r = (type(r) == 'number') and round(abs(r)) or 5

    check_volume(drone, round((pi * l * (r + 0.514) ^ 2)))

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
    check_and_yield(drone, 2)

end

-------------------------------------------------------------------------------
-- checkpoints
-------------------------------------------------------------------------------

function codeblock.commands.drone_save_checkpoint(drone, chkpt)

    assert(drone, S("drone does not exist"))

    if type(chkpt) ~= 'string' then error(S("no chkpt name")) end

    drone.checkpoints[chkpt] = {
        x = drone.x,
        y = drone.y,
        z = drone.z,
        dir = drone.dir
    }

    check_and_yield(drone, 0)

end

function codeblock.commands.drone_goto_checkpoint(drone, chkpt, x, y, z)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round(x) or 0
    local y = (type(y) == 'number') and round(y) or 0
    local z = (type(z) == 'number') and round(z) or 0

    if (x * x + y * y + z * z > codeblock.max_place_value) then
        error(S('too far away'))
    end

    local chkpt = (type(chkpt) == 'string') and chkpt or 'start'
    if not drone.checkpoints[chkpt] then error(S("no chkpt @1", chkpt)) end
    local cp = drone.checkpoints[chkpt]

    local angle = drone:angle()

    if angle == 0 then
        drone.x = cp.x + x
        drone.y = cp.y + y
        drone.z = cp.z + z
    elseif angle == 1 then
        drone.x = cp.x - z
        drone.y = cp.y + y
        drone.z = cp.z + x
    elseif angle == 2 then
        drone.x = cp.x - x
        drone.y = cp.y + y
        drone.z = cp.z - z
    elseif angle == 3 then
        drone.x = cp.x + z
        drone.y = cp.y + y
        drone.z = cp.z - x
    end

    drone:update_entity()
    check_and_yield(drone, 0)

end

-------------------------------------------------------------------------------
-- message
-------------------------------------------------------------------------------

function codeblock.commands.drone_send_message(drone, string)

    assert(drone, S("drone does not exist"))

    minetest_send_player(drone.name, '> ' .. tostring(msg))
    check_and_yield(drone, 1)
end

