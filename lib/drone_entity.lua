codeblock.DroneEntity = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S
local floor = math.floor
local pi = math.pi
local chat_send_player = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name

local drone_get = codeblock.Drone.get
local drone_set = codeblock.Drone.set
local drone_rmv = codeblock.Drone.remove
local drone_new = codeblock.Drone.new

local get_user_data = codeblock.filesystem.get_user_data
local read_file = codeblock.filesystem.read_file
local exists = codeblock.filesystem.exists

local split = codeblock.utils.split
local get_safe_coroutine = codeblock.sandbox.get_safe_coroutine

local tmp1 = 2 / pi
local tmp2 = pi / 2
local tmp3 = pi / 4

local function dirtocardinal(dir) return floor((dir + tmp3) * tmp1) * tmp2 end

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

local DroneEntity = {
    initial_properties = {
        visual = "cube",
        visual_size = {x = 1.1, y = 1.1},
        textures = {
            "drone_top.png", "drone_side.png", "drone_side.png",
            "drone_side.png", "drone_side.png", "drone_side.png"
        },
        collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
        physical = false,
        static_save = false
    },
    nametag = nil,
    _data = nil,
    owner = nil
}

local entity_mt = {

    __index = {

        on_step = function(self, dtime, moveresult)

            local drone = self._data -- ok as long as entity is removed

            if drone ~= nil then
                if drone.cor ~= nil then
                    local status = coroutine.status(drone.cor)
                    if status == 'suspended' then
                        local success, ret = coroutine.resume(drone.cor)
                        if not success then
                            chat_send_player(drone.name, S(
                                                 'Runtime error in @1:',
                                                 drone.file) .. '\n' .. ret)
                        end
                    elseif status == 'dead' then
                        chat_send_player(drone.name, S(
                                             "Program '@1' completed: @2",
                                             drone.file, tostring(drone)))
                        drone_rmv(drone.name)
                    end
                end

            end

            return
        end,

        on_rightclick = function(self, clicker) return end,

        on_punch = function(self, puncher, time_from_last_punch,
                            tool_capabilities, dir, damage) return {} end,

        on_blast = function(self, damage) return end,

        on_deactivate = function(self, ...)
            -- check drone existence, not the cached value
            local drone = drone_get(self._data.name)
            if drone ~= nil then
                chat_send_player(drone.name, S(
                                     'The drone has disappeared, program stopped'))
                chat_send_player(drone.name, S("Program '@1' completed: @2",
                                               drone.file, tostring(drone)))
                drone_rmv(drone.name)
            end

            return
        end

    }

}

--------------------------------------------------------------------------------
-- static
--------------------------------------------------------------------------------

function DroneEntity.on_place(name, pos)

    local player = get_player_by_name(name)

    if not player then return end

    local drone = drone_get(name)

    if drone ~= nil and drone.cor ~= nil then
        chat_send_player(name, S('Drone is busy, please wait!'))
        return
    end

    if not pos then
        chat_send_player(name, S("Please target a node"))
        return {}
    end

    local dir = dirtocardinal(player:get_look_horizontal())

    local last_file = player:get_meta():get_string('codeblock:last_file')
    local auth_level = player:get_meta():get_int('codeblock:auth_level')

    drone_new(name, pos, dir, auth_level)

    if (not last_file) or last_file == "" or
        (not get_user_data(name).ftp[last_file]) then
        DroneEntity.show_set_file_form(name)
    else
        DroneEntity.set_file(name, last_file)
    end

end

function DroneEntity.on_run(name)

    local drone = drone_get(name)

    if drone == nil then
        chat_send_player(name, S("Error, drone does not exist"))
        return
    else
        if drone.cor ~= nil then
            chat_send_player(name, S('Drone is busy, please wait!'))
            return
        end
    end

    local file = drone.file

    if not file then
        chat_send_player(name, S("Not a valid file"))
        return
    end

    local suc, res = get_safe_coroutine(drone, file)

    if not suc then
        drone_rmv(name)
        chat_send_player(name, res)
        return
    end

    drone.tstart = os.clock()
    drone.cor = res

end

function DroneEntity.on_remove(name)

    local drone = drone_get(name)

    if drone ~= nil then
        if drone.cor ~= nil then
            chat_send_player(drone.name, S("Program '@1' completed: @2",
                                           drone.file, tostring(drone)))
            drone_rmv(name)
        else
            drone_rmv(name)
        end
    end

end

function DroneEntity.set_file(name, filename)

    assert(filename)

    local player = get_player_by_name(name)

    local err = exists(name, filename)

    if err then
        chat_send_player(name, err)
        return err
    end

    -- set the drone file if drone exist
    local drone = drone_get(name)
    if drone then
        drone.file = filename
        drone:update_entity()
    end

    -- set last_file for next drone placing
    if player then
        player:get_meta():set_string('codeblock:last_file', filename)
    end

    return nil

end

function DroneEntity.show_set_file_form(name)

    local ud = get_user_data(name)
    local meta = {name = name, selectedIndex = 0}
    local fs = codeblock.formspecs.file_chooser
    minetest.create_form(meta, name, fs.get_form(meta), fs.on_close)

end

function DroneEntity.show_file_editor_form(name)

    local ud = get_user_data(name, true)

    -- load saved state
    local tabs = {}
    local contents = {}
    local active = 0
    local soe = false
    local loe = false
    local sos = false
    local player = get_player_by_name(name)
    if player then
        local meta = player:get_meta()
        soe = meta:get_int('codeblock:save_on_exit')
        loe = meta:get_int('codeblock:load_on_exit')
        sos = meta:get_int('codeblock:save_on_switch')
        local saved_active = meta:get_string('codeblock:editor_state_active')
        local saved_tabs = meta:get_string('codeblock:editor_state_tabs')
        if saved_tabs ~= "" then
            local pot_tabs = split(saved_tabs, ',')
            for i, filename in ipairs(pot_tabs) do
                if ud.ftp[filename] then
                    local content, err = read_file(name, filename, true)
                    if not err then
                        table.insert(tabs, filename)
                        table.insert(contents, content)
                        if saved_active ~= "" and filename == saved_active then
                            active = #tabs
                        end
                    else
                        chat_send_player(name, err)
                    end
                end
            end
        end
    end

    local meta = {
        name = name,
        tabs = tabs,
        contents = contents,
        active = active,
        help = 'cubes',
        scroll_c = 0,
        scroll_p = 0,
        scroll_w = 0,
        scroll_a = 0,
        soe = soe,
        loe = loe,
        sos = sos,
        newfile = ''
    }
    local fe = codeblock.formspecs.file_editor
    minetest.create_form(meta, name, fe.get_form(meta), fe.on_close)
    -- minetest.get_form_timer(name).start(1)

end

--- export

codeblock.DroneEntity = setmetatable(DroneEntity, entity_mt)

