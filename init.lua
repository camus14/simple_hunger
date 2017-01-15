minetest.register_tool("simple_hunger:golden_apple", {
	description = "Golden Apple",
	inventory_image = "golden_apple.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
		},
		damage_groups = {},
	},
})

minetest.register_craft({
	output = "simple_hunger:golden_apple",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:gold_ingot", "default:apple", "default:gold_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
	}
})

local golden_apple = function(player)
	local inv = player:get_inventory()
	local it = inv:get_stack("main", 8)
	if it:get_name() == "simple_hunger:golden_apple" then
		if inv:get_stack("fatiga", 1):get_count() >= 10 then
			inv:set_stack("fatiga", 1, ItemStack({name=":", count=inv:get_stack("fatiga", 1):get_count()-10}))
			it:add_wear(1456)
			inv:set_stack("main", 8, it)
			if inv:get_stack("fatiga", 1):get_count() >= 20 then
				inv:set_stack("fatiga", 1, ItemStack({name=":", count=0}))
			else
			end
			player:hud_change(1, 5, 20 - inv:get_stack("fatiga", 1):get_count())
		end
	end
	end

local ftg = function(player, costo)
	local inv = player:get_inventory()
	local valor = inv:get_stack("fatiga", 1):get_count()
	inv:set_stack("fatiga", 1, ItemStack({name=":", count=valor+costo}))
	if inv:get_stack("fatiga", 1):get_count() > 20 then
		local czs = player:get_hp()
		player:set_hp(czs-costo)
		inv:set_stack("fatiga", 1, ItemStack({name=":", count=20}))
	else
	end
	player:hud_change(1, 5, 20 - inv:get_stack("fatiga", 1):get_count())
end

local comer = function(itemstack, player, mzn, crz)			
	itemstack:take_item()
	local vida = player:get_hp()
	player:set_hp(vida+crz)
	local inv = player:get_inventory()
	inv:set_stack("fatiga", 1, ItemStack({name=":", count=inv:get_stack("fatiga", 1):get_count()-mzn}))
	if inv:get_stack("fatiga", 1):get_count() >= 20 then
		inv:set_stack("fatiga", 1, ItemStack({name=":", count=0}))
	else
	end
	player:hud_change(1, 5, 20 - inv:get_stack("fatiga", 1):get_count())
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_size("fatiga",1)
	if inv:get_stack("fatiga", 1):get_count() == nil then
		inv:set_stack("fatiga", 1, ItemStack({name=":", count=0}))
	else
	end
	player:hud_add({
		hud_elem_type = "statbar",
		position = {x=0.5,y=1},
		size = "",
		text = "hunger_hud.png",
		number = 20 - inv:get_stack("fatiga", 1):get_count(),
		alignment = {x=0,y=1},
		offset = {x=-265, y=-120},
	})
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_stack("fatiga", 1, ItemStack({name=":", count=0}))
	player:hud_change(1, 5, 20 - inv:get_stack("fatiga", 1):get_count())
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	ftg(digger, 2)
	golden_apple(digger)
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	ftg(placer, 1)
<<<<<<< HEAD
	golden_apple(placer)
=======
>>>>>>> 982682f37668fbdefef875a39c363b590de0e8ff
end)

minetest.override_item("default:apple", {
	on_use = function(itemstack, player, pointed_thing)
			comer(itemstack, player, 6, 4)
			return itemstack
	end,
})

minetest.override_item("farming:bread", {
	on_use = function(itemstack, player, pointed_thing)
			comer(itemstack, player, 20, 8)
			return itemstack
	end,
})

farming.hoe_on_use = function(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.get_node(p)

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end

	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end

	-- check if (wet) soil defined
	local regN = minetest.registered_nodes
	if regN[under.name].soil == nil or regN[under.name].soil.wet == nil or regN[under.name].soil.dry == nil then
		return
	end

	if minetest.is_protected(pt.under, user:get_player_name()) then
		minetest.record_protection_violation(pt.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, user:get_player_name()) then
		minetest.record_protection_violation(pt.above, user:get_player_name())
		return
	end

	-- turn the node into soil, wear out item and play sound
	minetest.set_node(pt.under, {name = regN[under.name].soil.dry})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})

	ftg(user, 1)
	golden_apple(user)

	if not minetest.setting_getbool("creative_mode") then
		itemstack:add_wear(65535/(uses-1))
	end
	return itemstack
end

farming.place_seed = function(itemstack, placer, pointed_thing, plantname)
	local function tick(pos)
		minetest.get_node_timer(pos):start(math.random(166, 286))
	end
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return itemstack
	end
	if pt.type ~= "node" then
		return itemstack
	end

	local under = minetest.get_node(pt.under)
	local above = minetest.get_node(pt.above)

	if minetest.is_protected(pt.under, placer:get_player_name()) then
		minetest.record_protection_violation(pt.under, placer:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, placer:get_player_name()) then
		minetest.record_protection_violation(pt.above, placer:get_player_name())
		return
	end

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return itemstack
	end
	if not minetest.registered_nodes[above.name] then
		return itemstack
	end

	-- check if pointing at the top of the node
	if pt.above.y ~= pt.under.y+1 then
		return itemstack
	end

	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return itemstack
	end

	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") < 2 then
		return itemstack
	end

	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pt.above, {name = plantname, param2 = 1})
	tick(pt.above)
	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end

	ftg(placer, 1)
	golden_apple(placer)

	return itemstack
end

function default.sapling_on_place(itemstack, placer, pointed_thing,
		sapling_name, minp_relative, maxp_relative, interval)
	-- Position of sapling
	local pos = pointed_thing.under
	local node = minetest.get_node(pos)
	local pdef = minetest.registered_nodes[node.name]
	if not pdef or not pdef.buildable_to then
		pos = pointed_thing.above
		node = minetest.get_node(pos)
		pdef = minetest.registered_nodes[node.name]
		if not pdef or not pdef.buildable_to then
			return itemstack
		end
	end

	local player_name = placer:get_player_name()
	-- Check sapling position for protection
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return itemstack
	end
	-- Check tree volume for protection
	if not default.intersects_protection(
			vector.add(pos, minp_relative),
			vector.add(pos, maxp_relative),
			player_name,
			interval) then
		minetest.set_node(pos, {name = sapling_name})
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
	else
		minetest.record_protection_violation(pos, player_name)
		-- Print extra information to explain
		minetest.chat_send_player(player_name, "Tree will intersect protection")
	end

	ftg(placer, 1)
	golden_apple(placer)

	return itemstack
end
