
-- Realistic Torch mod by TenPlus1

-- unlit torch
minetest.register_node("real_torch:torch", {
	description = "Unlit Torch",
	drawtype = "torchlike",
	tiles = {
		{name = "real_torch_floor.png"},
		{name = "real_torch_ceiling.png"},
		{name = "real_torch_wall.png"},
	},
	inventory_image = "real_torch_floor.png",
	wield_image = "real_torch_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5 - 0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5 + 0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5 + 0.3, 0.3, 0.1},
	},
	groups = {choppy = 2, dig_immediate = 3, attached_node = 1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})

-- override default torches to burn out after 8-10 minutes
minetest.override_item("default:torch", {

	on_timer = function(pos, elapsed)
		local p2 = minetest.get_node(pos).param2
		minetest.swap_node(pos, {name = "real_torch:torch", param2 = p2})
	end,

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(480, 600))
	end,
})

-- start timer on any already placed torches
minetest.register_lbm({
	name = "real_torch:convert_torch_to_node_timer",
	nodenames = {"default:torch"},
	action = function(pos)
		if not minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):start(math.random(480, 600))
		end
	end
})

-- coal powder
minetest.register_craftitem("real_torch:coal_powder", {
	description = "Coal Powder",
	inventory_image = "real_torch_coal_powder.png",

	-- punching unlit torch with coal powder relights
	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)

		if nod.name == "real_torch:torch" then
			minetest.swap_node(pos, {name = "default:torch", param2 = nod.param2})
			itemstack:take_item()
			return itemstack
		end
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "real_torch:coal_powder",
	burntime = 10,
})

minetest.register_craft({
	type = "shapeless",
	output = "real_torch:coal_powder 4",
	recipe = {"default:coal_lump"},
})

-- coal powder can make black dye
minetest.register_craft({
	type = "shapeless",
	output = "dye:black 2",
	recipe = {"real_torch:coal_powder"},
})

-- add coal powder to burnt out torch to relight
minetest.register_craft({
	type = "shapeless",
	output = "default:torch",
	recipe = {"real_torch:torch", "real_torch:coal_powder"},
})

-- Make sure Ethereal mod isn't running as this Abm already exists there
if not minetest.get_modpath("xanadu") then

-- if torch touches water then drop as unlit torch
minetest.register_abm({
	label = "Real Torch water check",
	nodenames = {"default:torch", "real_torch:torch"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 1,
	catch_up = false,

	action = function(pos, node)

		local num = #minetest.find_nodes_in_area(
			{x = pos.x - 1, y = pos.y, z = pos.z},
			{x = pos.x + 1, y = pos.y, z = pos.z},
			{"group:water"})

		num = num + #minetest.find_nodes_in_area(
			{x = pos.x, y = pos.y, z = pos.z - 1},
			{x = pos.x, y = pos.y, z = pos.z + 1},
			{"group:water"})

		num = num + #minetest.find_nodes_in_area(
			{x = pos.x, y = pos.y + 1, z = pos.z},
			{x = pos.x, y = pos.y + 1, z = pos.z},
			{"group:water"})

		if num > 0 then

			minetest.swap_node(pos, {name = "air"})

			if node.name == "default:torch" then
				node.name = "real_torch:torch"
			end

			minetest.add_item(pos, {name = node.name})
		end
	end,
})

end
