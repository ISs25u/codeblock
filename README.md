CodeBlock
=========================

![screenshot](screenshot.png)

CodeBlock allows creating oniric sturctures in Minetest using `lua` code.

**License:** GNU GENERAL PUBLIC LICENSE V3   
**Credits:** inspired by [Gnancraft](http://gnancraft.net/), [ComputerCraft](http://www.computercraft.info/), [Visual Bots](https://content.minetest.net/packages/Nigel/vbots/), [TurtleMiner](https://content.minetest.net/packages/BirgitLachner/turtleminer/)


## TODO

- [x] User associated filesystem to store programs (high priority)
- [x] Allow to set drone's file with in-game interface + remember last program started (high priority)
- [ ] Blockly web-based editor (high priority)
- [ ] Control drone operating speed (medium priority)
- [ ] Only use 1 tool to manage the drone (medium priority)
- [ ] In-game lua code editor (low priority)

- [ ] relative positioning
- [ ] default drone move by 1
- [ ] use minetest.write
- [ ] remove error() when possible
- [ ] only 1 drone per player and always exists
- [ ] register player join/leaver gives drone, etc
- [ ] safe formspecs
- [ ] check compatible versions of minetest
- [x] drone label with program
- [ ] remove drone on leave

## Tools usage

1. Create an empty (flat) world and activate `codeblock` mod
2. Enable creative mode and give yourself the tools `codeblock:drone_placer` and `codeblock:drone_starter`
3. Right click with the drone_placer tool on a block, choose a `lua` file to run, then left click to start the drone (you should have `example_1.lua` available)
4. Create your own lua file in `~/.minetest/worlds/<worldname>/codeblock_lua_files/<newfile.lua>`
4. Left click with the drone_starter to change wich file your are using

## Lua api

### Moves

```lua
up(n)
down(n)
forward(n)
back(n)
turn_right()
turn_left()
```

Example: `forward(5)`

### Blocks

```lua
place(block)
```

```lua
blocks = {stone, cobble, stonebrick, stone_block, mossycobble, desert_stone, desert_cobble, desert_stonebrick, desert_stone_block, sandstone, sandstonebrick, sandstone_block, desert_sandstone, desert_sandstone_brick, desert_sandstone_block, silver_sandstone, silver_sandstone_brick, silver_sandstone_block, obsidian, obsidianbrick, obsidian_block, dirt, dirt_with_grass, dirt_with_grass_footsteps, dirt_with_dry_grass, dirt_with_snow, dirt_with_rainforest_litter, dirt_with_coniferous_litter, dry_dirt, dry_dirt_with_dry_grass, permafrost, permafrost_with_stones, permafrost_with_moss, clay, snowblock, ice, cave_ice, tree, wood, leaves, jungletree, junglewood, jungleleaves, pine_tree, pine_wood, pine_needles, acacia_tree, acacia_wood, acacia_leaves, aspen_tree, aspen_wood, aspen_leaves, stone_with_coal, coalblock, stone_with_iron, steelblock, stone_with_copper, copperblock, stone_with_tin, tinblock, bronzeblock, stone_with_gold, goldblock, stone_with_mese, mese, stone_with_diamond, diamondblock, cactus, bush_leaves, acacia_bush_leaves, pine_bush_needles, bookshelf, glass, obsidian_glass, brick, meselamp}
```

```lua
plants = {sapling, apple, junglesapling, emergent_jungle_sapling, pine_sapling, acacia_sapling, aspen_sapling, large_cactus_seedling, dry_shrub, grass_1, grass_2, grass_3, grass_4, grass_5, dry_grass_1, dry_grass_2, dry_grass_3, dry_grass_4, dry_grass_5, fern_1, fern_2, fern_3, marram_grass_1, marram_grass_2, marram_grass_3, bush_stem, bush_sapling, acacia_bush_stem, acacia_bush_sapling, pine_bush_stem, pine_bush_needles, pine_bush_sapling}
```
```lua
wools = {white_wool, grey_wool, dark_grey_wool, black_wool, violet_wool, blue_wool, cyan_wool, dark_green_wool, green_wool, yellow_wool, brown_wool, orange_wool, red_wool, magenta_wool, pink_wool}
```

Example: `place(blocks.stone)`

### Checkpoints

```lua
save(name)
go(name)
```

Example:
```lua
save('place1') 
go('place1')
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
cos(x)
tan(x)
pi
```

### Misc 

```lua
print(message)
ipairs(array)
pairs(array)
```
