codeblock.events = {}
local S = codeblock.S

--
-- FUNCTIONS
--

function codeblock.events.handle_update_drone_entity(drone)
    local name = drone.name
    local drone_entity = codeblock.drone_entities[name]

    if not drone_entity or not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
        return
    end

    drone_entity:move_to({x = drone.x, y = drone.y, z = drone.z})
    drone_entity:set_rotation({x = 0, y = drone.dir, z = 0})

    local attr = drone_entity:get_nametag_attributes()
    attr.text = drone.file
    drone_entity:set_nametag_attributes(attr)

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

    codeblock.sandbox.run_safe(name, file)
    codeblock.commands.remove_drone(name)

end

function codeblock.events.handle_place_drone(placer, pointed_thing)

    local name = placer:get_player_name()

    if codeblock.drones[name] then codeblock.commands.remove_drone(name) end

    local pos = minetest.get_pointed_thing_position(pointed_thing)
    local dir = math.floor((placer:get_look_horizontal() + math.pi / 4) /
                               math.pi * 2) * math.pi / 2

    if not pos then
        minetest.chat_send_player(name, S("Please target node"))
        return {}
    end

    local drone = codeblock.commands.add_drone(pos, dir, name, nil)

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

    minetest.set_node({
        x = math.ceil(pos.x),
        y = math.ceil(pos.y),
        z = math.ceil(pos.z)
    }, {name = block})

end

