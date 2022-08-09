codeblock.sandbox = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S
local max = math.max
local min = math.min
local abs = math.abs
local floor = math.floor

local move = codeblock.commands.drone_move
local forward = codeblock.commands.drone_forward
local back = codeblock.commands.drone_back
local right = codeblock.commands.drone_right
local left = codeblock.commands.drone_left
local up = codeblock.commands.drone_up
local down = codeblock.commands.drone_down
local turn_left = codeblock.commands.drone_turn_left
local turn_right = codeblock.commands.drone_turn_right
local turn = codeblock.commands.drone_turn
local place_block = codeblock.commands.drone_place_block
local place_relative = codeblock.commands.drone_place_relative
local place_cube = codeblock.commands.drone_place_cube
local place_ccube = codeblock.commands.drone_place_ccube
local place_sphere = codeblock.commands.drone_place_sphere
local place_csphere = codeblock.commands.drone_place_csphere
local place_dome = codeblock.commands.drone_place_dome
local place_cdome = codeblock.commands.drone_place_cdome
local place_cylinder = codeblock.commands.drone_place_cylinder
local place_ccylinder = codeblock.commands.drone_place_ccylinder
local save_checkpoint = codeblock.commands.drone_save_checkpoint
local goto_checkpoint = codeblock.commands.drone_goto_checkpoint
local send_message = codeblock.commands.drone_send_message
local use_call = codeblock.commands.drone_use_call
local drone_get_block = codeblock.commands.drone_get_block
local override_day_night_ratio = codeblock.commands.drone_override_day_night_ratio
local set_clouds = codeblock.commands.drone_set_clouds
local set_stars = codeblock.commands.drone_set_stars
local set_sun = codeblock.commands.drone_set_sun
local set_moon = codeblock.commands.drone_set_moon

local cubes = codeblock.config.allowed_blocks.cubes
local plants = codeblock.config.allowed_blocks.plants
local wools = codeblock.config.allowed_blocks.wools
local iwools = codeblock.config.allowed_blocks.iwools
local niwools = #iwools
local table_randomizer = codeblock.utils.table_randomizer

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

local function round(dec, num)
    local mult = 10 ^ (dec or 0)
    return floor(num * mult + 0.5) / mult
end

local function round0(num) return floor(num + 0.5) end

local color
do
    local tmp1 = niwools - 1
    color = function(v, m, M)
        local m = (type(m) == 'number') and m or 1
        local M = (type(M) == 'number') and M or 11
        m, M = min(m, M), max(m, M)
        local i = round0(((v - m) / (M - m) * tmp1) % niwools) + 1
        return iwools[i]
    end
end

