-- codeblock/turtles.lua

codeblock.register_turtle("codebot", {
	description = "Code Bot",
	tiles = {
		"turtleminer_tech_turtle_top.png",
		"turtleminer_tech_turtle_bottom.png",
		"turtleminer_tech_turtle_right.png",
		"turtleminer_tech_turtle_left.png",
		"turtleminer_tech_turtle_back.png",
		"turtleminer_tech_turtle_front.png"
	},
	nodebox = {
		{-0.43, -0.37, -0.43, 0.43, 0.4375, 0.43}, -- Turtle
		{-0.3125, -0.42, -0.3125, 0.3125, -0.3, 0.3125}, -- Engine
		{-0.3125, 0.0625, 0.375, 0.3125, 0.375, 0.5}, -- Inventory
	},
})
