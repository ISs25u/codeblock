CodeBlock
=========================

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![ContentDB](https://content.minetest.net/packages/giga-turbo/codeblock/shields/downloads/)](https://content.minetest.net/packages/giga-turbo/codeblock/)

**CodeBlock allows creating oniric structures in Minetest using `lua` code.**

**License:** GPLv3   
**Credits:** inspired by [Gnancraft](http://gnancraft.net/), [ComputerCraft](http://www.computercraft.info/), [Visual Bots](https://content.minetest.net/packages/Nigel/vbots/), [TurtleMiner](https://content.minetest.net/packages/BirgitLachner/turtleminer/), [basic_robot](https://github.com/ac-minetest/basic_robot)


![screenshot](screenshot.png)

## Tools usage

1. Create an empty (flat) world and enable `codeblock` mod ant its dependencies
2. Enable creative mode and start the game
3. Right click with the `drone_poser` tool on a block, choose a `lua` program to run, then left click to start the drone
4. Right click with the `drone_setter` tool to change which program your are using, or left click with it to stop and remove the drone
5. Write your own programs in `~/.minetest/worlds/<worldname>/codeblock_lua_files/<user>/<filename.lua>`, they will appear when right clicking with the `drone_setter`

## Authlevel

Drone capacity depends on the user's _authlevel_ which can be set with the `/authlevel` command (see below). The higher the authlevel the quicker is the drone and the heavier the load on the server. High authlevel should be given carefully to users. Default authlevel is 1.

| authlevel     | 1 (limited) | 2 (basic) | 3 (privileged) | 4 (trusted) |                                                                      |
|---------------|-------------|-----------|----------------|-------------|----------------------------------------------------------------------|
| max_calls     |         1e6 |       1e7 |            1e8 |         1e9 | max number of calls (function calls and loops)                       |
| max_volume    |         1e5 |       1e6 |            1e7 |         1e8 | max build volume (1 block = 1m³)                                     |
| max_commands  |         1e4 |       1e5 |            1e6 |         1e7 | max drone commands (movements, constructions, checkpoints, etc)      |
| max_distance  |         150 |       300 |            700 |        1500 | max drone distance from drone spawn-point                            |
| max_dimension |          15 |        30 |             70 |         150 | max dimension of shapes (either width or length or height or radius) |

## Chat commands

#### `/authlevel <playername> <1-4>`

Set the authlevel of an user. Requires the `codeblock` privilege (`/grant <user> codeblock`).

#### `/codeblock_examples`

Generates the examples programs in `~/.minetest/worlds/<worldname>/codeblock_lua_files/<user>/` for the user issuing the command.

## Lua api

The coordinate system used is relative to the player. When the drone is placed it is oriented in the player direction, going forwards. All movements on the 3 axis are always relative to the drone direction (left-right, up-down, forward-backward).

The parameters `nr`, `nu`, `nf` denotes movements on the 3 axis, positive values going right/up/forward and negative values going left/down/backward.


### Movements

#### Moving drone

```lua
up(n)
down(n)
forward(n)
back(n)
left(n)
right(n)
move(nr, nu, nf)
```

Example: `move(-5, 1, 3)`

#### Rotating drone

```lua
turn_right()
turn_left()
turn(n_quarters_anti_clockwise)
```

Example: `turn(2)`


#### Checkpoints

```lua
save(name)
go(name, nr, nu, nf)
```

Example:
```lua
save('place1')
save('place2')
go('place1', 10, -50, 1)
go('place2') -- same as go('place2', 0, 0, 0)
```

### Block types

Placing blocks and building shapes requires a `block` parameter, which can be obtained with the following tables.

#### `blocks`

String-indexed table with the following values:

```lua
air, stone, cobble, stonebrick, stone_block, mossycobble, desert_stone, desert_cobble, desert_stonebrick, desert_stone_block, sandstone, sandstonebrick, sandstone_block, desert_sandstone, desert_sandstone_brick, desert_sandstone_block, silver_sandstone, silver_sandstone_brick, silver_sandstone_block, obsidian, obsidianbrick, obsidian_block, dirt, dirt_with_grass, dirt_with_grass_footsteps, dirt_with_dry_grass, dirt_with_snow, dirt_with_rainforest_litter, dirt_with_coniferous_litter, dry_dirt, dry_dirt_with_dry_grass, permafrost, permafrost_with_stones, permafrost_with_moss, clay, snowblock, ice, cave_ice, tree, wood, leaves, jungletree, junglewood, jungleleaves, pine_tree, pine_wood, pine_needles, acacia_tree, acacia_wood, acacia_leaves, aspen_tree, aspen_wood, aspen_leaves, stone_with_coal, coalblock, stone_with_iron, steelblock, stone_with_copper, copperblock, stone_with_tin, tinblock, bronzeblock, stone_with_gold, goldblock, stone_with_mese, mese, stone_with_diamond, diamondblock, cactus, bush_leaves, acacia_bush_leaves, pine_bush_needles, bookshelf, glass, obsidian_glass, brick, meselamp
```

Example: `local b = blocks.glass`

#### `plants`

String-indexed table with the following values:

```lua
sapling, apple, junglesapling, emergent_jungle_sapling, pine_sapling, acacia_sapling, aspen_sapling, large_cactus_seedling, dry_shrub, grass_1, grass_2, grass_3, grass_4, grass_5, dry_grass_1, dry_grass_2, dry_grass_3, dry_grass_4, dry_grass_5, fern_1, fern_2, fern_3, marram_grass_1, marram_grass_2, marram_grass_3, bush_stem, bush_sapling, acacia_bush_stem, acacia_bush_sapling, pine_bush_stem, pine_bush_needles, pine_bush_sapling
```

Example: `local p = plants.large_cactus_seedling`

#### `wools`

String-indexed table with the following values:

```lua
white, grey, dark_grey, black, violet, blue, cyan, dark_green, green, yellow, brown, orange, red, magenta, pink
```

Example: `local rw = wools.red`

#### `iwools`

Integer-indexed table, without white, black and greys, in pseudo-rainbow order (`red`, `brown`, `orange`, `yellow`, `green`, `dark_green`, `cyan`, `blue`, `violet`, `magenta`, `pink`), with the following values:

```lua
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
```

Example: `local orange = iwools[3]`

#### `color(x, m, M)`

Experimental. Return a wool color corresponding to the intensity of `x` on the scale `m` to `M`. If `m` and `M` are not specified then `x` is considered to be between 1 and 11.
 
Example: `local c = color(15, 1, 100)`

### Construction

#### Placing one blocks

```lua
place(block)
place_relative(nr, nu, nf, block, checkpoint)
```

Example:
```lua
save('place2')
place(blocks.stone)
place_relative(1, 0, 0, wools.blue, 'place2')
place_relative(0, 1, 0, wools.green, 'place2')
place_relative(0, 0, 1, wools.red, 'place2')
```

#### Shapes

Shapes are placed such that the drone position corresponds to the back-bottom-left of the shape (a cube will extend to the right-up-forward direction). `width` extends in the "right" direction, `height` extends in the "up" direction, `length` extends in the "forward" direction and `radius` extends in the remaining directions. `hollow` is `false` by default and default `block` is stone.

```lua
cube(width, height, length, block, hollow)
sphere(radius, block, hollow)
dome(radius, block, hollow)
cylinder(height, radius, block, hollow) -- short for vertical.cylinder
vertical.cylinder(height, radius, block, hollow)
horizontal.cylinder(length, radius, block, hollow)
```

Example: `cylinder(10, 4, blocks.leaves)`

#### Centered shapes

Shapes are placed such that the drone position corresponds to the center of the shape. For the dome it corresponds to the bottom of the dome and its center for the other coordinates. `width` extends in the "left-right" direction, `height` extends in the "up-down" direction, `length` extends in the "forward-backward" direction and `radius` extends in the remaining directions.

```lua
centered.cube(width, height, length, block, hollow)
centered.sphere(radius, block, hollow)
centered.dome(radius, block, hollow)
centered.cylinder(height, radius, block, hollow) -- short for centered.vertical.cylinder
centered.vertical.cylinder(height, radius, block, hollow)
centered.horizontal.cylinder(length, radius, block, hollow)
```

### Math 

#### Functions

```lua
random([m [, n]])
round(x, num)
round0(x)   -- short for round(x, 0) (integer rounding)
ceil(x)
floor(x)
deg(x)
rad(x)
exp(x)
log(x)
max(x, ...)
min(x, ...)
abs(x)
pow(x, y)
sqrt(x)
sin(x)
asin(x)
sinh(x)
cos(x)
acos(x)
cosh(x)
tan(x)
atan(x)
atan2(x, y)
tanh(x)
```

#### Values

```lua
pi
e
```

#### Vectors

See documentation [here](https://github.com/ISs25u/vector3) (replacing `vector3` by `vector`).

Example:
```lua
local u = vector(1, 2, 3)
local v = vector3(4, 5, 6)
local w = (5 * u + u:dot(v) * u:cross(v:scale(5))):norm()
local x, y, z = w:unpack()
```

### Misc 

```lua
print(message)
error(message)
ipairs(t)
pairs(t)
```
