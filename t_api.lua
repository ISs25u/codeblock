-- codeblock/t_api.lua

local  sequence = ''
local  recording = false
local  playing = false
local  nom_bloc = "dirt" --lightstone_red_off
---------------
-- FUNCTIONS --
---------------

local positions = {} -- form positions

--------------
-- FORMSPEC --
--------------

--NOTE JP : come from WorldEdit MOD determines whether `nodename` is a valid node name, returning a boolean
function codeblock.normalize_nodename(nodename)
	nodename = nodename:gsub("^%s*(.-)%s*$", "%1")
	if nodename == "" then return nil end
	local fullname = ItemStack({name=nodename}):get_name() --resolve aliases of node names to full names
	if minetest.registered_nodes[fullname] or fullname == "air" then --directly found node name or alias of nodename
		return fullname
	end
	for key, value in pairs(minetest.registered_nodes) do
		if key:find(":" .. nodename, 1, true) then --found in mod
			return key
		end
	end
	nodename = nodename:lower() --lowercase both for case insensitive comparison
	for key, value in pairs(minetest.registered_nodes) do
		if value.description:lower() == nodename then --found in description
			return key
		end
	end
	return nil
end

-- [function] show formspec
function codeblock.show_formspec(name, pos, formname, params)
	local meta = minetest.get_meta(pos) -- get meta
  if not meta then return false end -- if not meta, something is wrong
  positions[name] = pos -- set position (for receive fields)

	local function show(formspec)
		meta:set_string("formname", formname) -- set meta
		minetest.show_formspec(name, "codeblock:"..formname, formspec) -- show formspec
	end

  -- if form name is main, show main
  if formname == "main" then
		local node = nom_bloc
		local nodename = codeblock.normalize_nodename(node)
		local formspec =
			"size[6,6]" ..
			cadre_if_recording() ..
			string.format("field[0.2,0.4;4.5,0.8;form_nom_bloc;;%s]", minetest.formspec_escape(node)) ..
			"button[4.3,0.4;1.1,0.1;form_nom_bloc_search;Search]" ..
			(nodename and string.format("item_image[5.2,0;1,1;%s]", nodename)
				or "image[5.2,0;1,1;unknown_node.png]") ..
		--"label[0,0;Cliquez les boutons pour déplacer la tortue !]" .. --JP traduction
		"field[0.3,3;6,5;script_jp;Script :;"..sequence.."]"..
		"label[0,5.3;D ou G = tourner à Droite ou à Gauche]" ..
		"label[0,5.6;A ou R = Avancer ou Reculer]" ..
		"label[0,5.9;H ou B = aller en Haut ou en Bas]" ..
			"button_exit[4,1;1,1;exit;Exit]" ..
			"image_button[0,1;1,1;turtleminer_remote_arrow_up.png;up;]" ..
			"image_button[1,1;1,1;turtleminer_remote_arrow_fw.png;forward;]" ..
			"image_button[2,1;1,1;turtleminer_remote_dig_front.png;digfront;]" ..
			"image_button[2,3;1,1;turtleminer_remote_dig_down.png;digbottom;]" ..
			"image_button[3,1;1,1;turtleminer_remote_build_front.png;buildfront;]" ..
			"image_button[3,3;1,1;turtleminer_remote_build_down.png;buildbottom;]" ..
			"image_button[0,2;1,1;turtleminer_remote_arrow_left.png;turnleft;]"..
			"image_button[2,2;1,1;turtleminer_remote_arrow_right.png;turnright;]" ..
			"image_button[0,3;1,1;turtleminer_remote_arrow_down.png;down;]" ..
			"image_button[1,3;1,1;turtleminer_remote_arrow_bw.png;backward;]" ..
			"image_button[5,1;1,1;turtleminer_record.png;record;]"  .. --JP nouveau
			"image_button[5,2;1,1;turtleminer_stop.png;stopplay;]"  .. --JP nouveau
			"image_button[5,3;1,1;turtleminer_play.png;play;]" .. --JP nouveau
			--"image_button[4,2;1,1;turtleminer_fourmi.png;fourmi;]" .. --JP nouveau
			"image_button[1,2;1,1;turtleminer_remote_arrow_fw_build.png;buildforward;]" --JP nouveau
		show(formspec) -- show
	elseif formname == "set_name" then -- elseif form name is set_name, show set name formspec
		if not params then local params = "" end -- use blank name is none specified
	  local formspec =
	    "size[6,1.7]"..
	    default.gui_bg_img..
	    "field[.25,0.50;6,1;name;Name Your Turtle:;"..params.."]"..
	    "button[4.95,1;1,1;submit_name;Set]"
		show(formspec) -- show
	end
