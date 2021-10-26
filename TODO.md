## TODO

### v1.0.0

- [x] User associated filesystem to store programs
- [x] Allow to set drone's file with in-game interface + remember last program started
- [x] Control drone operating speed
- [ ] In-game lua code editor
- [ ] Blockly web-based editor


### v0.6.0

- [ ] get block at drone position
- [ ] fix color(v,m,M) function (or remove)
- [ ] fix place() in non-loaded chunks
- [ ] make mod configurable
- [ ] optional depends on vector3, worldedit, wool, etc
- [ ] function that returns a block at random in a list of blocks

### v0.5.0

- [ ] code editor
- [ ] editor : add checkboxes to save/load on exit (fix bug?)
- [ ] editor : add options to create/remove files
- [ ] filesystem : change to file names instead of indexes
- [ ] file : put an initial simple example.lua ready to use
- [ ] filesystem : handle removed/added files when restoring editor state

### v0.4.0

- [x] set drone limits/speed with authlevel (volume, calls, commands, dimension)
- [x] api now have a custom vector library
- [x] corrected centered shapes placement
- [x] tool fixes/textures

### v0.3.0

- [x] add cylinder() and dome()
- [x] WE center placing functions
- [x] separate H and V cylinder and centered funcitons
- [x] sanity checks of input types -> abs values !
- [x] fix trad
- [x] fix centered cylinders placement
- [x] rewrite programs with appropriate functions
- [x] review max volume allowed
- [x] update list of commands in README and contentDB

### v0.2.0

- [x] safe formspecs
- [x] check compatible versions of minetest
- [x] add turn(n) ?
- [x] add sphere()
- [x] add cube()
- [x] add move(r,f,u)
- [x] relative positioning
- [x] checkpoint saves drone dir
- [x] use minetest.write
- [x] remove error() when possible
- [x] default drone move by 1
- [x] drone label with program
- [x] remove drone on leave


## Other idead

- minetest.set_timeofday(val)
- minetest.emerge_area(pos1, pos2, [callback], [param])
- minetest.fix_light(pos1, pos2)
- minetest.hash_node_position(pos)
- minetest.string_to_pos(pos)
- minetest.get_position_from_hash(hash)
- minetest.is_protected(pos, name)
- minetest.request_insecure_environment()
- lua formatter ? https://github.com/LuaDevelopmentTools/luaformatter/blob/master/formatter.lua

Separate ?

- [ ] generate flat clean world https://github.com/srifqi/superflat
- [ ] teleport function?
- [ ] always day, etc