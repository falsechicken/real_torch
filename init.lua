
-- Realistic Torch mod by TenPlus1


-- check which torch(es) are available in minetest version
if minetest.registered_nodes["default:torch_ceiling"] then

	dofile(minetest.get_modpath("real_torch") .. "/3d.lua")
else
	dofile(minetest.get_modpath("real_torch") .. "/2d.lua")
end


-- start timer on any already placed torches
minetest.register_lbm({
	name = "real_torch:convert_torch_to_node_timer",
	nodenames = {"default:torch", "default:torch_wall", "default:torch_ceiling"},
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

			minetest.set_node(pos, {name = "default:torch", param2 = nod.param2})
			itemstack:take_item()

		elseif nod.name == "real_torch:torch_wall" then

			minetest.set_node(pos, {name = "default:torch_wall", param2 = nod.param2})
			itemstack:take_item()

		elseif nod.name == "real_torch:torch_ceiling" then

			minetest.set_node(pos, {name = "default:torch_ceiling", param2 = nod.param2})
			itemstack:take_item()
		end

		return itemstack
	end,
})

-- use coal powder as furnace fuel
minetest.register_craft({
	type = "fuel",
	recipe = "real_torch:coal_powder",
	burntime = 10,
})

-- 2x coal lumps = 8x coal powder
minetest.register_craft({
	type = "shapeless",
	output = "real_torch:coal_powder 10",
	recipe = {"default:coal_lump", "default:coal_lump"},
})

-- coal powder can make black dye
minetest.register_craft({
	type = "shapeless",
	output = "dye:black",
	recipe = {"real_torch:coal_powder"},
})

-- add coal powder to burnt out torch to relight
minetest.register_craft({
	type = "shapeless",
	output = "default:torch",
	recipe = {"real_torch:torch", "real_torch:coal_powder"},
})

-- Make sure Ethereal mod isn't running as this Abm already exists there
if not minetest.get_modpath("ethereal") then

-- if torch touches water then drop as unlit torch
minetest.register_abm({
	label = "Real Torch water check",
	nodenames = {
		"default:torch", "default:torch_wall", "default:torch:ceiling",
		"real_torch:torch", "real_torch:torch_wall", "real_torch:torch_ceiling"
	},
	neighbors = {"group:water"},
	interval = 5,
	chance = 1,
	catch_up = false,

	action = function(pos, node)

		local num = #minetest.find_nodes_in_area(
			{x = pos.x - 1, y = pos.y, z = pos.z},
			{x = pos.x + 1, y = pos.y, z = pos.z},
			{"group:water"})

		if num == 0 then
			num = num + #minetest.find_nodes_in_area(
				{x = pos.x, y = pos.y, z = pos.z - 1},
				{x = pos.x, y = pos.y, z = pos.z + 1},
				{"group:water"})
		end

		if num == 0 then
			num = num + #minetest.find_nodes_in_area(
				{x = pos.x, y = pos.y + 1, z = pos.z},
				{x = pos.x, y = pos.y + 1, z = pos.z},
				{"group:water"})
		end

		if num > 0 then
			minetest.set_node(pos, {name = "air"})

			minetest.sound_play({name="real_torch_extinguish", gain = 0.2},
				{pos = pos, max_hear_distance = 10})

			minetest.add_item(pos, {name = "real_torch:torch"})
		end
	end,
})

end
