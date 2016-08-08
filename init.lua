pep = {}
function pep.register_potion(potiondef)
	local on_use
	if(potiondef.effect_type ~= nil) then
		on_use = function(itemstack, user, pointed_thing)
			playereffects.apply_effect_type(potiondef.effect_type, potiondef.duration, user)
			itemstack:take_item()
			return itemstack
		end
	else
		on_use = function(itemstack, user, pointed_thing)
			itemstack:take_item()
			return itemstack
		end
	end
	minetest.register_craftitem("pep:"..potiondef.basename, {
		description = "Glass Bottle ("..potiondef.contentstring..")",
		inventory_image = "pep_"..potiondef.basename..".png",
		wield_image = "pep_"..potiondef.basename..".png",
		on_use = on_use,
	})
end

pep.moles = {}

function pep.enable_mole_mode(playername)
	pep.moles[playername] = true
end

function pep.disable_mole_mode(playername)
	pep.moles[playername] = false
end

function pep.yaw_to_vector(yaw)
	local tau = math.pi*2

	yaw = yaw % tau
	if yaw < tau/8 then
		return { x=0, y=0, z=1}
	elseif yaw < (3/8)*tau then
		return { x=-1, y=0, z=0 }
	elseif yaw < (5/8)*tau then
		return { x=0, y=0, z=-1 }
	elseif yaw < (7/8)*tau then
		return { x=1, y=0, z=0 }
	else
		return { x=0, y=0, z=1}
	end
end

function pep.moledig(playername)
	local player = minetest.get_player_by_name(playername)

	local yaw = player:get_look_yaw()
	-- fix stupid oddity of Minetest, adding pi/2 to the actual player's look yaw...
	-- TODO: Remove this code as soon as Minetest fixes this.
	yaw = yaw - math.pi/2

	local pos = vector.round(player:getpos())

	local v = pep.yaw_to_vector(yaw)

	local digpos1 = vector.add(pos, v)
	local digpos2 = { x = digpos1.x, y = digpos1.y+1, z = digpos1.z }

	local try_dig = function(pos)
		local n = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[n.name]
		if ndef.walkable and ndef.diggable then
			if ndef.can_dig ~= nil then
				if ndef.can_dig() then
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	end

	local dig = function(pos)
		if try_dig(pos) then
			local n = minetest.get_node(pos)
			local ndef = minetest.registered_nodes[n.name]
			if ndef.sounds ~= nil then
				minetest.sound_play(ndef.sounds.dug, { pos = pos })
			end
			-- TODO: Replace this code as soon Minetest removes support for this function
			local drops = minetest.get_node_drops(n.name, "default:pick_steel")
			minetest.dig_node(pos)
			local inv = player:get_inventory()
			local leftovers = {}
			for i=1,#drops do
				table.insert(leftovers, inv:add_item("main", drops[i]))
			end
			for i=1,#leftovers do
				minetest.add_item(pos, leftovers[i])
			end
		end
	end

	dig(digpos1)
	dig(digpos2)
end

pep.timer = 0

minetest.register_globalstep(function(dtime)
	pep.timer = pep.timer + dtime
	if pep.timer > 0.5 then
		for playername, is_mole in pairs(pep.moles) do
			if is_mole then
				pep.moledig(playername)
			end
		end
		pep.timer = 0
	end
end)

playereffects.register_effect_type("pepspeedplus", "High speed", "pep_speedplus.png", {"speed"},
	function(player)
		player:set_physics_override({speed=2})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepspeedminus", "Low speed", "pep_speedminus.png", {"speed"},
	function(player)
		player:set_physics_override({speed=0.5})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepspeedreset", "Speed neutralizer", "pep_speedreset.png", {"speed"},
	function() end, function() end)
playereffects.register_effect_type("pepjumpplus", "High jump", "pep_jumpplus.png", {"jump"},
	function(player)
		player:set_physics_override({jump=2})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepjumpminus", "Low jump", "pep_jumpminus.png", {"jump"},
	function(player)
		player:set_physics_override({jump=0.5})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepjumpreset", "Jump height neutralizer", "pep_jumpreset.png", {"jump"},
	function() end, function() end)
playereffects.register_effect_type("pepgrav0", "No gravity", "pep_grav0.png", {"gravity"},
	function(player)
		player:set_physics_override({gravity=0})
	end,
	function(effect, player)
		player:set_physics_override({gravity=1})
	end
)
playereffects.register_effect_type("pepgravreset", "Gravity neutralizer", "pep_gravreset.png", {"gravity"},
	function() end, function() end)
