codeblock.examples = {}

codeblock.examples.recursion = [[
    function recursion(checkpoint, block_list, MAX_DEPTH, depth)

        local depth = depth or 1
    
        if depth > MAX_DEPTH then return end
    
        for j = 1, 4 do
            for i = 1, 10 do
    
                up(1)
                forward(1)
                place(block_list[(depth % #block_list) + 1])
    
            end
    
            save(checkpoint .. j .. depth)
            recursion(checkpoint .. j .. depth, block_list, MAX_DEPTH, depth + 1)
            go(checkpoint)
            turn_left()
            save(checkpoint)
    
        end
    
    end
    
    ---
    ---
    
    save('origin')
    local mblocks = {blocks.stone, blocks.dirt, blocks.obsidian, blocks.sandstone}
    recursion('origin', mblocks, #mblocks)    
]]

codeblock.examples.density = [[
local R = 10
local YMAX = 100

local scale_density = function(f, MIN, MAX)
    return function(x) return (f(x) - MIN) / (MAX - MIN) end
end

local f = function(x) return pow(x, 2) end
local density = scale_density(f, f(0), f(YMAX))

save('o')
for x = -R, R do
    for y = 0, YMAX do
        for z = -R, R do

            if (pow(x, 2) + pow(z, 2) < pow(R, 2)) then
                if random() < density(y) then
                    place_relative(x, y, z, blocks.stone, 'o')
                end
            end

        end
    end
end
]]

codeblock.examples.spirals = [[
    function spiral(TURNS, MAX_RADIUS, MAX_Y, BLOCK, ORIGIN)

        local increment = 0.01
    
        for a = 0, 2 * pi * TURNS, increment do
    
            local R = a / (2 * pi * TURNS) * MAX_RADIUS
            local x = R * cos(a)
            local y = a / (2 * pi * TURNS) * MAX_Y
            local z = R * sin(a)
    
            place_relative(x, y, z, BLOCK, ORIGIN)
            left()
            place(BLOCK)
            right()
            place(BLOCK)
            forward()
            place(BLOCK)
            back()
            place(BLOCK)
    
        end
    
    end
    
    --
    
    local mblocks = {
        blocks.sandstone, blocks.silver_sandstone, blocks.desert_sandstone
    }
    
    for i = 1, #mblocks do
        spiral(5, 25, 100, mblocks[i % (#mblocks + 1)], 'spiral' .. i)
        go('spiral' .. i)
        right(50)
    end
]]

codeblock.examples.plot2D = [[
    function plot2D(XMIN, XMAX, ZMIN, ZMAX, FMIN, FMAX, NPOINTS, f)

        local increment = (XMAX - XMIN) / (NPOINTS - 1)
    
        for nx = 1, NPOINTS do
            for nz = 1, NPOINTS do
                local x = XMIN + ((nx - 1) * increment)
                local z = ZMIN + ((nz - 1) * increment)
                local y = f(x, z)
    
                local color = floor((y - FMIN) / (FMAX - FMIN) * (#iwools - 1))
                local block = iwools[(color % #iwools) + 1]
    
                place_relative(nx - 1, 0, nz - 1, block)
            end
        end
    end
    
    f = function(x, z) return cos(x + pi / 2) * sin(z) end
    
    plot2D(-2 * pi, 2 * pi, -2 * pi, 2 * pi, -1, 1, 100, f)    
]]

codeblock.examples.plot3D = [[
    function plot3D(XMIN, XMAX, ZMIN, ZMAX, FMIN, FMAX, NPOINTS, H, f)

        local increment = (XMAX - XMIN) / (NPOINTS - 1)
    
        for nx = 1, NPOINTS do
            for nz = 1, NPOINTS do
                local x = XMIN + ((nx - 1) * increment)
                local z = ZMIN + ((nz - 1) * increment)
                local y = f(x, z)
                local h = floor((y - FMIN) / (FMAX - FMIN) * H)
    
                local color = floor((y - FMIN) / (FMAX - FMIN) * (#iwools - 1))
                local block = iwools[(color % #iwools) + 1]
    
                place_relative(nx - 1, h, nz - 1, block)
            end
        end
    end
    
    f = function(x, z) return cos(x + pi / 2) * sin(z) end
    
    plot3D(-2 * pi, 2 * pi, -2 * pi, 2 * pi, -1, 1, 100, 100, f)    
]]

codeblock.examples.menger = [[
    function menger(size, block)
        local function recursion(size, x, y, z)
    
            local inc = floor(size / 3)
    
            save('chpt_' .. size)
    
            if size == 1 then return end
    
            for nx = 0, size - 1, inc do
                for ny = 0, size - 1, inc do
                    for nz = 0, size - 1, inc do
    
                        if (nx == ny and nx == inc) or (ny == nz and nz == inc) or
                            (nz == nx and nx == inc) then
                            go('chpt_' .. size)
                            move(x + nx, y + ny, z + nz)
                            cube(inc, inc, inc, blocks.air)
                        else
                            go('chpt_' .. size)
                            recursion(inc, x + nx, y + ny, z + nz)
                        end
    
                    end
                end
            end
    
        end
    
        cube(size, size, size, block)
        recursion(size, 0, 0, 0)
    
    end
    
    --
    
    local sizes = {pow(3, 1), pow(3, 2), pow(3, 3), pow(3, 4)}
    
    up()
    for i, s in ipairs(sizes) do
        menger(s, iwools[i])
        right(s + 3)
    end  
]]

codeblock.examples.forest = [[
    function forest(radius)
        local function tree(HMIN, HMAX)
    
            local H = random(HMIN, HMAX)
            local W = random(floor(HMIN * 0.5), floor(HMIN * 0.6))
            local R = floor(W / 2)
            local D = 3
    
            cube(1, H, 1, blocks.wood)
            up(H)
            cube(W + 1, 1, 1, blocks.wood)
            right(W)
            down(D)
            cube(1, D, 1, blocks.wood)
    
            move(-R, -2 * R, -R)
            sphere(R, blocks.meselamp)
            sphere(R, blocks.leaves, true)
        end
    
        --
    
        local HMIN = 8
        local HMAX = 12
        local SPACING = floor(HMAX * 0.6 * 2.2)
    
        save('o')
        for i = -radius, radius, SPACING do
            for j = -radius, radius, SPACING do
    
                if sqrt(i * i + j * j) < radius then
                    go('o')
                    move(i + random(-5, 5), 0, j + random(-5, 5))
                    turn(random(0, 3))
                    tree(HMIN, HMAX)
                end
    
            end
        end
    
    end
    
    forest(100)
]]

codeblock.examples.death_star = [[
    local R1 = 30
    local R2 = R1
    
    local mvt = vector.new(-1, -1, -1)
    local pos = vector.floor(vector.multiply(vector.normalize(mvt), 0.95 * (R1 + R2)))
    
    up(2 * R1 + R2)
    save('center')
    centered.sphere(R1, wools.grey)
    centered.sphere(R1 - 1, wools.cyan)
    
    move(pos.x, pos.y, pos.z)
    centered.sphere(R2, blocks.air)
    
    go('center')
    for i = 1, 200, 1 do
        centered.sphere(2, blocks.meselamp)
        move(mvt.x, mvt.y, mvt.z)
    end    
]]

codeblock.examples.planet = [[
    local R1 = 100

    up(2 * R1)
    save('center')
    centered.sphere(R1, blocks.desert_sandstone)
    centered.sphere(R1 - 2, blocks.silver_sandstone)
    local vcenter = vector.new(0, 0, 0)
    
    for i = 1, 200 do
    
        local theta = random() * pi
        local phi = random() * 2 * pi
        local r = random(5, 20)
    
        local vrandom = vector.new(r * cos(phi) * sin(theta), r * sin(phi) * sin(theta),
                             r * cos(theta))
        local pos = vector.multiply(vector.direction(vcenter, vrandom), (R1 + r) * 0.95)
    
        go('center')
        move(pos.x, pos.y, pos.z)
        centered.sphere(r, blocks.air)
    
    end
]]

codeblock.examples.tests = [[
    local funs = {
        function() place(blocks.obsidian) end,
        function() place_relative(1, 1, 1, wools.cyan, _) end,
        function() cube(_, _, _, wools.yellow) end,
        function() sphere(_, wools.green) end, function() dome(_, wools.blue) end,
        function() vertical.cylinder(_, _, wools.red) end,
        function() horizontal.cylinder(_, _, wools.orange) end,
        function() centered.vertical.cylinder(_, _, wools.white) end,
        function() centered.horizontal.cylinder(_, _, wools.magenta) end,
        function() centered.cube(_, _, _, wools.black) end,
        function() centered.sphere(5, wools.pink) end,
        function() centered.dome(5, wools.violet) end
    }
    
    for _, fun in ipairs(funs) do
        fun()
        right(15)
    end
    
    move(1, 1, 1)
    forward(5)
    back(6)
    left(2)
    right(3)
    up(6)
    down(1)
    turn_left()
    turn_right()
    turn(4)
    save('chk')
    go('chk')    
]]

codeblock.examples.maze = [[
    function getRule(...)

        local rules = {}
        local arg = {...}
        for _, c in ipairs(arg) do rules[c] = true end
    
        return rules
    
    end
    
    -- parameters
    
    local W = 30
    local H = W
    local neighs = {
        {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
    }
    local rulesB = getRule(3)
    local rulesS = getRule(1, 2, 3, 4)
    local scale = 1
    local density = 0.1
    local iter = 300
    
    -- functions
    
    function genMat(density)
    
        local mat = {}
    
        for i = 1, W do
            for j = 1, H do
                if random() < density then mat[j * W + i] = true end
            end
        end
    
        return mat
    
    end
    
    function evolve(mat)
    
        local nmat = {}
    
        function neighbors(i, j)
    
            local n = 0
            local ni, nj
            for _, nn in ipairs(neighs) do
                ni = i + nn[1]
                nj = j + nn[2]
                if ni >= 1 and ni <= W and nj >= 1 and nj <= H then
                    if mat[nj * W + ni] then n = n + 1 end
                end
    
            end
            return n
    
        end
    
        for i = 1, W do
            for j = 1, H do
                local alive = mat[j * W + i]
                local count = neighbors(i, j)
                if alive then
                    if rulesS[count] then nmat[j * W + i] = true end
                else
                    if rulesB[count] then nmat[j * W + i] = true end
                end
    
            end
        end
    
        return nmat
    
    end
    
    function plot(mat, build_block)
    
        save('laborigin')
        local build_block = build_block or blocks.leaves
    
        for i = 1, W do
            for j = 1, H do
                go('laborigin')
                move((i - 1) * scale, 0, (j - 1) * scale)
                cube(scale, scale, scale,
                     mat[j * W + i] and build_block or blocks.air)
            end
        end
    
        go('laborigin')
    
    end
    
    -- 
    
    local mat = genMat(density)
    for i = 1, iter do mat = evolve(mat) end
    
    up()
    plot(mat)
]]


-- codeblock.examples.exampleN = [[

-- ]]