codeblock.commands = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local floor = math.floor
local abs = math.abs
local pi = math.pi
local upper = string.upper
local max = math.max
local sqrt = math.sqrt

local S = codeblock.S
local cubes_names = codeblock.utils.cubes_names
local blocks = codeblock.utils.blocks

local minetest_send_player = minetest.chat_send_player
local minetest_set_node = minetest.set_node

local max_calls = codeblock.max_calls
local max_volume = codeblock.max_volume
local max_commands = codeblock.max_commands
local max_distance = codeblock.max_distance
local max_dimension = codeblock.max_dimension
local commands_before_yield = codeblock.commands_before_yield

local tmp1 = 2 * pi
local tmp2 = pi / 2
local tmp3 = 4 / 3 * pi
local tmp4 = 2 / 3 * pi

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local function round0(x) return floor(x + .5) end

local function place_block(x, y, z, block)
    minetest_set_node({x = x, y = y, z = z}, {name = block})
end

local function use_volume(drone, v_used)

    local al = drone.auth_level

    local volume = drone.volume + v_used;
    if volume <= max_volume[al] then
        drone.volume = volume
    else
        error(S('out of available volume (@1)', max_volume[al]), 4);
    end

end

local function use_call(drone)

    local al = drone.auth_level

    local calls = drone.calls + 1;
    if calls <= max_calls[al] then
        drone.calls = calls
    else
        error(S('call limit (@1) exeeded', max_calls[al]), 4);
    end

end

local function check_drone_yield(drone, op_level)

    -- op_level = 0  -> moves
    -- op_level = 1  -> place
    -- op_level = 2  -> world_edit

    local al = drone.auth_level
    local commands = drone.commands + 1;

    if commands <= max_commands[al] then
        if al == 1 then -- yield every command
            coroutine.yield()
        elseif al == 2 then -- don't yield moves
            if op_level > 0 or (commands % commands_before_yield[al] == 0) then
                coroutine.yield()
            end
        elseif al == 3 then -- don't yield moves and place
            if op_level > 1 or (commands % commands_before_yield[al] == 0) then
                coroutine.yield()
            end
        elseif al == 4 then -- only yield every n commands
            if commands % commands_before_yield[al] == 0 then
                coroutine.yield()
            end
        else
            coroutine.yield()
        end

        drone.commands = commands

    else
        error(S('ops limit (@1) exeeded', max_commands[al]), 4);
    end

end

local function check_dimensions(drone, ...)

    local al = drone.auth_level

    local M = max(...)
    if M > max_dimension[al] then
        error(S('max dim @1 exeeded', max_dimension[al]), 4)
    end

end

local function check_distance(drone, x, y, z)

    local s = drone.spawn
    local dx = x - s[1]
    local dy = y - s[2]
    local dz = z - s[3]
    local d = dx * dx + dy * dy + dz * dz
    if d > max_distance[drone.auth_level] then
        error(S('too far away (@1)', sqrt(d)), 4)
    end

end

-------------------------------------------------------------------------------
-- movements
-------------------------------------------------------------------------------

