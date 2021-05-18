codeblock.events = {}
local S = default.get_translator

--
-- FUNCTIONS
--

function codeblock.events.handle_update_drone_entity(drone)
    local name = drone.name
    local drone_entity = codeblock.drone_entities[name]

    if not drone_entity or not drone then error(S("drone does not exist")) end

    drone_entity:move_to({x = drone.x, y = drone.y, z = drone.z})
    drone_entity:set_rotation({x = 0, y = drone.dir, z = 0})

end

function codeblock.events.handle_start_drone(user)

    local name = user:get_player_name()

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return {}
    end

    local file = drone.file

    if not file then
        minetest.chat_send_player(name, S("no file selected"))
        return
    end

    -- minetest.chat_send_player(name, S("Starting drone @1/@2", name, file))

    -- EXECUTION

    codeblock.sandbox.run_safe(name, file)
    codeblock.commands.remove_drone(name)

end

function codeblock.events.handle_place_drone(placer, pointed_thing)

    local name = placer:get_player_name()

    if codeblock.drones[name] then codeblock.commands.remove_drone(name) end

    local pos = minetest.get_pointed_thing_position(pointed_thing)
    local dir = math.floor((placer:get_look_horizontal() + math.pi / 4) /
                               math.pi * 2) * math.pi / 2

    local code = nil

    if not pos then
        minetest.chat_send_player(name, S("Please target node"))
        return {}
    end

    local drone = codeblock.commands.add_drone(pos, dir, name, code)

    -- minetest.chat_send_player(name, S("@1 placing a drone at @2", name, minetest.pos_to_string(pos)))

    local meta = placer:get_meta()
    local last_index = meta:get_int('codeblock:last_index')
    if not last_index or last_index == 0 then
        codeblock.events.handle_show_set_drone(placer)

    else
        codeblock.commands.set_drone_file_from_index(name, last_index)
    end

end

function codeblock.events.handle_show_set_drone(player)

    local name = player:get_player_name()
    local path = codeblock.datapath .. name

    local files = codeblock.filesystem.get_files(path)

    if not files or #files == 0 then
        minetest.chat_send_player(name, S('no files'))
        return
    end

    minetest.show_formspec(name, 'codeblock:choose_file',
                           codeblock.formspecs.choose_file(files))

end

function codeblock.events.handle_place_block(pos, block)

    assert(pos)

    block = block or "default:dirt"

    minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, {name = block})

end
