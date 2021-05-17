codeblock.Drone = {}

function codeblock.Drone:new(pos, dir, name, file)

    drone = {
        x = pos.x or 0,
        y = pos.y or 0,
        z = pos.z or 0,
        dir = dir or 0,
        checkpoints = {},
        name = name,
        file = file
    }

    drone.checkpoints['start'] = {x = drone.x, y = drone.y, z = drone.z}
    setmetatable(drone, self)
    self.__index = self
    return drone
end

function codeblock.Drone:set_pos(pos)
    self.x = pos.x
    self.y = pos.y
    self.z = pos.z
    return self
end

function codeblock.Drone:set_dir(dir)
    self.dir = dir
    return self
end

function codeblock.Drone:set_file(file)
    self.file = file
    return self
end