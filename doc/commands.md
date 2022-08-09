# Moving the drone

`up(n)`
`down(n)`
`forward(n)`
`back(n)`
`left(n)`
`right(n)`
`move(n_right, n_up, n_forward)`

# Rotating the drone

`turn_right()`
`turn_left()`
`turn(n_quarters_anti_clockwise)`

# Checkpoints

`save(name)`
`go(name, n_right, n_up, n_forward)`

# Random blocks

`random.block()`
`random.plant()`
`random.wool()`

# Block at drone position

`get_block()`

# Placing one block

`place(block)`
`place_relative(n_right, n_up, n_forward, block, checkpoint)`

# Shapes

`cube(width, height, length, block, hollow)`
`sphere(radius, block, hollow)`
`dome(radius, block, hollow)`
`cylinder(height, radius, block, hollow)`
`vertical.cylinder(height, radius, block, hollow)`
`horizontal.cylinder(length, radius, block, hollow)`

# Centered shapes

`centered.cube(width, height, length, block, hollow)`
`centered.sphere(radius, block, hollow)`
`centered.dome(radius, block, hollow)`
`centered.cylinder(height, radius, block, hollow)`
`centered.vertical.cylinder(height, radius, block, hollow)`
`centered.horizontal.cylinder(length, radius, block, hollow)`

# Math

`random([m [, n]])`
`round(x, num)`
`round0(x)`
`ceil(x)`
`floor(x)`
`deg(x)`
`rad(x)`
`exp(x)`
`log(x)`
`max(x, ...)`
`min(x, ...)`
`abs(x)`
`pow(x, y)`
`sqrt(x)`
`sin(x)`
`asin(x)`
`sinh(x)`
`cos(x)`
`acos(x)`
`cosh(x)`
`tan(x)`
`atan(x)`
`atan2(x, y)`
`tanh(x)`
`pi`
`e`

# Misc

`print(message)`
`error(message)`
`ipairs(table)`
`pairs(table)`
`table.randomizer(t)`
`type(v)`
`--include lua_file_name`

# Vectors

`See https://github.com/ISs25u/vector3 for details`

Operations + - * /

`vector(x, y, z)`
`vector.fromSpherical(r, theta, phi)`
`vector.fromCylindrical(r, phi, y)`
`vector.fromPolar(r, phi)`
`vector.srandom(a, b)`
`vector.crandom(a, b, c, d)`
`vector.prandom(a, b)`
`v1:clone()`
`v1:length()`
`v1:norm()`
`v1:scale(x)`
`v1:limit(x)`
`v1:floor()`
`v1:round()`
`v1:set(x, y, z)`
`v1:offset(ox, oy, oz)`
`v1:apply(f)`
`v1:dist(v2)`
`v1:dot(v2)`
`v1:cross(v2)`
`v1:rotate_around(v, angle)`
`v1:unpack()`
