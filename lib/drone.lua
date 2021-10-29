codeblock.Drone = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S
local pi = math.pi
local floor = math.floor
local min = math.min
local max = math.max

local chat_send_player = minetest.chat_send_player
local check_auth_level = codeblock.utils.check_auth_level

local tmp1 = 2 / pi
local tmp2 = 2 * pi
local tmp3 = pi / 2

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

local Drone = {instances = {}}

local instance_mt = {

    __index = {

        update_entity = function(self)
            if self.obj ~= nil then
                self.obj:set_pos({x = self.x, y = self.y, z = self.z})
                self.obj:set_rotation({x = 0, y = self.dir, z = 0})
                self.obj:set_properties({
                    nametag = '[' .. self.obj:get_luaentity().owner .. '] ' ..
                        (self.file or '?.lua')
                });
            end
        end,

        angle = function(self) return tmp1 * (self.dir % tmp2) end

    },

    __tostring = function(self)
        return S('cmd @1 call @2 vol @3 time @4', self.commands, self.calls,
                 self.volume, (os.clock() - (self.tstart or os.clock())))
    end
}

local drone_mt = {

    __index = {

        new = function(name, pos, dir, auth_level)

            assert(type(name) == 'string' and #name > 0, 'Wrong parameters')
            assert(type(pos) == 'table' and
                       (type(pos.x) == 'number' and type(pos.y) == 'number' and
                           type(pos.z) == 'number'), 'Wrong parameters')
            local suc, auth_level = check_auth_level(auth_level)
            if not suc then
                minetest.get_player_by_name(name):get_meta():set_int(
                    'codeblock:auth_level', codeblock.config.default_auth_level)
            end

            local px, py, pz = floor(pos.x), floor(pos.y), floor(pos.z)
            local dir = (type(dir) == 'number' and dir % tmp3 == 0) and dir or 0

            local drone = {
                name = name,
                x = px,
                y = py,
                z = pz,
                spawn = {px, py, pz},
                dir = dir,
                auth_level = auth_level,
                checkpoints = {},
                volume = 0,
                calls = 0,
                commands = 0,
                tstart = nil,
                file = nil,
                cor = nil,
                obj = nil
            }

            drone.checkpoints['spawn'] = {x = px, y = py, z = pz, dir = dir}

            setmetatable(drone, instance_mt)

            drone.obj = minetest.add_entity(pos, "codeblock:drone", nil)
            drone.obj:get_luaentity().owner = name
            drone.obj:get_luaentity()._data = drone

            drone:update_entity()

            Drone.set(name, drone)

            return drone

        end,

        get = function(k) return rawget(Drone.instances, k) end,

        set = function(k, v)
            Drone.remove(k)
            return rawset(Drone.instances, k, v)
        end,
        remove = function(k)
            local d = rawget(Drone.instances, k)
            if d ~= nil then
                rawset(Drone.instances, k, nil) -- avoid obj:remove() to call remove() again
                if d.obj ~= nil then d.obj:remove() end
                d.obj = nil
                d.cor = nil
                return nil
            end
            return nil
        end

    },

    __tostring = function()

        local s = ''
        for k, v in pairs(Drone.instances) do
            s = s .. k .. ': ' .. tostring(v) .. '\n'
        end
        return s

    end

}

--- Export

codeblock.Drone = setmetatable(Drone, drone_mt)
