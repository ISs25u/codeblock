local Drone = {}
Drone.__index = Drone

function Drone:new(pos, dir, name, file)

    local drone = {
        name = name or '',
        x = pos.x or 0,
        y = pos.y or 0,
        z = pos.z or 0,
        dir = dir or 0,
        checkpoints = {},
        file = file,
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

    return setmetatable(drone, Drone)

end

local topi = 2 / math.pi
local ttpi = 2 * math.pi

function Drone:angle() return topi * (self.dir % ttpi) end

codeblock.Drone = setmetatable(Drone, {
    __call = function(self, ...) return self:new(...) end
})
