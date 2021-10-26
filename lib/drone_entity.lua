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
                                                 'runtime error in @1',
                                                 drone.file) .. '\n' .. ret)
                        end
                    elseif status == 'dead' then
                        chat_send_player(drone.name, S('program @1 ended @2',
                                                       drone.file,
                                                       tostring(drone)))
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
                chat_send_player(drone.name, S('drone entity removed'))
                chat_send_player(drone.name, S('program @1 ended @2',
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
        chat_send_player(name, S('drone busy'))
        return
    end

    if not pos then
        chat_send_player(name, S("Please target node"))
        return {}
    end

    local dir = dirtocardinal(player:get_look_horizontal())

    local last_index = player:get_meta():get_int('codeblock:last_index')
    local auth_level = player:get_meta():get_int('codeblock:auth_level')

    drone_new(name, pos, dir, auth_level)

    if not last_index or last_index == 0 then
        DroneEntity.show_set_file_form(name)
    else
        DroneEntity.set_file_from_index(name, last_index)
    end

end

function DroneEntity.on_run(name)

    local drone = drone_get(name)

    if drone == nil then
        chat_send_player(name, S("drone does not exist"))
        return
    else
        if drone.cor ~= nil then
            chat_send_player(name, S('drone busy'))
            return
        end
    end

    local file = drone.file

    if not file then
        chat_send_player(name, S("no file selected"))
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
            chat_send_player(drone.name, S('program @1 ended @2', drone.file,
                                           tostring(drone)))
            drone_rmv(name)
        else
            drone_rmv(name)
        end
    end

end

-- assume Drone exists
function DroneEntity.set_file_from_index(name, index)

    local path = codeblock.datapath .. name

    local file, err = codeblock.filesystem.get_file_from_index(path, index)

    if err then return S('no files') end

    local drone = drone_get(name)
    if drone then
        drone.file = file
        drone:update_entity()
    end

    local player = get_player_by_name(name)
    if player then player:get_meta():set_int('codeblock:last_index', index) end

    return nil

end

function DroneEntity.read_file_from_index(name, index)

    local dpath = codeblock.datapath .. name

    local file, err = codeblock.filesystem.get_file_from_index(dpath, index)

    if err then return true, S('no files') end

    local fpath = dpath .. '/' .. file

    local fcontent = codeblock.filesystem.read(fpath)

    if fcontent:byte(1) == 27 then
        return true, S("Error in @1", file) .. S('binary bytecode prohibited')
    end

    return fcontent

end

function DroneEntity.write_file_from_index(name, index, content)

    local dpath = codeblock.datapath .. name

    local file, err = codeblock.filesystem.get_file_from_index(dpath, index)

    if err then return S('no files') end

    local fpath = dpath .. '/' .. file

    local suc = codeblock.filesystem.write(fpath, content)

    if not suc then return S('cannot write file') end

    return nil

end

function DroneEntity.show_set_file_form(name)

    local fs = codeblock.formspecs.file_chooser
    local path = codeblock.datapath .. name

    if not path then
        chat_send_player(name, S("no file selected"))
        return
    end

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        chat_send_player(name, S('no files'))
        return
    end

    local meta = {files = files, selectedIndex = 0}

    minetest.create_form(meta, name, fs.get_form(meta), fs.on_close)

end

function DroneEntity.show_file_editor_form(name)

    local fe = codeblock.formspecs.file_editor
    local path = codeblock.datapath .. name

    if not path then
        chat_send_player(name, S("no file selected"))
        return
    end

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        chat_send_player(name, S('no files'))
        return
    end

    -- load saved state

    local tabs = {}
    local tabsContents = {}
    local activeN = 0
    local activeId = 0

    local player = get_player_by_name(name)
    if player then
        -- load tabs
        local stabs = {}
        local es = player:get_meta():get_string('codeblock:editor_state_tabs')
        if es and es ~= "" then stabs = split(es, ',') end
        local id, content
        for i, sid in pairs(stabs) do
            id = tonumber(sid)
            content = DroneEntity.read_file_from_index(name, id)
            table.insert(tabs, id)
            table.insert(tabsContents, content)
        end

        -- load active tab
        activeId = player:get_meta():get_int('codeblock:editor_state_active')
        for i, id in pairs(tabs) do
            if id == activeId then
                activeN = i
                break
            end
        end
        if activeN == 0 then activeId = 0 end
    end

    local meta = {
        files = files,
        tabs = tabs,
        tabsContents = tabsContents,
        activeId = activeId,
        activeN = activeN
    }
    minetest.create_form(meta, name, fe.get_form(meta), fe.on_close)

end

--- export

codeblock.DroneEntity = setmetatable(DroneEntity, entity_mt)

