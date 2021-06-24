codeblock.Drone = {}

function codeblock.Drone:new(pos, dir, name, file)

    drone = {
        name = name,
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
    setmetatable(drone, self)
    self.__index = self
    return drone

end