local function getScriptEnv(drone)

    assert(drone, S("Error, drone does not exist"))

    local env = {
        -- movements
        move = function(x, y, z) move(drone, x, y, z) end,
        forward = function(n) forward(drone, n) end,
        back = function(n) back(drone, n) end,
        left = function(n) left(drone, n) end,
        right = function(n) right(drone, n) end,
        up = function(n) up(drone, n) end,
        down = function(n) down(drone, n) end,
        turn_left = function() turn_left(drone) end,
        turn_right = function() turn_right(drone) end,
        turn = function(quarters) turn(drone, quarters) end,
        place = function(block) place_block(drone, block) end,
        place_relative = function(x, y, z, block, chkpt)
            place_relative(drone, x, y, z, block, chkpt)
        end,
        save = function(chkpt) save_checkpoint(drone, chkpt) end,
        go = function(chkpt, x, y, z)
            goto_checkpoint(drone, chkpt, x, y, z)
        end,
        -- worldedit commands
        cube = function(w, h, l, block, hollow)
            place_cube(drone, w, h, l, block, hollow)
        end,
        sphere = function(r, block, hollow)
            place_sphere(drone, r, block, hollow)
        end,
        dome = function(r, block, hollow)
            place_dome(drone, r, block, hollow)
        end,
        cylinder = function(l, r, block, hollow)
            place_cylinder(drone, 'V', l, r, block, hollow)
        end,
        vertical = {
            cylinder = function(l, r, block, hollow)
                place_cylinder(drone, 'V', l, r, block, hollow)
            end
        },
        horizontal = {
            cylinder = function(l, r, block, hollow)
                place_cylinder(drone, 'H', l, r, block, hollow)
            end
        },
        centered = {
            cube = function(w, h, l, block, hollow)
                place_ccube(drone, w, h, l, block, hollow)
            end,
            sphere = function(r, block, hollow)
                place_csphere(drone, r, block, hollow)
            end,
            dome = function(r, block, hollow)
                place_cdome(drone, r, block, hollow)
            end,
            cylinder = function(l, r, block, hollow)
                place_ccylinder(drone, 'V', l, r, block, hollow)
            end,
            vertical = {
                cylinder = function(l, r, block, hollow)
                    place_ccylinder(drone, 'V', l, r, block, hollow)
                end
            },
            horizontal = {
                cylinder = function(l, r, block, hollow)
                    place_ccylinder(drone, 'H', l, r, block, hollow)
                end
            }
        },
        -- blocks: wools
        wools = wools,
        iwools = iwools,
        -- blocks: default
        blocks = cubes,
        plants = plants,
        -- vector3 commands
        vector = vector3,
        -- environments
        override_day_night_ratio = function(ratio) return override_day_night_ratio(drone, ratio) end,
        set_clouds = function(value) return set_clouds(drone, value) end,
        set_stars = function(value) return set_stars(drone, value) end,
        set_sun = function(value) return set_sun(drone, value) end,
        set_moon = function(value) return set_moon(drone, value) end,
        -- utilities
        get_block = function() return drone_get_block(drone) end,
        print = function(str) return send_message(drone, str) end,
        color = color,
        ipairs = ipairs,
        pairs = pairs,
        type = type,
        random = setmetatable({}, {
            __index = {
                block = table_randomizer(cubes),
                plant = table_randomizer(plants),
                wool = table_randomizer(wools)
            },
            __call = function(self, ...) return math.random(...) end
        }),
        table = {randomizer = table_randomizer},
        floor = math.floor,
        ceil = math.ceil,
        round = round,
        round0 = round0,
        deg = math.deg,
        rad = math.rad,
        exp = math.exp,
        log = math.log,
        max = math.max,
        min = math.min,
        pow = math.pow,
        sqrt = math.sqrt,
        abs = math.abs,
        sin = math.sin,
        sinh = math.sinh,
        asin = math.asin,
        cos = math.cos,
        cosh = math.cosh,
        acos = math.acos,
        tan = math.tan,
        tanh = math.tanh,
        atan = math.atan,
        atan2 = math.atan2,
        pi = math.pi,
        e = math.exp(1),
        error = error
    }

    env._G = {
        print = env.print,
        error = env.error,
        use_call = function() use_call(drone) end
    }
    return env

end

--------------------------------------------------------------------------------
-- adapted from https://github.com/ac-minetest/basic_robot/blob/master/init.lua
--------------------------------------------------------------------------------

local function check_code(code)
    -- "while ", "for ", "do ","goto ",
    local bad_code = {"repeat", "until", "_c_", "_G", "while%(", "while{"} -- ,"\\\"", "%[=*%[","--[["}, "%.%.[^%.]"
    for _, v in pairs(bad_code) do
        if string.find(code, v) then return S('@1 is not allowed!', v) end
    end
end

