# TODO

# v1.0.0 goals

- [x] User associated filesystem to store programs
- [x] Allow to set drone's file with in-game interface + remember last program started
- [x] Control drone operating speed
- [x] In-game lua code editor
- [ ] Blockly web-based editor

# next intermediate version goals

- [x] fix contrast in ingame API Help
- [ ] move allowed blocks to config + procedurally generate them
- [x] create examples folder and generate them

# maybe

- [ ] option to set drone default block to place
- [ ] open copy of program
- [ ] option to pause the drone a certain time?
- [ ] make mod configurable (see https://github.com/AntumMT/mod-hovercraft/)
- [ ] fix place() in non-loaded chunks
    - minetest.emerge_area(pos1, pos2, [callback], [param])
    - minetest.get_node_or_nil(pos) (if unloaded)
    - minetest.emerge_area(pos1, pos2, [callback], [param]) (does not trigger emerge)
    - minetest.compare_block_status(pos, condition)
- [ ] fix color(v,m,M) function (or remove)
- [ ] rebuild construction when re-running code (save previous area) 

# Other ideas

- minetest.set_timeofday(val)
- minetest.fix_light(pos1, pos2)
- minetest.is_protected(pos, name)
- minetest.place_schematic(pos, schematic, rotation, replacements, force_placement, flags)
- minetest.create_schematic(p1, p2, probability_list, filename, slice_prob_list)
- HTTPApiTable.fetch(HTTPRequest req, callback)
- format lua when saving ? https://github.com/LuaDevelopmentTools/luaformatter/blob/master/formatter.lua
- render code with html widget? (highlight)
- show line error on save?
- colored concrete instead of wool? : https://github.com/nikolaus-albinger/colored_concrete

# Game ideas

- [ ] generate flat clean world https://github.com/srifqi/superflat
- [ ] teleport function?
- [ ] always day, etc