playereffects.register_effect_type("pepregen", "Regeneration", "pep_regen.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 2
)
playereffects.register_effect_type("pepregen2", "Strong regeneration", "pep_regen2.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+2)
	end,
	nil, nil, nil, 1
)

if minetest.get_modpath("mana") ~= nil then
	playereffects.register_effect_type("pepmanaregen", "Weak mana boost", "pep_manaregen.png", {"mana"},
		function(player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) + 0.5)
		end,
		function(effect, player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) - 0.5)
		end
	)
	playereffects.register_effect_type("pepmanaregen2", "Strong mana boost", "pep_manaregen2.png", {"mana"},
		function(player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) + 1)
		end,
		function(effect, player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) - 1)
		end
	)
end


playereffects.register_effect_type("pepbreath", "Perfect breath", "pep_breath.png", {"breath"},
	function(player)
		player:set_breath(player:get_breath()+2)
	end,
	nil, nil, nil, 1
)
playereffects.register_effect_type("pepmole", "Mole mode", "pep_mole.png", {"autodig"},
	function(player)
		pep.enable_mole_mode(player:get_player_name())
	end,
	function(effect, player)
		pep.disable_mole_mode(player:get_player_name())
	end
)

pep.register_potion({
	basename = "speedplus",
	contentstring = "Running Potion",
	effect_type = "pepspeedplus",
	duration = 30
})

pep.register_potion({
	basename = "speedminus",
	contentstring = "Slug Potion",
	effect_type = "pepspeedminus",
	duration = 30
})
pep.register_potion({
	basename = "speedreset",
	contentstring = "Speed Neutralizer",
	effect_type = "pepspeedreset",
	duration = 0
})
pep.register_potion({
	basename = "breath",
	contentstring = "Air Potion",
	effect_type = "pepbreath",
	duration = 30,
})
pep.register_potion({
	basename = "regen",
	contentstring = "Weak Healing Potion",
	effect_type = "pepregen",
	duration = 10,
})
pep.register_potion({
	basename = "regen2",
	contentstring = "Strong Healing Potion",
	effect_type = "pepregen2",
	duration = 10,
})
pep.register_potion({
	basename = "grav0",
	contentstring = "Non-Gravity Potion",
	effect_type = "pepgrav0",
	duration = 20,
})
pep.register_potion({
	basename = "gravreset",
	contentstring = "Gravity Neutralizer",
	effect_type = "pepgravreset",
	duration = 0,
})
pep.register_potion({
	basename = "jumpplus",
	contentstring = "High Jumping Potion",
	effect_type = "pepjumpplus",
	duration = 30,
})
pep.register_potion({
	basename = "jumpminus",
	contentstring = "Low Jumping Potion",
	effect_type = "pepjumpminus",
	duration = 30,
})
pep.register_potion({
	basename = "jumpreset",
	contentstring = "Jump Neutralizer",
	effect_type = "pepjumpreset",
	duration = 0,
})
pep.register_potion({
	basename = "mole",
	contentstring = "Mole Potion",
	effect_type = "pepmole",
	duration = 18,
})
if(minetest.get_modpath("mana")~=nil) then
	pep.register_potion({
		basename = "manaregen",
		contentstring = "Weak Mana Potion",
		effect_type = "pepmanaregen",
		duration = 10,
	})
	pep.register_potion({
		basename = "manaregen2",
		contentstring = "Strong Mana Potion",
		effect_type = "pepmanaregen2",
		duration = 10,
	})
end


