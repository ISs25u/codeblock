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
function spiral(TURNS, MAX_RADIUS, MAX_Y, BLOCK)

    save('origin')

    local MAX_PHI = 2 * pi * TURNS

    local phi = 0
    local R, y, pos, lpos, p
    while phi < MAX_PHI do

        p = phi / MAX_PHI
        R = (p * (MAX_RADIUS - 0.5)) + 0.5
        y = p * MAX_Y
        pos = vector.fromCylindrical(R, phi, y):round()

        if pos ~= lpos then
            place_relative(pos.x, pos.y, pos.z, BLOCK, 'origin')
            lpos = pos
        end

        phi = phi + 1 / (2 * pi * R)

    end

    go('origin')

end

--

local mblocks = {
    blocks.sandstone, blocks.silver_sandstone, blocks.desert_sandstone
}

for i = 1, #mblocks do
    spiral(5, 25, 100, mblocks[i])
    right(50)
end
]]

codeblock.examples.plot2D = [[
function plot2D(XMIN, XMAX, ZMIN, ZMAX, FMIN, FMAX, NPOINTS, SIZE, fun)

    local increment = (XMAX - XMIN) / (NPOINTS - 1)

    local rx, ry, rz, y
    for x = XMIN, XMAX, increment do
        for z = ZMIN, ZMAX, increment do

            y = fun(x, z)

            rx = (x - XMIN) / (XMAX - XMIN) * SIZE
            ry = 0
            rz = (z - ZMIN) / (ZMAX - ZMIN) * SIZE

            place_relative(rx, ry, rz, color(y, FMIN, FMAX))

        end
    end
end

fun = function(x, z) return cos(x + pi / 2) * sin(z) end

plot2D(-2 * pi, 2 * pi, -2 * pi, 2 * pi, -1, 1, 101, 100, fun)       
]]

codeblock.examples.plot3D = [[
function plot3D(XMIN, XMAX, ZMIN, ZMAX, FMIN, FMAX, NPOINTS, SIZE, fun)

    local visited = {}
    for x = 1, NPOINTS do
        for y = 1, NPOINTS do
            for z = 1, NPOINTS do
                visited[x + y * NPOINTS + z * NPOINTS ^ 2] = false
            end
        end
    end

    local increment = (XMAX - XMIN) / (NPOINTS - 1)
    local rx, ry, rz, y, i
    for x = XMIN, XMAX, increment do
        for z = ZMIN, ZMAX, increment do

            y = fun(x, z)

            rx = round0((x - XMIN) / (XMAX - XMIN) * SIZE)
            ry = round0((y - FMIN) / (FMAX - FMIN) * SIZE / 2)
            rz = round0((z - ZMIN) / (ZMAX - ZMIN) * SIZE)

            i = (rx - XMIN) / NPOINTS + (ry - FMIN) / NPOINTS * NPOINTS +
                    (rz - ZMIN) / NPOINTS * NPOINTS * NPOINTS + 3
            if not visited[i] then
                place_relative(rx, ry, rz, color(y, FMIN, FMAX))
                visited[i] = true
            end

        end
    end
end

fun = function(x, z) return cos(x + pi / 2) * sin(z) end

plot3D(-2 * pi, 2 * pi, -2 * pi, 2 * pi, -1, 1, 300, 100, fun)
]]