local function identify_strings(code) -- returns list of positions {start,end} of literal strings in lua code

    local i = 0;
    local j;
    local _;
    local length = string.len(code);
    local mode = 0; -- 0: not in string, 1: in '...' string, 2: in "..." string, 3. in [==[ ... ]==] string
    local modes = {
        {"'", "'"}, -- inside ' '
        {"\"", "\""}, -- inside " "
        {"%[=*%[", "%]=*%]"} -- inside [=[ ]=]
    }
    local ret = {}
    while i < length do
        i = i + 1

        local jmin = length + 1;
        if mode == 0 then -- not yet inside string
            for k = 1, #modes do
                j = string.find(code, modes[k][1], i);
                if j and j < jmin then -- pick closest one
                    jmin = j
                    mode = k
                end
            end
            if mode ~= 0 then -- found something
                j = jmin
                ret[#ret + 1] = {jmin}
            end
            if not j then break end -- found nothing
        else
            _, j = string.find(code, modes[mode][2], i); -- search for closing pair
            if not j then break end
            if (mode ~= 2 or (string.sub(code, j - 1, j - 1) ~= "\\") or
                string.sub(code, j - 2, j - 1) == "\\\\") then -- not (" and not \" - but "\\" is allowed)
                ret[#ret][2] = j
                mode = 0
            end
        end
        i = j -- move to next position
    end
    if mode ~= 0 then ret[#ret][2] = length end
    return ret
end

local function is_inside_string(strings, pos) -- is position inside one of the strings?
    local low = 1;
    local high = #strings;
    if high == 0 then return false end
    local mid = high;
    while high > low + 1 do
        mid = math.floor((low + high) / 2)
        if pos < strings[mid][1] then
            high = mid
        else
            low = mid
        end
    end
    if pos > strings[low][2] then
        mid = high
    else
        mid = low
    end
    return strings[mid][1] <= pos and pos <= strings[mid][2]
end

local function find_outside_string(script, pattern, pos, strings)
    local found = true;
    local i1 = pos;
    while found do
        found = false
        local i2 = string.find(script, pattern, i1);
        if i2 then
            if not is_inside_string(strings, i2) then return i2 end
            found = true;
            i1 = i2 + 1;
        end
    end
    return nil
end

local function preprocess_code(script)

    -- strip comments
    script = script:gsub("%-%-%[%[.*%-%-%]%]", ""):gsub("%-%-[^\n]*\n", "\n")

    -- process script to insert call counter in every function
    local _use_call_code = " _G.use_call(); "

    local i1 = 0;
    local i2 = 0;
    local found = true;

    local strings = identify_strings(script);

    local inserts = {};

    local constructs = {
        {"while%s", "%sdo%s", 2, 6}, -- numbers: insertion pos = i2+2,  after skip to i1 = i12+6
        {"function", ")", 0, 8}, {"for%s", "%sdo%s", 2, 4},
        {"goto%s", nil, -1, 5}
    }

    for i = 1, #constructs do
        i1 = 0;
        found = true
        while (found) do -- PROCESS SCRIPT AND INSERT COUNTER AT PROBLEMATIC SPOTS

            found = false;

            i2 = find_outside_string(script, constructs[i][1], i1, strings) -- first part of construct
            if i2 then
                local i21 = i2;
                if constructs[i][2] then
                    i2 = find_outside_string(script, constructs[i][2], i2,
                                             strings); -- second part of construct ( if any )
                    if i2 then
                        inserts[#inserts + 1] = i2 + constructs[i][3]; -- move to last position of construct[i][2]
                        found = true;
                    end
                else
                    inserts[#inserts + 1] = i2 + constructs[i][3]
                    found = true -- 1 part construct
                end

                if found then
                    i1 = i21 + constructs[i][4]; -- skip to after constructs[i][1]
                end
            end

        end
    end

    table.sort(inserts)

    -- add inserts
    local ret = {};
    i1 = 1;
    for i = 1, #inserts do
        i2 = inserts[i];
        ret[#ret + 1] = string.sub(script, i1, i2);
        i1 = i2 + 1;
    end
    ret[#ret + 1] = string.sub(script, i1);
    script = table.concat(ret, _use_call_code)

    return script;

end

local function loadScript(filename, droneName)
    local untrusted_code = codeblock.filesystem.read_file(droneName, filename, true)

    if not untrusted_code then
        return false, S("Compilation error in @1: ", filename) ..
                   S('@1 not found.', filename)
    end

    if untrusted_code:byte(1) == 27 then
        return false, S("Compilation error in @1: ", filename) ..
                   S("binary bytecode prohibited")
    end

    return true, untrusted_code
end

local function inlcudeFile(script, droneName)
    local errs = {}
    script = script:gsub("%-%-+%s*include%s+(%S+)\n", function(filename)
        local result = filename:gsub("^%s*(.-)%s*$", "%1") --trim spaces
        local char = result:sub(1,1)
        if char == '(' or char == '[' or char == '{' or char == "'" or char == '"' then
            result = result:sub(2, #result - 1)
        end
        if result ~= "" then
            if result:sub(-4) ~= ".lua" then result = result .. ".lua" end
            local ok
            ok, result = loadScript(result, droneName)
            if not ok then
                table.insert(errs, result)
                result = filename
            end
        else
            result = filename
        end
        return result
    end)
    if #errs > 0 then
        return false, table.concat(errs, "\n")
    else
        return true, script
    end
end

--------------------------------------------------------------------------------
-- public
--------------------------------------------------------------------------------

function codeblock.sandbox.get_safe_coroutine(drone, filename)

    assert(drone)
    assert(filename)

    local name = drone.name
    local filename = drone.file

    -- loading file
    local ok, untrusted_code = loadScript(filename, name)
    if not ok then return ok, untrusted_code end
    ok, untrusted_code = inlcudeFile(untrusted_code, name)
    if not ok then return ok, untrusted_code end

    -- checking forbiden things

    local err = check_code(untrusted_code);

    if err then
        return false, S("Compilation error in @1: ", filename) .. '\n' .. err
    end

    -- preprocessing code

    local safe_code = preprocess_code(untrusted_code);

    -- compiling into bytecode

    local bytecode, message = loadstring(safe_code)
    if not bytecode then
        return false,
               S("Compilation error in @1: ", filename) .. '\n' .. message
    end

    -- return it

    setfenv(bytecode, getScriptEnv(drone))
    return true, coroutine.create(bytecode)

end
