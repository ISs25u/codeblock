--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------
local S = codeblock.S
local drone_run = codeblock.DroneEntity.run
local drone_place = codeblock.DroneEntity.place
local drone_remove = codeblock.DroneEntity.remove_drone
local drone_form = codeblock.DroneEntity.showfileformspec
local drone_setfile = codeblock.DroneEntity.setfilefromindex
local check_auth_level = codeblock.utils.check_auth_level
local get_player_by_name = minetest.get_player_by_name

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

local function give_tools(player)
    local inv = player:get_inventory()
    inv:add_item('main', ItemStack('codeblock:drone_placer'))
    inv:add_item('main', ItemStack('codeblock:drone_starter'))
end

local function generate_examples(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not minetest.mkdir(codeblock.datapath .. name) then
        minetest.chat_send_player(name, S('Cannot create @1', path))
        return false
    end

    for ename, content in pairs(codeblock.examples) do
        local file_path = path .. '/' .. ename .. '.lua'
        codeblock.filesystem.write(file_path, content)
    end

    return true

end

--------------------------------------------------------------------------------
-- tools
--------------------------------------------------------------------------------

minetest.register_tool("codeblock:drone_placer", {
    description = S("Drone Placer"),
    inventory_image = "drone_placer.png",
    range = 128,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        drone_run(user)
        return itemstack
    end,
    on_place = function(itemstack, placer, pointed_thing)
        drone_place(placer, pointed_thing)
        return itemstack
    end
})

minetest.register_tool("codeblock:drone_starter", {
    description = S("Drone Starter"),
    inventory_image = "drone_starter.png",
    range = 128,
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        drone_form(user)
        return itemstack
    end,
    on_place = function(itemstack, placer, pointed_thing)
        drone_remove(placer)
        return itemstack
    end
})

--------------------------------------------------------------------------------
-- entities
--------------------------------------------------------------------------------

minetest.register_entity("codeblock:drone", codeblock.DroneEntity)

--------------------------------------------------------------------------------
-- players
--------------------------------------------------------------------------------

minetest.register_on_joinplayer(function(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not minetest.mkdir(codeblock.datapath .. name) then
        minetest.chat_send_player(name, S('Cannot create @1', path))
    end

    -- TODO: TEMP fix ?
    player:override_day_night_ratio(1)
    player:set_stars({visible = false})
    player:set_sun({visible = false})
    player:set_moon({visible = false})
    player:set_clouds({density = 0})

end)

minetest.register_on_newplayer(function(player)

    generate_examples(player)
    give_tools(player)
    player:get_meta():set_int('codeblock:last_index', 0)
    player:get_meta():set_int('codeblock:auth_level',
                              codeblock.default_auth_level)

    local privs = minetest.get_player_privs(player:get_player_name())
    privs.fly = true
    privs.fast = true
    minetest.set_player_privs(player:get_player_name(), privs)

end)

minetest.register_on_leaveplayer(
    function(player, timed_out) drone_remove(player) end)

--------------------------------------------------------------------------------
-- Commands and privileges
--------------------------------------------------------------------------------

minetest.register_privilege("codeblock", {
    description = "Player can use the codeblock admin commands",
    give_to_singleplayer = false
})

minetest.register_chatcommand("authlevel", {
    privs = {codeblock = true},
    func = function(name, params)

        local pname, pal = string.match(params, '^([%a%d_-]+) (%d)$')

        local valid_al, al = check_auth_level(tonumber(pal))

        local player = get_player_by_name(pname or '')

        if valid_al then
            if player then
                player:get_meta():set_int('codeblock:auth_level', al)
                return true, S('@1 auth_level set to @2', pname, al)
            else
                return false, S('Player not found')
            end
        else
            return false, S('Invalid authlevel')
        end

    end
})

minetest.register_chatcommand("codeblock_examples", {
    privs = {codeblock = true},
    func = function(name, params)

        local pname = string.match(params, '^([%a%d_-]+)$')

        local player = get_player_by_name(pname or name or '')

        if player then
            local res = generate_examples(player)
            if res then
                return true, S('examples generated')
            else
                return false, S('error')
            end
        else
            return false, S('Player not found')
        end

    end
})

--------------------------------------------------------------------------------
-- formspecs
--------------------------------------------------------------------------------

minetest.register_on_player_receive_fields(
    function(player, formname, fields)

        if formname == "codeblock:choose_file" then

            local name = player:get_player_name()
            local res = minetest.explode_textlist_event(fields.file)

            if res.type == "DCL" then

                minetest.close_formspec(name, 'codeblock:choose_file')
                drone_setfile(player, res.index)

            end

        end

    end)
