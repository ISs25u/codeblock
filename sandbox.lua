codeblock.sandbox = {}

local S = codeblock.S

local function getScriptEnv(name)

    local cmd = codeblock.commands
    local utils = codeblock.utils

    local env = {
        move = function(x, y, z)
            cmd.drone_move(name, x, y, z)
            return
        end,
        forward = function(n)
            cmd.drone_forward(name, n)
            return
        end,
        back = function(n)
            cmd.drone_back(name, n)
            return
        end,
        left = function(n)
            cmd.drone_left(name, n)
            return
        end,
        right = function(n)
            cmd.drone_right(name, n)
            return
        end,
        up = function(n)
            cmd.drone_up(name, n)
            return
        end,
        down = function(n)
            cmd.drone_down(name, n)
            return
        end,
        turn_left = function()
            cmd.drone_turn_left(name)
            return
        end,
        turn_right = function()
            cmd.drone_turn_right(name)
            return
        end,
        turn = function(quarters)
            cmd.drone_turn(name, quarters)
            return
        end,
        place = function(block)
            cmd.drone_place_block(name, block)
            return
        end,
        place_relative = function(x, y, z, block, label)
            cmd.drone_place_relative(name, x, y, z, block, label)
        end,
        save = function(label) cmd.drone_save_checkpoint(name, label) end,
        go = function(label) cmd.drone_goto_checkpoint(name, label) end,
        cube = function(w, h, l, block, hollow)
            cmd.drone_place_cube(name, w, h, l, block, hollow)
        end,
        sphere = function(r, block, hollow)
            cmd.drone_place_sphere(name, r, block, hollow)
        end,
        dome = function(r, block, hollow)
            cmd.drone_place_dome(name, r, block, hollow)
        end,
        vertical = {
            cylinder = function(l, r, block, hollow)
                cmd.drone_place_cylinder(name, 'V', l, r, block, hollow)
            end
        },
        horizontal = {
            cylinder = function(l, r, block, hollow)
                cmd.drone_place_cylinder(name, 'H', l, r, block, hollow)
            end
        },
        centered = {
            cube = function(w, h, l, block, hollow)
                cmd.drone_place_ccube(name, w, h, l, block, hollow)
            end,
            sphere = function(r, block, hollow)
                cmd.drone_place_csphere(name, r, block, hollow)
            end,
            dome = function(r, block, hollow)
                cmd.drone_place_cdome(name, r, block, hollow)
            end,
            vertical = {
                cylinder = function(l, r, block, hollow)
                    cmd.drone_place_ccylinder(name, 'V', l, r, block, hollow)
                end
            },
            horizontal = {
                cylinder = function(l, r, block, hollow)
                    cmd.drone_place_ccylinder(name, 'H', l, r, block, hollow)
                end
            }
        },
        blocks = codeblock.utils.cubes_names,
        plants = codeblock.utils.plants_names,
        wools = codeblock.utils.wools_names,
        iwools = codeblock.utils.iwools_names,
        ipairs = ipairs,
        pairs = pairs,
        random = math.random,
        floor = math.floor,
        ceil = math.ceil,
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
        vector = vector,
        error = error,
        print = function(msg)
            minetest.chat_send_player(name, '> ' .. tostring(msg))
            return
        end
    }

    env._G = env
    return env

end

--------------------------------------------------------------------------------
-- adapted from https://github.com/ac-minetest/basic_robot/blob/master/init.lua
--------------------------------------------------------------------------------

local function check_code(code)
    -- "while ", "for ", "do ","goto ",  
    local bad_code = {"repeat", "until", "_c_", "_G", "while%(", "while{"} -- ,"\\\"", "%[=*%[","--[["}, "%.%.[^%.]"
    for _, v in pairs(bad_code) do
        if string.find(code, v) then return S('@1 is not allowed', v) end
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
    local length = string.len(script)
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

local function preprocess_code(script, call_limit) -- version 07/24/2018

    --[[ idea: in each local a = function (args) ... end insert counter like:
	local a = function (args) counter_check_code ... end 
	when counter exceeds limit exit with error
	--]]

    local call_limit = codeblock.call_limit

    script = script:gsub("%-%-%[%[.*%-%-%]%]", ""):gsub("%-%-[^\n]*\n", "\n") -- strip comments

    -- process script to insert call counter in every function
    local _increase_ccounter = " _c_ = _c_ + 1; if _c_ > " .. call_limit ..
                                   " then _G.error(\"" ..
                                   S('call limit (@1) exeeded', call_limit) ..
                                   "\") end; "

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
    script = table.concat(ret, _increase_ccounter)

    -- must reset ccounter when paused, but user should not be able to force reset by modifying pause!
    -- (suggestion about 'pause' by Kimapr, 09/26/2019)

    return '_c_ = 0\n' .. script;

end

function codeblock.sandbox.run_safe(name, file)

    if not file then
        minetest.chat_send_player(name, S("Empty drone file"))
        return
    end

    local path = codeblock.datapath .. name .. '/' .. file
    local untrusted_code = codeblock.filesystem.read(path)

    if not untrusted_code then
        minetest.chat_send_player(name, S('@1 not found', file))
        return
    end

    if untrusted_code:byte(1) == 27 then
        minetest.chat_send_player(name, S("Error in @1", file) ..
                                      S("binary bytecode prohibited"))
    end

    err = check_code(untrusted_code);

    if err then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, err)
        return
    end

    safe_code = preprocess_code(untrusted_code, 10); -- TODO change limit

    local bytecode, message = loadstring(safe_code)
    if not bytecode then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, message)
        return
    end

    setfenv(bytecode, getScriptEnv(name))
    math.randomseed(minetest.get_us_time())
    local status, err = pcall(bytecode)

    if not status then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, err)
        return
    end

end