end

-- [function] rotate
function codeblock.rotate(pos, direction, player)
	-- [function] calculate dir
	local function calculate_dir(x, turn)
		if turn == "right" then
			x = x + 1
			if x > 3 then x = 0 end
			return x
		elseif turn == "left" then
			x = x - 1
			if x < 0 then x = 3 end
			return x
		end
	end

	local node = minetest.get_node(pos) -- get node
	local ndef = minetest.registered_nodes[node.name] -- get node def

	-- if direction is right, rotate right
	if direction == "right" then
		-- calculate param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		local x = rotation + 1
		if x > 3 then x = 0 end -- calculate x
		rotationPart = axisdir * 4 + x
		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2 -- set new param2
		minetest.swap_node(pos, node) -- swap node
		-- minetest.sound_play("moveokay", { to_player = player, gain = 1.0 }) -- play sound
	elseif direction == "left" then -- elseif direction is left, rotate left
		-- calculate param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		local x = rotation - 1
		if x < 0 then x = 3 end -- calculate x
		rotationPart = axisdir * 4 + x
		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2 -- set new param2
		minetest.swap_node(pos, node) -- swap node
		-- minetest.sound_play("moveokay", { to_player = player, gain = 1.0 }) -- play sound
	end
end

-- [function] move
function codeblock.move(pos, direction, name)
	local oldmeta = minetest.get_meta(pos):to_table() -- get meta
	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local new_pos = vector.new(pos) -- new pos vector
	local entity_pos = vector.new(pos) -- entity position vector

	local function turtle_move(pos, new_pos, entity_pos)
		-- if not walkable, proceed
		if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.remove_node(pos) -- remote old node
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

			-- if not walkable, move player
			if not minetest.registered_nodes[minetest.get_node(entity_pos).name].walkable then
				local objects_to_move = {}

				local objects = minetest.get_objects_inside_radius(new_pos, 1) -- get objects
				for _, obj in ipairs(objects) do -- for every object, add to table
					table.insert(objects_to_move, obj) -- add to table
				end

				for _, obj in ipairs(objects_to_move) do
					local entity = obj:get_luaentity()
					if not entity then
							obj:setpos(entity_pos)
					end
				end
			end

			-- minetest.sound_play("moveokay", { player = name, gain = 1.0 }) -- play sound
		else -- else, return false
			-- minetest.sound_play("moveerror", { player = name, gain = 1.0 }) -- play sound
			return false
		end
	end

	-- if direction is forward, move forward
	if direction == "forward" or direction == "f" then
		-- calculate new coords
		new_pos.z = new_pos.z - dir.z
		new_pos.x = new_pos.x - dir.x
		entity_pos.z = entity_pos.z - dir.z * 2
		entity_pos.x = entity_pos.x - dir.x * 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		entity_pos.z = entity_pos.z + dir.z * 2
		entity_pos.x = entity_pos.x + dir.x * 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		entity_pos.y = entity_pos.y + 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		entity_pos.y = entity_pos.y - 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	end
end

