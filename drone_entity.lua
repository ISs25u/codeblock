codeblock.DroneEntity = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S
local floor = math.floor
local pi = math.pi
local minetest_send_player = minetest.chat_send_player
local Drone = codeblock.Drone

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

            local drone = self._data

            if drone ~= nil and drone.cor ~= nil then

                local status = coroutine.status(drone.cor)

                if status == 'suspended' then

                    local success, ret = coroutine.resume(drone.cor)

                    if not success then
                        minetest_send_player(drone.name, S(
                                                 'runtime error in @1',
                                                 drone.file) .. '\n' .. ret)
                    end

                elseif status == 'dead' then
                    -- TODO remove or change
                    minetest_send_player(drone.name, 'Program ' .. drone.file ..
                                             ' ended: ' .. tostring(drone))
                    Drone[drone.name] = nil
                end

            end

            return
        end,

        on_rightclick = function(self, clicker) return end,

        on_punch = function(self, puncher, time_from_last_punch,
                            tool_capabilities, dir, damage) return {} end,

        on_blast = function(self, damage) return end,

        on_deactivate = function(self, ...)
            -- TODO
            -- Drone[self.owner] = nil
            return
        end

    }

}

--------------------------------------------------------------------------------
-- static
--------------------------------------------------------------------------------

function DroneEntity.place(placer, pointed_thing)

    local name = placer:get_player_name()

    local pos = minetest.get_pointed_thing_position(pointed_thing)

    if not pos then
        minetest_send_player(name, S("Please target node"))
        return {}
    end

    local dir = dirtocardinal(placer:get_look_horizontal())

    local last_index = placer:get_meta():get_int('codeblock:last_index')
    local auth_level = placer:get_meta():get_int('codeblock:auth_level')

    Drone(name, pos, dir, auth_level)

    if not last_index or last_index == 0 then
        DroneEntity.showfileformspec(placer)
    else
        DroneEntity.setfilefromindex(placer, last_index)
    end

end

function DroneEntity.run(user)

    local name = user:get_player_name()

    local drone = Drone[name]

    if not drone then
        minetest_send_player(name, S("drone does not exist"))
        return
    end

    local file = drone.file

    if not file then
        minetest_send_player(name, S("no file selected"))
        return
    end

    local suc, res = codeblock.sandbox.get_safe_coroutine(drone, file)

    if not suc then
        Drone[name] = nil
        minetest_send_player(name, res)
        return
    end

    drone.tstart = os.clock()
    drone.cor = res

end

function DroneEntity.remove_drone(player)

    local name = player:get_player_name()
    Drone[name] = nil

end

-- assume Drone exists
function DroneEntity.setfilefromindex(player, index)

    local name = player:get_player_name()

    local path = codeblock.datapath .. name

    local file, err = codeblock.filesystem.get_file_from_index(path, index)

    if err then
        minetest_send_player(name, S('no files'))
        return
    end

    local drone = Drone[name]

    if drone then

        drone.file = file
        drone:update_entity()

    end

    player:get_meta():set_int('codeblock:last_index', index)

    return

end

function DroneEntity.showfileformspec(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not path then
        minetest_send_player(name, S("no file selected"))
        return
    end

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        minetest_send_player(name, S('no files'))
        return
    end

    minetest.show_formspec(name, 'codeblock:choose_file',
                           codeblock.formspecs.choose_file(files))

end

--- export

codeblock.DroneEntity = setmetatable(DroneEntity, entity_mt)

