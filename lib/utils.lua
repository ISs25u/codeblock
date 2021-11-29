codeblock.utils = {}

local auth_levels = codeblock.config.auth_levels
local default_auth_level = codeblock.config.default_auth_level
local is_wool_enabled = codeblock.is_wool_enabled

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

function codeblock.utils.check_auth_level(auth_level)
    if type(auth_level) == 'number' and auth_levels[auth_level] ~= nil then
        return true, auth_level
    else
        return false, default_auth_level
    end
end

function codeblock.utils.split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function codeblock.utils.table_reverse(tbl)
    local rev = {}
    for k, v in pairs(tbl) do rev[v] = k end
    return rev
end

function codeblock.utils.table_convert_ik(tbl)
    local itable = {}
    for k, v in pairs(tbl) do table.insert(itable, k) end
    table.sort(itable)
    return itable
end

function codeblock.utils.table_convert_iv(tbl)
    local itable = {}
    for k, v in pairs(tbl) do table.insert(itable, v) end
    table.sort(itable)
    return itable
end

function codeblock.utils.table_randomizer(tbl)
    local keys = {}
    local random = math.random
    for k in pairs(tbl) do table.insert(keys, k) end
    return function() return tbl[keys[random(#keys)]] end
end

--------------------------------------------------------------------------------
-- Allowed blocks
--------------------------------------------------------------------------------

codeblock.utils.blocks = {
    air = 'air',
    stone = 'default:stone',
    cobble = 'default:cobble',
    stonebrick = 'default:stonebrick',
    stone_block = 'default:stone_block',
    mossycobble = 'default:mossycobble',
    desert_stone = 'default:desert_stone',
    desert_cobble = 'default:desert_cobble',
    desert_stonebrick = 'default:desert_stonebrick',
    desert_stone_block = 'default:desert_stone_block',
    sandstone = 'default:sandstone',
    sandstonebrick = 'default:sandstonebrick',
    sandstone_block = 'default:sandstone_block',
    desert_sandstone = 'default:desert_sandstone',
    desert_sandstone_brick = 'default:desert_sandstone_brick',
    desert_sandstone_block = 'default:desert_sandstone_block',
    silver_sandstone = 'default:silver_sandstone',
    silver_sandstone_brick = 'default:silver_sandstone_brick',
    silver_sandstone_block = 'default:silver_sandstone_block',
    obsidian = 'default:obsidian',
    obsidianbrick = 'default:obsidianbrick',
    obsidian_block = 'default:obsidian_block',
    dirt = 'default:dirt',
    dirt_with_grass = 'default:dirt_with_grass',
    dirt_with_grass_footsteps = 'default:dirt_with_grass_footsteps',
    dirt_with_dry_grass = 'default:dirt_with_dry_grass',
    dirt_with_snow = 'default:dirt_with_snow',
    dirt_with_rainforest_litter = 'default:dirt_with_rainforest_litter',
    dirt_with_coniferous_litter = 'default:dirt_with_coniferous_litter',
    dry_dirt = 'default:dry_dirt',
    dry_dirt_with_dry_grass = 'default:dry_dirt_with_dry_grass',
    permafrost = 'default:permafrost',
    permafrost_with_stones = 'default:permafrost_with_stones',
    permafrost_with_moss = 'default:permafrost_with_moss',
    clay = 'default:clay',
    snowblock = 'default:snowblock',
    ice = 'default:ice',
    cave_ice = 'default:cave_ice',
    tree = 'default:tree',
    wood = 'default:wood',
    leaves = 'default:leaves',
    jungletree = 'default:jungletree',
    junglewood = 'default:junglewood',
    jungleleaves = 'default:jungleleaves',
    pine_tree = 'default:pine_tree',
    pine_wood = 'default:pine_wood',
    pine_needles = 'default:pine_needles',
    acacia_tree = 'default:acacia_tree',
    acacia_wood = 'default:acacia_wood',
    acacia_leaves = 'default:acacia_leaves',
    aspen_tree = 'default:aspen_tree',
    aspen_wood = 'default:aspen_wood',
    aspen_leaves = 'default:aspen_leaves',
    stone_with_coal = 'default:stone_with_coal',
    coalblock = 'default:coalblock',
    stone_with_iron = 'default:stone_with_iron',
    steelblock = 'default:steelblock',
    stone_with_copper = 'default:stone_with_copper',
    copperblock = 'default:copperblock',
    stone_with_tin = 'default:stone_with_tin',
    tinblock = 'default:tinblock',
    bronzeblock = 'default:bronzeblock',
    stone_with_gold = 'default:stone_with_gold',
    goldblock = 'default:goldblock',
    stone_with_mese = 'default:stone_with_mese',
    mese = 'default:mese',
    stone_with_diamond = 'default:stone_with_diamond',
    diamondblock = 'default:diamondblock',
    cactus = 'default:cactus',
    bush_leaves = 'default:bush_leaves',
    acacia_bush_leaves = 'default:acacia_bush_leaves',
    pine_bush_needles = 'default:pine_bush_needles',
    bookshelf = 'default:bookshelf',
    glass = 'default:glass',
    obsidian_glass = 'default:obsidian_glass',
    brick = 'default:brick',
    meselamp = 'default:meselamp',
    sapling = 'default:sapling',
    apple = 'default:apple',
    junglesapling = 'default:junglesapling',
    emergent_jungle_sapling = 'default:emergent_jungle_sapling',
    pine_sapling = 'default:pine_sapling',
    acacia_sapling = 'default:acacia_sapling',
    aspen_sapling = 'default:aspen_sapling',
    large_cactus_seedling = 'default:large_cactus_seedling',
    dry_shrub = 'default:dry_shrub',
    junglegrass = 'default:junglegrass',
    grass_1 = 'default:grass_1',
    grass_2 = 'default:grass_2',
    grass_3 = 'default:grass_3',
    grass_4 = 'default:grass_4',
    grass_5 = 'default:grass_5',
    dry_grass_1 = 'default:dry_grass_1',
    dry_grass_2 = 'default:dry_grass_2',
    dry_grass_3 = 'default:dry_grass_3',
    dry_grass_4 = 'default:dry_grass_4',
    dry_grass_5 = 'default:dry_grass_5',
    fern_1 = 'default:fern_1',
    fern_2 = 'default:fern_2',
    fern_3 = 'default:fern_3',
    marram_grass_1 = 'default:marram_grass_1',
    marram_grass_2 = 'default:marram_grass_2',
    marram_grass_3 = 'default:marram_grass_3',
    bush_stem = 'default:bush_stem',
    bush_sapling = 'default:bush_sapling',
    acacia_bush_stem = 'default:acacia_bush_stem',
    acacia_bush_sapling = 'default:acacia_bush_sapling',
    pine_bush_stem = 'default:pine_bush_stem',
    pine_bush_sapling = 'default:pine_bush_sapling',
    wool_white = is_wool_enabled and 'wool:white' or nil,
    wool_grey = is_wool_enabled and 'wool:grey' or nil,
    wool_dark_grey = is_wool_enabled and 'wool:dark_grey' or nil,
    wool_black = is_wool_enabled and 'wool:black' or nil,
    wool_violet = is_wool_enabled and 'wool:violet' or nil,
    wool_blue = is_wool_enabled and 'wool:blue' or nil,
    wool_cyan = is_wool_enabled and 'wool:cyan' or nil,
    wool_dark_green = is_wool_enabled and 'wool:dark_green' or nil,
    wool_green = is_wool_enabled and 'wool:green' or nil,
    wool_yellow = is_wool_enabled and 'wool:yellow' or nil,
    wool_brown = is_wool_enabled and 'wool:brown' or nil,
    wool_orange = is_wool_enabled and 'wool:orange' or nil,
    wool_red = is_wool_enabled and 'wool:red' or nil,
    wool_magenta = is_wool_enabled and 'wool:magenta' or nil,
    wool_pink = is_wool_enabled and 'wool:pink' or nil
}

codeblock.utils.cubes_names = {
    air = 'air',
    stone = 'stone',
    cobble = 'cobble',
    stonebrick = 'stonebrick',
    stone_block = 'stone_block',
    mossycobble = 'mossycobble',
    desert_stone = 'desert_stone',
    desert_cobble = 'desert_cobble',
    desert_stonebrick = 'desert_stonebrick',
    desert_stone_block = 'desert_stone_block',
    sandstone = 'sandstone',
    sandstonebrick = 'sandstonebrick',
    sandstone_block = 'sandstone_block',
    desert_sandstone = 'desert_sandstone',
    desert_sandstone_brick = 'desert_sandstone_brick',
    desert_sandstone_block = 'desert_sandstone_block',
    silver_sandstone = 'silver_sandstone',
    silver_sandstone_brick = 'silver_sandstone_brick',
    silver_sandstone_block = 'silver_sandstone_block',
    obsidian = 'obsidian',
    obsidianbrick = 'obsidianbrick',
    obsidian_block = 'obsidian_block',
    dirt = 'dirt',
    dirt_with_grass = 'dirt_with_grass',
    dirt_with_grass_footsteps = 'dirt_with_grass_footsteps',
    dirt_with_dry_grass = 'dirt_with_dry_grass',
    dirt_with_snow = 'dirt_with_snow',
    dirt_with_rainforest_litter = 'dirt_with_rainforest_litter',
    dirt_with_coniferous_litter = 'dirt_with_coniferous_litter',
    dry_dirt = 'dry_dirt',
    dry_dirt_with_dry_grass = 'dry_dirt_with_dry_grass',
    permafrost = 'permafrost',
    permafrost_with_stones = 'permafrost_with_stones',
    permafrost_with_moss = 'permafrost_with_moss',
    clay = 'clay',
    snowblock = 'snowblock',
    ice = 'ice',
    cave_ice = 'cave_ice',
    tree = 'tree',
    wood = 'wood',
    leaves = 'leaves',
    jungletree = 'jungletree',
    junglewood = 'junglewood',
    jungleleaves = 'jungleleaves',
    pine_tree = 'pine_tree',
    pine_wood = 'pine_wood',
    pine_needles = 'pine_needles',
    acacia_tree = 'acacia_tree',
    acacia_wood = 'acacia_wood',
    acacia_leaves = 'acacia_leaves',
    aspen_tree = 'aspen_tree',
    aspen_wood = 'aspen_wood',
    aspen_leaves = 'aspen_leaves',
    stone_with_coal = 'stone_with_coal',
    coalblock = 'coalblock',
    stone_with_iron = 'stone_with_iron',
    steelblock = 'steelblock',
    stone_with_copper = 'stone_with_copper',
    copperblock = 'copperblock',
    stone_with_tin = 'stone_with_tin',
    tinblock = 'tinblock',
    bronzeblock = 'bronzeblock',
    stone_with_gold = 'stone_with_gold',
    goldblock = 'goldblock',
    stone_with_mese = 'stone_with_mese',
    mese = 'mese',
    stone_with_diamond = 'stone_with_diamond',
    diamondblock = 'diamondblock',
    cactus = 'cactus',
    bush_leaves = 'bush_leaves',
    acacia_bush_leaves = 'acacia_bush_leaves',
    pine_bush_needles = 'pine_bush_needles',
    bookshelf = 'bookshelf',
    glass = 'glass',
    obsidian_glass = 'obsidian_glass',
    brick = 'brick',
    meselamp = 'meselamp'
}

codeblock.utils.plants_names = {
    sapling = 'sapling',
    apple = 'apple',
    junglesapling = 'junglesapling',
    emergent_jungle_sapling = 'emergent_jungle_sapling',
    pine_sapling = 'pine_sapling',
    acacia_sapling = 'acacia_sapling',
    aspen_sapling = 'aspen_sapling',
    large_cactus_seedling = 'large_cactus_seedling',
    dry_shrub = 'dry_shrub',
    grass_1 = 'grass_1',
    grass_2 = 'grass_2',
    grass_3 = 'grass_3',
    grass_4 = 'grass_4',
    grass_5 = 'grass_5',
    dry_grass_1 = 'dry_grass_1',
    dry_grass_2 = 'dry_grass_2',
    dry_grass_3 = 'dry_grass_3',
    dry_grass_4 = 'dry_grass_4',
    dry_grass_5 = 'dry_grass_5',
    fern_1 = 'fern_1',
    fern_2 = 'fern_2',
    fern_3 = 'fern_3',
    marram_grass_1 = 'marram_grass_1',
    marram_grass_2 = 'marram_grass_2',
    marram_grass_3 = 'marram_grass_3',
    bush_stem = 'bush_stem',
    bush_sapling = 'bush_sapling',
    acacia_bush_stem = 'acacia_bush_stem',
    acacia_bush_sapling = 'acacia_bush_sapling',
    pine_bush_stem = 'pine_bush_stem',
    pine_bush_sapling = 'pine_bush_sapling'
}

codeblock.utils.wools_names = {
    white = 'wool_white',
    grey = 'wool_grey',
    dark_grey = 'wool_dark_grey',
    black = 'wool_black',
    violet = 'wool_violet',
    blue = 'wool_blue',
    cyan = 'wool_cyan',
    dark_green = 'wool_dark_green',
    green = 'wool_green',
    yellow = 'wool_yellow',
    brown = 'wool_brown',
    orange = 'wool_orange',
    red = 'wool_red',
    magenta = 'wool_magenta',
    pink = 'wool_pink'
}

codeblock.utils.iwools_names = {
    'wool_red', 'wool_brown', 'wool_orange', 'wool_yellow', 'wool_green',
    'wool_dark_green', 'wool_cyan', 'wool_blue', 'wool_violet', 'wool_magenta',
    'wool_pink'

}

codeblock.utils.html_commands = [[
    <b><style font=normal size=16>Moving the drone</style></b>
    <b><style color=#264653 font=mono size=12>up</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>down</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>forward</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>back</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>left</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>right</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>move</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n_right</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_up</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_forward</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Rotating the drone</style></b>
    <b><style color=#264653 font=mono size=12>turn_right</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>turn_left</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>turn</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n_quarters_anti_clockwise</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Checkpoints</style></b>
    <b><style color=#264653 font=mono size=12>save</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>name</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>go</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>name</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_right</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_up</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_forward</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Random blocks</style></b>
    <b><style color=#264653 font=mono size=12>random.block</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>random.plant</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>random.wool</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Block at drone position</style></b>
    <b><style color=#264653 font=mono size=12>get_block</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Placing one block</style></b>
    <b><style color=#264653 font=mono size=12>place</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>block</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>place_relative</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>n_right</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_up</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n_forward</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> checkpoint</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Shapes</style></b>
    <b><style color=#264653 font=mono size=12>cube</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>width</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> length</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>sphere</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>dome</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vertical.cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>horizontal.cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>length</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Centered shapes</style></b>
    <b><style color=#264653 font=mono size=12>centered.cube</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>width</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> length</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>centered.sphere</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>centered.dome</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>centered.cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>centered.vertical.cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>height</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>centered.horizontal.cylinder</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>length</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> radius</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> block</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> hollow</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Math</style></b>
    <b><style color=#264653 font=mono size=12>random</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>\[m \[</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> n\]\]</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>round</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> num</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>round0</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>ceil</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>floor</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>deg</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>rad</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>exp</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>log</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>max</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> ...</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>min</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> ...</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>abs</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>pow</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> y</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>sqrt</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>sin</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>asin</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>sinh</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>cos</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>acos</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>cosh</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>tan</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>atan</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>atan2</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> y</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>tanh</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>pi</style></b>
    <b><style color=#264653 font=mono size=12>e</style></b>
    <b><style font=normal size=16>Misc</style></b>
    <b><style color=#264653 font=mono size=12>print</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>message</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>error</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>message</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>ipairs</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>table</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>pairs</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>table</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>table.randomizer</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>t</style><style font=mono size=12>)</style></b>
    <b><style font=normal size=16>Vectors</style></b>
    <b><style color=#264653 font=mono size=12>See https://github.com/ISs25u/vector3 for details</style></b>
    Operations + - * /
    <b><style color=#264653 font=mono size=12>vector</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> y</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> z</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.fromSpherical</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>r</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> theta</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> phi</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.fromCylindrical</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>r</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> phi</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> y</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.fromPolar</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>r</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> phi</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.srandom</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>a</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> b</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.crandom</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>a</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> b</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> c</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> d</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>vector.prandom</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>a</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> b</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:clone</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:length</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:norm</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:scale</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:limit</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:floor</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:round</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:set</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>x</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> y</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> z</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:offset</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>ox</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> oy</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> oz</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:apply</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>f</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:dist</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>v2</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:dot</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>v2</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:cross</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>v2</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:rotate_around</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>v</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12> angle</style><style font=mono size=12>)</style></b>
    <b><style color=#264653 font=mono size=12>v1:unpack</style><style font=mono size=12>(</style><style color=#e9c46a font=mono size=12></style><style font=mono size=12>)</style></b>
]]