-- [function] dig
function codeblock.dig(pos, where, name)
	-- [function] dig
	local function dig(pos)
		if minetest.get_node_or_nil(pos) then -- if node, dig
			minetest.set_node(pos, { name = "air" })
			minetest.check_for_falling(pos)
			-- minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		else -- minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) 
		end -- else, play error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local dig_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		dig_pos.z = dig_pos.z - dir.z
		dig_pos.x = dig_pos.x - dir.x
		dig(dig_pos) -- dig node in front
	elseif where == "below" then -- elseif where is below, dig below
		dig_pos.y = dig_pos.y - 1 -- remove 1 from dig_pos y axis
		dig(dig_pos) -- dig node below
	end
end

-- [function] build
function codeblock.build(pos, where, name)
	-- [function] build
	local function build(pos)
		if minetest.get_node_or_nil(pos) then -- if node, dig
			minetest.set_node(pos, { name = codeblock.normalize_nodename(nom_bloc) }) --JP modification
			minetest.check_for_falling(pos)
			-- minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		else -- minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) 
		end -- else, play error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local build_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		build_pos.z = build_pos.z - dir.z
		build_pos.x = build_pos.x - dir.x
		build(build_pos) -- dig node in front
	elseif where == "below" then -- elseif where is below, dig below
		build_pos.y = build_pos.y - 1 -- remove 1 from dig_pos y axis
		build(build_pos) -- dig node below
	end
end


--------------
-- NODE DEF --
--------------


-- [function] register turtle
function codeblock.register_turtle(turtlestring, desc)
	minetest.register_node("codeblock:"..turtlestring, {
		drawtype = "nodebox",
		description = desc.description,
		tiles = desc.tiles,
		groups={ oddly_breakable_by_hand=1 },
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = desc.nodebox
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos) -- get meta
			--meta:set_string("formspec", codeblock.formspec()) -- set formspec
			meta:set_string("owner", placer:get_player_name()) -- set owner
			meta:set_string("infotext", "Unnamed turtle\n(owned by "..placer:get_player_name()..")") -- set infotext
		end,
		on_rightclick = function(pos, node, clicker)
			local name = clicker:get_player_name() -- get clicker name
			local meta = minetest.get_meta(pos)
			-- if name not set, show name form
			if not meta:get_string("name") or meta:get_string("name") == "" then
				codeblock.show_formspec(name, pos, "set_name", "") -- show set name formspec
			elseif meta:get_string("formname") ~= "" then -- elseif formname is set, show specific form
				-- if wielding remote control, show formspec
				if clicker:get_wielded_item():get_name() == "codeblock:remotecontrol" then
					codeblock.show_formspec(name, pos, meta:get_string("formname")) -- show formspec (note: no params)
				else
					minetest.chat_send_player(name, "Use a remote controller to access the turtle.")
				end
			else -- else, show normal formspec
				-- if wielding remote control, show formspec
				if clicker:get_wielded_item():get_name() == "codeblock:remotecontrol" then
					codeblock.show_formspec(name, pos, "main") -- show main formspec
				else
					minetest.chat_send_player(name, "Use a remote controller to access the turtle.")
				end
			end
		end,
	})
end


-----------------------
-- DEBUT TEST JP DEF --------------------------------------------------------------------------------------------
-----------------------

-- [function] moveJP
function codeblock.moveJP(pos, direction, name)
	local oldmeta = minetest.get_meta(pos):to_table() -- get meta
	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local new_pos = vector.new(pos) -- new pos vector

	local function turtle_move(pos, new_pos)
		-- if not walkable, proceed
		--if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.remove_node(pos) -- remote old node
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

		--	minetest.sound_play("moveokay", { player = name, gain = 1.0 }) -- play sound
		--else -- else, return false
		--	minetest.sound_play("moveerror", { player = name, gain = 1.0 }) -- play sound
		--	return false
		--end
	end

	-- if direction is forward, move forward
	if direction == "forward" or direction == "f" then
		-- calculate new coords
		new_pos.z = new_pos.z - dir.z
		new_pos.x = new_pos.x - dir.x
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		turtle_move(pos, new_pos) -- call local function
	end
end