--[=[ register crafts ]=]
--[[ normal potions ]]
if(minetest.get_modpath("vessels")~=nil) then
if(minetest.get_modpath("default")~=nil) then
	minetest.register_craft({
		type = "shapeless",
		output = "pep:breath",
		recipe = { "default:papyrus", "default:papyrus", "default:papyrus", "default:papyrus",
			   "default:papyrus", "default:papyrus", "default:papyrus", "default:papyrus", "vessels:glass_bottle" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:speedminus",
		recipe = { "default:dry_grass_1", "default:ice", "vessels:glass_bottle" }
	})
	if(minetest.get_modpath("flowers") ~= nil) then
		minetest.register_craft({
			type = "shapeless",
			output = "pep:jumpplus",
			recipe = { "flowers:flower_tulip", "default:grass_1", "default:mese_crystal_fragment",
				   "default:mese_crystal_fragment", "vessels:glass_bottle" }
		})
		minetest.register_craft({
			type = "shapeless",
			output = "pep:poisoner",
			recipe = { "flowers:mushroom_red", "flowers:mushroom_red", "flowers:mushroom_red", "vessels:glass_bottle" }
		})

		if(minetest.get_modpath("farming") ~= nil) then
			minetest.register_craft({
				type = "shapeless",
				output = "pep:regen",
				recipe = { "default:cactus", "farming:flour", "flowers:mushroom_brown", "vessels:glass_bottle" }
			})
		end
	end
	if(minetest.get_modpath("farming") ~= nil) then
		minetest.register_craft({
			type = "shapeless",
			output = "pep:regen2",
			recipe = { "default:gold_lump", "farming:flour", "pep:regen" }
		})
		if minetest.get_modpath("mana") ~= nil then
			minetest.register_craft({
				type = "shapeless",
				output = "pep:manaregen",
				recipe = { "default:dry_shrub", "default:dry_shrub", "farming:seed_cotton", "default:mese_crystal_fragment",
					   "vessels:glass_bottle" }
			})
		end
	end
	if minetest.get_modpath("mana") ~= nil then
		minetest.register_craft({
			type = "shapeless",
			output = "pep:manaregen2",
			recipe = { "default:dry_shrub", "default:dry_shrub", "default:dry_shrub", "default:dry_shrub", "default:junglesapling",
				   "default:acacia_sapling", "default:mese_crystal_fragment", "pep:manaregen" }
		})
	end

	minetest.register_craft({
		type = "shapeless",
		output = "pep:jumpminus",
		recipe = { "default:leaves", "default:jungleleaves", "default:iron_lump", "flowers:dandelion_yellow", "vessels:glass_bottle" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:grav0",
		recipe = { "default:mese_crystal", "vessels:glass_bottle" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:mole",
		recipe = { "default:pick_steel", "default:shovel_steel", "vessels:glass_bottle" },
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:gravreset" ,
		recipe = { "pep:grav0", "default:iron_lump" }
	})
end
if(minetest.get_modpath("flowers") ~= nil) then
	minetest.register_craft({
		type = "shapeless",
		output = "pep:speedplus",
		recipe = { "default:pine_sapling", "default:cactus", "flowers:dandelion_yellow", "default:junglegrass", "vessels:glass_bottle" }
	})
end
end

--[[ independent crafts ]]

minetest.register_craft({
	type = "shapeless",
	output = "pep:speedreset",
	recipe = { "pep:speedplus", "pep:speedminus" }
})
minetest.register_craft({
	type = "shapeless",
	output = "pep:jumpreset",
	recipe = { "pep:jumpplus", "pep:jumpminus" }
})



if minetest.get_modpath("doc_items") ~= nil then
	doc.sub.items.set_items_longdesc({
		["pep:grav0"] = "When you drink this potion, gravity stops affecting you, as if you were in space. The effect lasts for 20 seconds.",
		["pep:gravreset"] = "Drinking it will stop all gravity effects you currently have.",
		["pep:breath"] = "Drinking it gives you breath underwater for 30 seconds.",
		["pep:jumpplus"] = "Drinking it will make you jump higher for 30 seconds.",
		["pep:jumpminus"] = "Drinking it will make you jump lower for 30 seconds.",
		["pep:jumpreset"] = "Drinking it will stop all jumping effects you may currently have.",
		["pep:speedplus"] = "Drinking it will make you run faster for 30 seconds.",
		["pep:speedminus"] = "Drinking it will make you walk slower for 30 seconds.",
		["pep:speedreset"] = "Drinking it will stop all speed effects you may currently have.",
		["pep:regen"] = "Drinking it makes you regnerate health. Every 2 seconds, you get 1 HP, 10 times in total.",
		["pep:regen2"] = "Drinking it makes you regnerate health quickly. Every second you get 2 HP, 10 times in total.",
		["pep:mole"] = "Drinking it will start an effect which will magically attempt to mine any two blocks in front of you horizontally, as if you were using a steel pickaxe on them. The effect lasts for 18 seconds.",
		["pep:manaregen"] = "Drinking it will increase your mana regeneration rate by 0.5 for 10 seconds.",
		["pep:manaregen2"] = "Drinking it will increase your mana regeneration rate by 1 for 10 seconds.",
	})
	local use = "Hold it in your hand, then leftclick to drink it."
	doc.sub.items.set_items_usagehelp({
		["pep:grav0"] = use,
		["pep:gravreset"] = use,
		["pep:breath"] = use,
		["pep:jumpplus"] = use,
		["pep:jumpminus"] = use,
		["pep:jumpreset"] = use,
		["pep:speedplus"] = use,
		["pep:speedminus"] = use,
		["pep:speedreset"] = use,
		["pep:regen"] = use,
		["pep:regen2"] = use,
		["pep:mole"] = use,
		["pep:manaregen"] = use,
		["pep:manaregen2"] = use,
	})
end
