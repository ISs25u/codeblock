CodeBlock
=========================

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![ContentDB](https://content.minetest.net/packages/giga-turbo/codeblock/shields/downloads/)](https://content.minetest.net/packages/giga-turbo/codeblock/)

**CodeBlock allows creating oniric sturctures in Minetest using `lua` code.**

**License:** GPLv3   
**Credits:** inspired by [Gnancraft](http://gnancraft.net/), [ComputerCraft](http://www.computercraft.info/), [Visual Bots](https://content.minetest.net/packages/Nigel/vbots/), [TurtleMiner](https://content.minetest.net/packages/BirgitLachner/turtleminer/), [basic_robot](https://github.com/ac-minetest/basic_robot)


![screenshot](screenshot.png)

## Tools usage

1. Create an empty (flat) world and enable `codeblock` mod
2. Enable creative mode or give yourself the tools `codeblock:drone_placer` and `codeblock:drone_starter`
3. Right click with the `drone_placer` tool on a block, choose a `lua` program to run, then left click to start the drone
4. Left click with the `drone_starter` to change wich program your are using
5. Write your own programs in `~/.minetest/worlds/<worldname>/codeblock_lua_files/<user>/<filename.lua>`

## Lua api

### Movements

```lua
up(n)
down(n)
forward(n)
back(n)
left(n)
right(n)
move(right,forward,up)
turn_right()
turn_left()
turn(n_quarters)
```

Example: `forward(5)`

### Construction

__Individual blocks__

```lua
place(block)
place_relative(x, y, z, block, checkpoint_name)
```

__Primitives ("back-bottom-left" placed)__

```lua
cube(width, height, length, block, hollow)
sphere(radius, block, hollow)
dome(radius, block, hollow)
vertical.cylinder(height, radius, block, hollow)
horizontal.cylinder(length, radius, block, hollow)
```

__Centered primitives__

```lua
centered.cube(width, height, length, block, hollow)
centered.sphere(radius, block, hollow)
centered.dome(radius, block, hollow)
centered.vertical.cylinder(height, radius, block, hollow)
centered.horizontal.cylinder(length, radius, block, hollow)
```

### Types of blocks

`blocks`

```lua
air, stone, cobble, stonebrick, stone_block, mossycobble, desert_stone, desert_cobble, desert_stonebrick, desert_stone_block, sandstone, sandstonebrick, sandstone_block, desert_sandstone, desert_sandstone_brick, desert_sandstone_block, silver_sandstone, silver_sandstone_brick, silver_sandstone_block, obsidian, obsidianbrick, obsidian_block, dirt, dirt_with_grass, dirt_with_grass_footsteps, dirt_with_dry_grass, dirt_with_snow, dirt_with_rainforest_litter, dirt_with_coniferous_litter, dry_dirt, dry_dirt_with_dry_grass, permafrost, permafrost_with_stones, permafrost_with_moss, clay, snowblock, ice, cave_ice, tree, wood, leaves, jungletree, junglewood, jungleleaves, pine_tree, pine_wood, pine_needles, acacia_tree, acacia_wood, acacia_leaves, aspen_tree, aspen_wood, aspen_leaves, stone_with_coal, coalblock, stone_with_iron, steelblock, stone_with_copper, copperblock, stone_with_tin, tinblock, bronzeblock, stone_with_gold, goldblock, stone_with_mese, mese, stone_with_diamond, diamondblock, cactus, bush_leaves, acacia_bush_leaves, pine_bush_needles, bookshelf, glass, obsidian_glass, brick, meselamp
```

`plants`

```lua
sapling, apple, junglesapling, emergent_jungle_sapling, pine_sapling, acacia_sapling, aspen_sapling, large_cactus_seedling, dry_shrub, grass_1, grass_2, grass_3, grass_4, grass_5, dry_grass_1, dry_grass_2, dry_grass_3, dry_grass_4, dry_grass_5, fern_1, fern_2, fern_3, marram_grass_1, marram_grass_2, marram_grass_3, bush_stem, bush_sapling, acacia_bush_stem, acacia_bush_sapling, pine_bush_stem, pine_bush_needles, pine_bush_sapling
```

`wools`

```lua
white, grey, dark_grey, black, violet, blue, cyan, dark_green, green, yellow, brown, orange, red, magenta, pink
```

`iwools`

```lua
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
```

Example: 
```lua
place(blocks.stone)
up(1)
place(plants.acacia_bush_stem)
up(1)
place(wools.blue)
up(1)
place(iwools[3])
```

### Checkpoints

```lua
save(name)
go(name)
```

Example:
```lua
save('place1')
move(0, 1, 1)
place(wools.obsidian)
go('place1')
move(0, -1, -1)
place(wools.glass)
```

### Math 

```lua
random(a,b)
floor(x)
ceil(x)
deg(x)
rad(x)
exp(x)
log(x)
max(a,b)
min(a,b)
pow(a,b)
sqrt(x)
abs(x)
sin(x)
sinh(x)
asin(x)
cos(x)
cosh(x)
acos(x)
tan(x)
tanh(x)
atan(x)
atan2(x)
pi
```

### Misc 

```lua
print(message)
ipairs(array)
pairs(array)
```