-- [function] buildforwardJP
function codeblock.buildforwardJP(pos, name)
	local oldmeta = minetest.get_meta(pos):to_table() -- get meta
	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local new_pos = vector.new(pos) -- new pos vector

	local function turtle_move(pos, new_pos)
		-- if not walkable, proceed
		if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.set_node(pos, { name = codeblock.normalize_nodename(nom_bloc) }) --JP modification
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

			-- minetest.sound_play("moveokay", { player = name, gain = 1.0 }) -- play sound
		else -- else, return false
			-- minetest.sound_play("moveerror", { player = name, gain = 1.0 }) -- play sound
			return false
		end
	end

	-- calculate new coords
	new_pos.z = new_pos.z - dir.z
	new_pos.x = new_pos.x - dir.x
	turtle_move(pos, new_pos) -- call local function
end

-- [function] buildbelowJP
function codeblock.buildbelowJP(pos, name)

	local function build(pos)
		if minetest.get_node_or_nil(pos) then -- if node, dig
			minetest.set_node(pos, { name = codeblock.normalize_nodename(nom_bloc) }) --JP modification
			minetest.check_for_falling(pos)
			-- minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		else -- minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) 
		end -- else, play error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local build_pos = vector.new(pos) -- dig position

	build_pos.y = build_pos.y - 1 -- remove 1 from dig_pos y axis
	build(build_pos) -- dig node below

	local oldmeta = minetest.get_meta(pos):to_table() -- get meta
	local new_pos = vector.new(pos) -- new pos vector
	local entity_pos = vector.new(pos) -- entity position vector

	local function turtle_move(pos, new_pos, entity_pos)
		-- if not walkable, proceed
		if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.remove_node(pos) -- remote old node
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

			-- if not walkable, move player
			if not minetest.registered_nodes[minetest.get_node(entity_pos).name].walkable then
				local objects_to_move = {}

				local objects = minetest.get_objects_inside_radius(new_pos, 1) -- get objects
				for _, obj in ipairs(objects) do -- for every object, add to table
					table.insert(objects_to_move, obj) -- add to table
				end

				for _, obj in ipairs(objects_to_move) do
					local entity = obj:get_luaentity()
					if not entity then
							obj:setpos(entity_pos)
					end
				end
			end

			-- minetest.sound_play("moveokay", { player = name, gain = 1.0 }) -- play sound
		else -- else, return false
			-- minetest.sound_play("moveerror", { player = name, gain = 1.0 }) -- play sound
			return false
		end
	end

	-- if direction is forward, move forward
	-- calculate new coords
	new_pos.z = new_pos.z - dir.z
	new_pos.x = new_pos.x - dir.x
	entity_pos.z = entity_pos.z - dir.z * 2
	entity_pos.x = entity_pos.x - dir.x * 2
	turtle_move(pos, new_pos, entity_pos) -- call local function
end

-- [function] langtonJP
function codeblock.langtonJP(pos, where, name)

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local build_pos = vector.new(pos) -- dig position

	build_pos.y = build_pos.y - 1 -- remove 1 from dig_pos y axis
	if not minetest.registered_nodes[minetest.get_node(build_pos).name].walkable then -- si vide alors je place un bloc
		minetest.set_node(build_pos, { name = codeblock.normalize_nodename(nom_bloc) })
		minetest.check_for_falling(build_pos)
		-- minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		codeblock.rotate(pos, "right", name)
	else -- sinon j'enlève le bloc
		minetest.set_node(build_pos, { name = "air" })
		minetest.check_for_falling(build_pos)
		-- minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) 
		codeblock.rotate(pos, "left", name)
	end
	codeblock.move(pos, "forward", name)
	
end

-- [function] langtonJPcent
function codeblock.langtonJPcent(pos, name)
	local newpos = pos
	for count = 1, 100 do
		codeblock.langtonJP(newpos, "below", name)
		newpos = positions[name]
	end
end

function cadre_if_recording()
  if recording then
    return "image[-0.4,-0.4;8.2,7.9;turtleminer_cadre.png]"
  else
    return ""
  end
end

-- [function] playJP
function firstIndexOf(str, substr)
  local i = string.find(str, substr, 1, true)
  if i == nil then
    return 0
  else
    return i
  end
