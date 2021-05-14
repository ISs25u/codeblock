codeblock.drone = {}

local drones = {}


function codeblock.drone:new(ref)
    -- generate random name or ID
    ref = ref or {x=0, y=0, z=0}
    setmetatable(ref,self) -- self is codeblock.drone 
    self.__index = self 
    -- add to drones

    return ref
end

function codeblock.drone:forward(n)
    self.z = self.z + n
    return self
end

function codeblock.drone:rotate_left(n)
    return self
end

function codeblock.drone:rotate_right(n)
    return self
end