local function drone_move(drone, x, y, z)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round0(x) or 0
    local y = (type(y) == 'number') and round0(y) or 0
    local z = (type(z) == 'number') and round0(z) or 0

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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_forward(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_back(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_right(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_left(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_up(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

    drone.y = drone.y + n

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_down(drone, n)

    assert(drone, S("drone does not exist"))

    local n = (type(n) == 'number') and round0(n) or 1

    drone.y = drone.y - n

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_turn_left(drone)

    assert(drone, S("drone does not exist"))

    drone.dir = (drone.dir + tmp2) % tmp1

    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_turn_right(drone)

    assert(drone, S("drone does not exist"))

    drone.dir = (drone.dir - tmp2) % tmp1

    drone:update_entity()
    check_drone_yield(drone, 0)

end

local function drone_turn(drone, quarters)

    assert(drone, S("drone does not exist"))

    local quarters = (type(quarters) == 'number') and round0(quarters) or 0

    drone.dir = (drone.dir + quarters * tmp2) % tmp1

    drone:update_entity()
    check_drone_yield(drone, 0)

end

-------------------------------------------------------------------------------
-- blocks
-------------------------------------------------------------------------------

local function drone_place_block(drone, block)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    use_volume(drone, 1)

    place_block(drone.x, drone.y, drone.z, real_block)
    check_drone_yield(drone, 1)

end

local function drone_place_relative(drone, x, y, z, block, chkpt)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round0(x) or 0
    local y = (type(y) == 'number') and round0(y) or 0
    local z = (type(z) == 'number') and round0(z) or 0

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local chkpt = (type(chkpt) == 'string') and chkpt or 'spawn'
    if not drone.checkpoints[chkpt] then error(S("no chkpt @1", chkpt)) end
    local cp = drone.checkpoints[chkpt]

    use_volume(drone, 1)

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

    check_distance(drone, drone.x, drone.y, drone.z)

    drone:update_entity()
    place_block(drone.x, drone.y, drone.z, real_block)
    check_drone_yield(drone, 1)

end

-------------------------------------------------------------------------------
-- WorldEdit
-------------------------------------------------------------------------------

local function drone_place_cube(drone, w, h, l, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and round0(abs(w)) or 10
    local h = (type(h) == 'number') and round0(abs(h)) or 10
    local l = (type(l) == 'number') and round0(abs(l)) or 10
    local x
    local y = drone.y
    local z

    check_dimensions(drone, w, h, l)
    use_volume(drone, w * h * l)

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
    check_drone_yield(drone, 2)

end

local function drone_place_ccube(drone, w, h, l, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local w = (type(w) == 'number') and round0(abs(w)) or 10
    local h = (type(h) == 'number') and round0(abs(h)) or 10
    local l = (type(l) == 'number') and round0(abs(l)) or 10

    check_dimensions(drone, w, h, l)
    use_volume(drone, w * h * l)

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

    local pos = {x = drone.x, y = drone.y - floor(0.5 * (h - 1)), z = drone.z}

    count = worldedit.cube(pos, w, h, l, real_block, hollow)
    check_drone_yield(drone, 2)

end

local function drone_place_sphere(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round0(abs(r)) or 5
    local x
    local y = drone.y + r
    local z

    check_dimensions(drone, r * 2)
    use_volume(drone, round0(tmp3 * (r + 0.514) ^ 3))

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
    check_drone_yield(drone, 2)

end

local function drone_place_csphere(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round0(abs(r)) or 5
    local pos = {x = round0(drone.x), y = round0(drone.y), z = round0(drone.z)}

    check_dimensions(drone, r * 2)
    use_volume(drone, round0(tmp3 * (r + 0.514) ^ 3))

    count = worldedit.sphere(pos, r, real_block, hollow)
    check_drone_yield(drone, 2)

end

local function drone_place_dome(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round0(abs(r)) or 5
    local x
    local y = drone.y
    local z

    check_dimensions(drone, r * 2)
    use_volume(drone, round0(tmp4 * (r + 0.514) ^ 3))

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
    check_drone_yield(drone, 2)

end

local function drone_place_cdome(drone, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local r = (type(r) == 'number') and round0(abs(r)) or 5
    local pos = {x = drone.x, y = drone.y, z = drone.z}

    check_dimensions(drone, r * 2)
    use_volume(drone, round0(tmp4 * (r + 0.514) ^ 3))

    count = worldedit.dome(pos, r, real_block, hollow)
    check_drone_yield(drone, 2)

end

local function drone_place_cylinder(drone, o, l, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and round0(abs(l)) or 10
    local r = (type(r) == 'number') and round0(abs(r)) or 5

    check_dimensions(drone, l, r * 2)
    use_volume(drone, round0((pi * l * (r + 0.514) ^ 2)))

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
    check_drone_yield(drone, 2)

end

local function drone_place_ccylinder(drone, o, l, r, block, hollow)

    assert(drone, S("drone does not exist"))

    block = block or cubes_names.stone
    local real_block = blocks[block]
    if not real_block then error(S('block not allowed')) end

    local hollow = (hollow == nil) and false or (hollow and true or false)
    local o = (type(o) == 'string') and upper(o) or 'V'
    local l = (type(l) == 'number') and round0(abs(l)) or 10
    local r = (type(r) == 'number') and round0(abs(r)) or 5

    check_dimensions(drone, l, r * 2)
    use_volume(drone, round0((pi * l * (r + 0.514) ^ 2)))

    local axis
    local x, y, z
    local angle = drone:angle()
    if (o == 'V') then
        axis = 'y'
        x = drone.x
        y = drone.y - floor(0.5 * (l - 1))
        z = drone.z
    elseif (o == 'H') then
        y = drone.y
        if angle == 0 then
            axis = 'z'
            x = drone.x
            z = drone.z - floor(l / 2)
        elseif angle == 1 then
            axis = 'x'
            x = drone.x - floor(l / 2)
            z = drone.z
        elseif angle == 2 then
            axis = 'z'
            x = drone.x
            z = drone.z - floor(l / 2)
        elseif angle == 3 then
            axis = 'x'
            x = drone.x - floor(l / 2)
            z = drone.z
        end
    else
        axis = 'y'
    end

    local pos = {x = x, y = y, z = z}

    count = worldedit.cylinder(pos, axis, l, r, r, real_block, hollow)
    check_drone_yield(drone, 2)

end

-------------------------------------------------------------------------------
-- checkpoints
-------------------------------------------------------------------------------

local function drone_save_checkpoint(drone, chkpt)

    assert(drone, S("drone does not exist"))

    if type(chkpt) ~= 'string' then error(S("no chkpt name")) end

    drone.checkpoints[chkpt] = {
        x = drone.x,
        y = drone.y,
        z = drone.z,
        dir = drone.dir
    }

    check_drone_yield(drone, 0)

end

local function drone_goto_checkpoint(drone, chkpt, x, y, z)

    assert(drone, S("drone does not exist"))

    local x = (type(x) == 'number') and round0(x) or 0
    local y = (type(y) == 'number') and round0(y) or 0
    local z = (type(z) == 'number') and round0(z) or 0

    local chkpt = (type(chkpt) == 'string') and chkpt or 'spawn'
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

    check_distance(drone, drone.x, drone.y, drone.z)
    drone:update_entity()
    check_drone_yield(drone, 0)

end

-------------------------------------------------------------------------------
-- message
-------------------------------------------------------------------------------

local function drone_send_message(drone, string)

    assert(drone, S("drone does not exist"))

    minetest_send_player(drone.name, '> ' .. tostring(string))
    check_drone_yield(drone, 1)
end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------

codeblock.commands.drone_move = drone_move
codeblock.commands.drone_forward = drone_forward
codeblock.commands.drone_back = drone_back
codeblock.commands.drone_right = drone_right
codeblock.commands.drone_left = drone_left
codeblock.commands.drone_up = drone_up
codeblock.commands.drone_down = drone_down
codeblock.commands.drone_turn_left = drone_turn_left
codeblock.commands.drone_turn_right = drone_turn_right
codeblock.commands.drone_turn = drone_turn
codeblock.commands.drone_place_block = drone_place_block
codeblock.commands.drone_place_relative = drone_place_relative
codeblock.commands.drone_place_cube = drone_place_cube
codeblock.commands.drone_place_ccube = drone_place_ccube
codeblock.commands.drone_place_sphere = drone_place_sphere
codeblock.commands.drone_place_csphere = drone_place_csphere
codeblock.commands.drone_place_dome = drone_place_dome
codeblock.commands.drone_place_cdome = drone_place_cdome
codeblock.commands.drone_place_cylinder = drone_place_cylinder
codeblock.commands.drone_place_ccylinder = drone_place_ccylinder
codeblock.commands.drone_save_checkpoint = drone_save_checkpoint
codeblock.commands.drone_goto_checkpoint = drone_goto_checkpoint
codeblock.commands.drone_send_message = drone_send_message
codeblock.commands.drone_use_call = use_call