end
function codeblock.playJP_seq(pos, name, seq)
	-- local newpos = pos VOIR NOTE quelques lignes plus bas dans le if playing
	local compteur = 1
	local nf_fois = 1
	if firstIndexOf('1234567890', string.sub(seq, 1, 1)) ~= 0 then
		nf_fois = 0
		local seq1_est_nombre = firstIndexOf('1234567890', string.sub(seq, 1, 1))
		while not (seq1_est_nombre == 0) do
			if seq1_est_nombre == 10 then
				nf_fois = nf_fois * 10
			else
				nf_fois = nf_fois * 10 + seq1_est_nombre
			end
			compteur = compteur + 1
			seq1_est_nombre = firstIndexOf('1234567890', string.sub(seq, compteur, compteur))
		end
	end
	if string.sub(seq, compteur, compteur) == '(' then
		local compteur_par = compteur
		local nb_parenth = 1
		while not ((string.sub(seq, compteur_par, compteur_par) == ')' and nb_parenth == 0) or (#seq == compteur_par)) do -- ajouter ici un test du genre OR la fin de seq est atteinte
			compteur_par = compteur_par + 1
			if string.sub(seq, compteur_par, compteur_par) == '(' then
				nb_parenth = nb_parenth + 1
			elseif string.sub(seq, compteur_par, compteur_par) == ')' then
				nb_parenth = nb_parenth - 1
			end
		end
		if (string.sub(seq, compteur_par, compteur_par) == ')' and nb_parenth == 0) then
			for i = 1, nf_fois do
				codeblock.playJP_seq(pos, name, string.sub(seq, compteur + 1, compteur_par - 1))
			end
			if #seq > compteur_par then
				codeblock.playJP_seq(pos, name, string.sub(seq, compteur_par + 1, #seq))
			end
		else
			playing = false
			sequence = sequence .. " error : ) missing !" 
		end
	else
		for i = 1, nf_fois do
			if playing then 
				if string.sub(seq, compteur, compteur) == 'D' then	codeblock.rotate(positions[name], "right", name) -- elseif turn right button, rotate right
				elseif string.sub(seq, compteur, compteur) == 'G' then codeblock.rotate(positions[name], "left", name) -- elseif turn left button, rotate left
				elseif string.sub(seq, compteur, compteur) == 'A' then codeblock.move(positions[name], "forward", name) -- elseif move forward button, move forward
				elseif string.sub(seq, compteur, compteur) == 'R' then codeblock.move(positions[name], "backward", name) -- elseif move backward button, move backward
				elseif string.sub(seq, compteur, compteur) == 'H' then codeblock.move(positions[name], "up", name) -- elseif move up button, move up
				elseif string.sub(seq, compteur, compteur) == 'B' then codeblock.move(positions[name], "down", name) -- elseif move down button, move down
				elseif string.sub(seq, compteur, compteur) == 'C' then codeblock.dig(positions[name], "front", name) -- elseif dig in front button, dig in front
				elseif string.sub(seq, compteur, compteur) == 'c' then codeblock.dig(positions[name], "below", name) -- elseif dig bottom button, dig below
				elseif string.sub(seq, compteur, compteur) == 'p' then codeblock.build(positions[name], "front", name) -- elseif build in front button, build in front
				elseif string.sub(seq, compteur, compteur) == 'L' then codeblock.langtonJP(positions[name], "below", name) -- JP TEST
				elseif string.sub(seq, compteur, compteur) == 'a' then codeblock.buildbelowJP(positions[name], name) -- JP TEST
				elseif string.sub(seq, compteur, compteur) == 'P' then codeblock.build(positions[name], "below", name) -- JP TEST
				elseif string.sub(seq, compteur, compteur) == ')' then 
					playing = false
					sequence = sequence .. " error : ( missing !" 
				elseif string.sub(seq, compteur, compteur) == ' ' then 
				else 
					playing = false
					sequence = sequence .. " error : instruction " .. string.sub(seq, compteur, compteur) .. " unknown !" 
				end -- JP TEST
				-- newpos = positions[name] NOTE j'ai enlevé cette gestion de la position qui posait probleme en passant directement la position sans passer par cette variable local
			end
		end
		if #seq > compteur then
			codeblock.playJP_seq(pos, name, string.sub(seq, compteur + 1, #seq))
		end
	end
end
--------------------- https://blockly-demo.appspot.com/static/demos/code/index.html?lang=fr
-- FIN TEST JP DEF ---------------------------------------------------------------------------------------------------------
---------------------

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "codeblock:main" then return end -- if not right formspec, return

	local name = sender:get_player_name()
	local pos = positions[name]
	local form_script = fields.script_jp
	if form_script ~= sequence then 
		sequence = form_script
	end

	if not pos then return end -- if not position, return - something is wrong

	local node = minetest.get_node(pos) -- node info

	-- check fields
	if fields.turnright then 
		codeblock.rotate(pos, "right", name) -- elseif turn right button, rotate right
		if recording then 
			sequence = sequence .. 'D'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.turnleft then 
		codeblock.rotate(pos, "left", name) -- elseif turn left button, rotate left
		if recording then 
			sequence = sequence .. 'G'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.forward then 
		codeblock.move(pos, "forward", name) -- elseif move forward button, move forward
		if recording then 
			sequence = sequence .. 'A'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.backward then 
		codeblock.move(pos, "backward", name) -- elseif move backward button, move backward
		if recording then 
			sequence = sequence .. 'R'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.up then 
		codeblock.move(pos, "up", name) -- elseif move up button, move up
		if recording then 
			sequence = sequence .. 'H'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.down then 
		codeblock.move(pos, "down", name) -- elseif move down button, move down
		if recording then 
			sequence = sequence .. 'B'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.digfront then 
		codeblock.dig(pos, "front", name) -- elseif dig in front button, dig in front
		if recording then 
			sequence = sequence .. 'C'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.digbottom then 
		codeblock.dig(pos, "below", name) -- elseif dig bottom button, dig below
		if recording then 
			sequence = sequence .. 'c'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.buildfront then 
		codeblock.build(pos, "front", name) -- elseif build in front button, build in front
		if recording then 
			sequence = sequence .. 'p'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.buildbottom then 
		codeblock.build(pos, "below", name) -- elseif build bottom button, build below
		if recording then 
			sequence = sequence .. 'P'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.buildforward then 
		codeblock.buildbelowJP(pos, name) -- JP TEST
		if recording then 
			sequence = sequence .. 'a'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.play then 
		playing = true 
		codeblock.playJP_seq(pos, name, sequence)
		if (recording and playing) then 
			sequence = sequence .. sequence
		end
		codeblock.show_formspec(name, positions[name], "main")
	elseif fields.stopplay then -- JP TEST 
		if (recording or playing) then 
			recording = false 
			playing = false 
		else
			sequence = '' -- un double stop permet ainsi de remettre à zéro le script
		end
		codeblock.show_formspec(name, positions[name], "main")
	elseif fields.record then 
		recording = true
		codeblock.show_formspec(name, positions[name], "main")
	elseif fields.fourmi then 
		codeblock.langtonJP(pos, "below", name) 
		if recording then 
			sequence = sequence .. 'L'
			codeblock.show_formspec(name, positions[name], "main")
		end
	elseif fields.form_nom_bloc_search then
		nom_bloc = tostring(fields.form_nom_bloc)
		codeblock.show_formspec(name, positions[name], "main")
	end -- JP TEST
end)

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "codeblock:set_name" then return end -- if not right formspec, return

	local name = sender:get_player_name()
	local meta = minetest.get_meta(positions[name])
	local tname = fields.name or "Unnamed turtle"

	meta:set_string("name", tname) -- set name
	meta:set_string("infotext", tname .. "\n(owned by "..name..")") -- set infotext
	codeblock.show_formspec(name, positions[name], "main") -- show main formspec
end)
