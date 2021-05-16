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

    minetest.chat_send_player(name, S("Starting drone @1/@2", name, file))

    local file = codeblock.datapath .. name .. '/' .. file
    local content = codeblock.filesystem.read(file)

    if not content then
        minetest.chat_send_player(name, S('@1 not found', file))
        return {}
    end

    -- EXECUTION

    assert(codeblock.commands.run_safe(content, name))

    codeblock.commands.remove_drone(user:get_player_name())

end

function codeblock.events.handle_place_drone(placer, pointed_thing)

    local name = placer:get_player_name()

    if codeblock.drones[name] then codeblock.commands.remove_drone(name) end

    local pos = minetest.get_pointed_thing_position(pointed_thing)
    local dir = math.floor((placer:get_look_horizontal() + math.pi / 4) /
                               math.pi * 2) * math.pi / 2
    local code = 'test.lua' -- TODO

    if not pos then
        minetest.chat_send_player(name, S("Please target node"))
        return {}
    end

    local drone = codeblock.commands.add_drone(pos, dir, name, code)
    minetest.chat_send_player(name, S("@1 placing a drone at @2", name,
                                      minetest.pos_to_string(pos)))

end

function codeblock.events.handle_place_block(pos, block)

    assert(pos)

    block = block or "default:dirt"

    minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, {name = block})

end