codeblock.examples.menger = [[
function menger(size, block)

    local empty_pos = {}
    local solid_pos = {}
    for nx = 0, 2, 1 do
        for ny = 0, 2, 1 do
            for nz = 0, 2, 1 do

                if (nx == ny and nx == 1) or (ny == nz and nz == 1) or
                    (nz == nx and nx == 1) then
                    empty_pos[#empty_pos + 1] = {nx, ny, nz}
                else
                    solid_pos[#solid_pos + 1] = {nx, ny, nz}
                end

            end
        end
    end

    local function recursion(size, x, y, z)

        local inc = floor(size / 3)
        if size == 1 then return end

        for _, n in ipairs(empty_pos) do
            go('origin', x + n[1] * inc, y + n[2] * inc, z + n[3] * inc)
            cube(inc, inc, inc, blocks.air)
        end

        for _, n in ipairs(solid_pos) do
            recursion(inc, x + n[1] * inc, y + n[2] * inc, z + n[3] * inc)
        end

    end

    save('origin')
    cube(size, size, size, block)
    recursion(size, 0, 0, 0)
    go('origin')

end

--

local sizes = {pow(3, 3), pow(3, 2), pow(3, 1), pow(3, 0)}

up()
for i, size in ipairs(sizes) do menger(size, iwools[i]) end
]]

codeblock.examples.mosely = [[
function mosely(size, block)

    local empty_pos = {}
    local solid_pos = {}
    local s, m, M
    for nx = 0, 2, 1 do
        for ny = 0, 2, 1 do
            for nz = 0, 2, 1 do
                s = nx + ny + nz
                m = min(nx, ny, nz)
                M = max(nx, ny, nz)
                if s == 0 or s == 6 or (s == 2 and M == 2) or
                    (s == 3 and M == 1) or (s == 4 and m == 0) then
                    empty_pos[#empty_pos + 1] = {nx, ny, nz}
                else
                    solid_pos[#solid_pos + 1] = {nx, ny, nz}
                end

            end
        end
    end

    local function recursion(size, x, y, z)

        local inc = floor(size / 3)
        if size == 1 then return end

        for _, n in ipairs(empty_pos) do
            go('origin', x + n[1] * inc, y + n[2] * inc, z + n[3] * inc)
            cube(inc, inc, inc, blocks.air)
        end

        for _, n in ipairs(solid_pos) do
            recursion(inc, x + n[1] * inc, y + n[2] * inc, z + n[3] * inc)
        end

    end

    save('origin')
    cube(size, size, size, block)
    recursion(size, 0, 0, 0)
    go('origin')

end

--

up()
mosely(pow(3,4), blocks.snowblock)
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

local mvt = vector(-1, -1, -1)
local pos = mvt:scale(0.95 * (R1 + R2)):floor()

up(2 * R1 + R2)
save('center')
centered.sphere(R1, wools.grey)
centered.sphere(R1 - 1, wools.cyan)

move(pos.x, pos.y, pos.z)
centered.sphere(R2, blocks.air)

go('center')
for i = 1, 2 * R1 + R2, 1 do
    centered.sphere(2, blocks.meselamp)
    move(mvt.x, mvt.y, mvt.z)
end    
]]

codeblock.examples.planet = [[
local R = 30

up(R * 2)
save('center')
centered.sphere(R, wools.grey)
centered.sphere(R - 1, wools.black)

local r, pos
for i = 1, R do
    r = random(round0(R / 3), round0(R / 2))
    pos = vector.srandom(1, 1):scale(R + 0.90 * r)
    go('center', pos.x, pos.y, pos.z)
    centered.sphere(r, blocks.air)
end

local v
for i = 1, round0(R * R / 3) do
    v = vector.prandom(round0(R * 2), round0(R * 3)):rotate_around(vector.xz, pi / 6)
    go('center', v.x, v.y, v.z)
    centered.sphere(random(1, 2), blocks.obsidian)
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

codeblock.examples.torus = [[
local r = 10
local R = 30

up(R + r)
save('o')

local v
local vy = vector.y
local vz = vector.z
local vx = vector.x
for A = 0, 2 * pi, 1 / (R + r) / 2 do
    for a = 0, 2 * pi, 1 / r do
        v = vector.fromPolar(r, a):rotate_around(vz, pi / 2):offset(0, 0, R)
        v = v:rotate_around(vy, A)
        place_relative(v.x, v.y, v.z, blocks.desert_sandstone, 'o')
    end

end

for A = 0, 2 * pi, 1 / (R + r) / 2 do
    for a = 0, 2 * pi, 1 / r do
        v = vector.fromPolar(r, a):offset(0, 0, R)
        v = v:rotate_around(vx, A):offset(0, 0, R)
        place_relative(v.x, v.y, v.z, blocks.obsidian, 'o')
    end
end
]]

codeblock.examples.donuts = [[
function wavy_donut(r, R, H, block)

    save('origin')

    local v
    local vx = vector.x
    local vy = vector.y
    local vz = vector.z
    local visited = {}
    local h = round0(0.5 * r)
    for x = -R - r, R + r do
        visited[x] = {}
        for y = -r - h, r + h do
            visited[x][y] = {}
            for z = -R - r, R + r do visited[x][y][z] = false end
        end
    end

    for A = 0, 2 * pi, 1 / (R + r) / 2 do
        for a = 0, 2 * pi, 1 / r do

            v = vector.fromPolar(r, a):rotate_around(vz, pi / 2):offset(0, 0, R)
            v = v:rotate_around(vy, A):offset(0, r * 0.5 * sin(H * A), 0)
                    :round()

            if not visited[v.x][v.y][v.z] then
                place_relative(v.x, v.y, v.z, block, 'origin')
                visited[v.x][v.y][v.z] = true
            end

        end

    end

    go('origin')

end

--

local r = 6
local R = 15

save('grid')
local h = 3
for nx = 0, 2 do
    for nz = 0, 2 do
        go('grid', nx * 2 * (R + r + 2) + 30, 2 * r, nz * 2 * (r + R + 2))
        wavy_donut(r, R, h, color(h))
        h = h + 1
    end
end
]]

-- codeblock.examples.exampleN = [[

-- ]]
