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
	minetest.register_node("pep:"..potiondef.basename, {
		description = "Glass Bottle ("..potiondef.contentstring..")",
		drawtype = "plantlike",
		tiles = { "pep_"..potiondef.basename..".png" },
		inventory_image = "pep_"..potiondef.basename.."_inv.png",
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.4, 0.25 },
		},
		groups = { vessel = 1, dig_immediate = 3, attached_node =1},
		sounds = default.node_sound_glass_defaults(),
		on_use = on_use,
	})
end

playereffects.register_effect_type("pepspeedplus", "High speed", nil, {"speed"},
	function(player)
		player:set_physics_override({speed=2})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepspeedminus", "Low speed", nil, {"speed"},
	function(player)
		player:set_physics_override({speed=0.5})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepjumpplus", "High jump", nil, {"jump"},
	function(player)
		player:set_physics_override({jump=2})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepjumpminus", "Low jump", nil, {"jump"},
	function(player)
		player:set_physics_override({jump=0.5})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepfloat", "No gravity", nil, {"gravity"},
	function(player)
		player:set_physics_override({gravity=0})
	end,
	function(effect, player)
		player:set_physics_override({gravity=1})
	end
)
playereffects.register_effect_type("pepregen", "Regeneration", nil, {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 2
)
playereffects.register_effect_type("pepregen2", "Strong regeneration", nil, {"health"},
	function(player)
		player:set_hp(player:get_hp()+2)
	end,
	nil, nil, nil, 1
)

playereffects.register_effect_type("peppoison", "Poisoned", nil, {"health"},
	function(player)
		player:set_hp(player:get_hp()-1)
	end,
	nil, nil, nil, 2
)
playereffects.register_effect_type("pepbreath", "Perfect breath", nil, {"breath"},
	function(player)
		player:set_breath(player:get_breath()+2)
	end,
	nil, nil, nil, 1
)

pep.register_potion({
	basename = "water",
	contentstring = "Water",
	effect_type = nil,
})

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
	basename = "breath",
	contentstring = "Air Potion",
	effect_type = "pepbreath",
	duration = 60,
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
	basename = "float",
	contentstring = "Non-Gravity Potion",
	effect_type = "pepfloat",
	duration = 20,
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

--[[ register crafts ]]
if(minetest.get_modpath("default") ~= nil) then
	minetest.register_craft({
		type = "shapeless",
		output = "pep:breath",
		recipe = { "default:papyrus", "pep:water" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:speedminus",
		recipe = { "default:dry_shrub", "pep:water" }
	})
	if(minetest.get_modpath("flowers") ~= nil) then
		minetest.register_craft({
			type = "shapeless",
			output = "pep:jumpplus",
			recipe = { "flowers:flower_geranium", "default:grass_1", "pep:water" }
		})
		minetest.register_craft({
			type = "shapeless",
			output = "pep:speedplus",
			recipe = { "flowers:rose", "flowers:dandelion_yellow", "pep:water" }
		})
	end
	minetest.register_craft({
		type = "shapeless",
		output = "pep:jumpminus",
		recipe = { "default:leaves", "default:jungleleaves", "pep:water" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:regen",
		recipe = { "default:cactus", "default:junglegrass", "pep:water" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:regen2",
		recipe = { "default:gold_lump", "pep:regen" }
	})
	minetest.register_craft({
		type = "shapeless",
		output = "pep:float",
		recipe = { "default:mese_crystal", "pep:water" }
	})
end
