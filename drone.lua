codeblock.Drone = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S
local pi = math.pi

local tmp1 = 2 / pi
local tmp2 = 2 * pi

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
                        self.file
                });
            end
        end,

        angle = function(self) return tmp1 * (self.dir % tmp2) end

    }
}

local drone_mt = {

    __call = function(self, name, pos, dir, file)

        assert(name)
        assert(pos)

        local drone = {
            name = name,
            x = pos.x,
            y = pos.y,
            z = pos.z,
            dir = dir or 0,
            file = file,
            checkpoints = {},
            volume = 0,
            cor = nil,
            obj = nil
        }

        drone.checkpoints['start'] = {
            x = drone.x,
            y = drone.y,
            z = drone.z,
            dir = drone.dir
        }

        setmetatable(drone, instance_mt)

        drone.obj = minetest.add_entity(pos, "codeblock:drone", nil)
        drone.obj:set_rotation({x = 0, y = dir, z = 0})
        drone.obj:get_luaentity().owner = name
        drone.obj:get_luaentity()._data = drone

        Drone[name] = drone

        return drone

    end,

    __index = function(self, k)

        local d = rawget(self.instances, k)

        if d ~= nil and d.obj == nil then
            return rawset(self.instances, k, nil)
        end

        return d

    end,

    __newindex = function(self, k, v)

        local d = rawget(self.instances, k)

        if d ~= nil and d.obj ~= nil then

            d.obj:remove()
            return rawset(self.instances, k, v)

        end

        return rawset(self.instances, k, v)

    end,

    __tostring = function(self)

        local s = ''
        for k, v in pairs(self.instances) do
            s = s .. k .. ': ' .. tostring(v) .. '\n'
        end
        return s

    end

}

--- Export

codeblock.Drone = setmetatable(Drone, drone_mt)
