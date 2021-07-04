--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------
local S = codeblock.S
local drone_run = codeblock.DroneEntity.run
local drone_place = codeblock.DroneEntity.place
local drone_remove = codeblock.DroneEntity.remove_drone
local drone_form = codeblock.DroneEntity.showfileformspec
local drone_setfile = codeblock.DroneEntity.setfilefromindex

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

    -- player:get_meta():set_int('codeblock:last_index', 0)

end)

minetest.register_on_newplayer(function(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    if not minetest.mkdir(codeblock.datapath .. name) then
        minetest.chat_send_player(name, S('Cannot create @1', path))
    end

    for ename, content in pairs(codeblock.examples) do
        local file_path = path .. '/' .. ename .. '.lua'
        codeblock.filesystem.write(file_path, content)
    end

    player:get_meta():set_int('codeblock:last_index', 0)

end)

minetest.register_on_leaveplayer(
    function(player, timed_out) drone_remove(player) end)

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
