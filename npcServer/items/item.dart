part of coUserver;

class Item extends Object with MetabolicsChange, Consumable, Cubimal, CubimalBox, Emblem {
	/// Discounts, stored as itemType: part paid out of 1 (eg. 0.8 for 20% off)
	static Map<String, num> discountedItems = {
		"knife_and_board": 0.75
	};

	@Field() String category, iconUrl, spriteUrl, toolAnimation, name, description, itemType, item_id;
	@Field() int price, stacksTo, iconNum = 4, durability, durabilityUsed = 0, subSlots = 0;
	@Field() num x, y;
	@Field() bool onGround = false, isContainer = false;
	@Field() List<String> subSlotFilter;
	@Field() List<Action> actions = [];
	@Field() Map<String, dynamic> metadata = {};

	Action dropAction = new Action.withName('drop')
		..description = "Drop this item on the ground.";
	Action pickupAction = new Action.withName('pickup')
		..description = "Put this item in your bags.";

	num get discount {
		if (discountedItems[itemType] != null) {
			return discountedItems[itemType];
		} else {
			return 1;
		}
	}

	Item();

	Item.clone(this.itemType) {
		Item model = items[itemType];
		category = model.category;
		iconUrl = model.iconUrl;
		spriteUrl = model.spriteUrl;
		toolAnimation = model.toolAnimation;
		name = model.name;
		description = model.description;
		price = model.price;
		stacksTo = model.stacksTo;
		iconNum = model.iconNum;
		durability = model.durability;
		x = model.x;
		y = model.y;
		isContainer = model.isContainer;
		subSlots = model.subSlots;
		subSlotFilter = model.subSlotFilter;
		metadata = model.metadata;
		actions = model.actions;

		bool found = false;
		actions.forEach((Action action) {
			if (action.name == 'drop') {
				found = true;
			}
		});

		if (!found) {
			actions.insert(0, dropAction);
		}
	}

	Map getMap() {
		return {
			"iconUrl":iconUrl,
			"spriteUrl":spriteUrl,
			"name":name,
			"itemType":itemType,
			"category":category,
			"isContainer":isContainer,
			"description":description,
			"price":price,
			"stacksTo":stacksTo,
			"iconNum":iconNum,
			"id":item_id,
			"onGround":onGround,
			"x":x,
			"y":y,
			"actions":actionList,
			"tool_animation": toolAnimation,
			"durability": durability,
			"durabilityUsed": durabilityUsed,
			"subSlots": subSlots,
			"metadata": metadata,
			"discount": discount
		};
	}

	List<Map> get actionList {
		if (onGround) {
			return [encode(pickupAction)];
		} else {
			List<Map> result = encode(actions);
			bool found = false;
			actions.forEach((Action action) {
				if (action.name == 'drop') {
					found = true;
				}
			});
			if (!found) {
				result.insert(0, encode(dropAction));
			}
			return result;
		}
	}

	bool filterAllows({Item testItem, String itemType}) {
		assert(testItem != null || itemType != null);

		if(itemType.isEmpty) {
			//bags except empty item types (this is an empty slot)
			return true;
		}

		if(testItem == null) {
			testItem = items[itemType];
		}

		if (subSlotFilter.length == 0) {
			return !testItem.isContainer;
		} else {
			return subSlotFilter.contains(testItem.itemType);
		}
	}

	// Client-Sent Actions //////////////////////////////////////////////////////////////////////////

	// ////////////////////// //
	// Used by multiple items //
	// ////////////////////// //

	Future<bool> sniff({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		if (itemInSlot.itemType == "butterfly_milk") {
			return await Item_Cheese.sniff(userSocket, email);
		} else if (itemInSlot.itemType == "very_very_stinky_cheese") {
			return await Item_Milk.sniff(userSocket, username);
		} else {
			return false;
		}
	}

	// ////////////// //
	// Butterfly Milk //
	// ////////////// //

	Future<bool> shakeBottle({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Milk.shakeBottle(userSocket, username, email);
	}

	// //////////////// //
	// Butterfly Butter //
	// //////////////// //

	Future<bool> compress({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Butter.compress(userSocket, email);
	}

	// ////// //
	// Cheese //
	// ////// //

	Future<bool> age({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Cheese.age(map, userSocket, email);
	}

	Future<bool> prod({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Cheese.prod(userSocket, email);
	}

	Future<bool> sniffCheese(String streetName, Map map, WebSocket userSocket, String email, String username) async {
		return await Item_Cheese.sniff(userSocket, email);
	}

	// //////////////// //
	// Butterfly Lotion //
	// //////////////// //

	Future<bool> taste({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		toast("That didn't taste as good as it smells. -5 mood", userSocket);
		return await ItemUser.trySetMetabolics(username, mood:-5);
	}

	// //////////// //
	// Focusing Orb //
	// //////////// //

	Future<bool> levitate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.levitate(userSocket);
	}

	Future<bool> focusEnergy({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.focusEnergy(userSocket, username);
	}

	Future<bool> focusMood({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.focusMood(userSocket, username);
	}

	Future<bool> radiate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.radiate(streetName, username);
	}

	Future<bool> meditate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.meditate(userSocket, username);
	}

	// //// //
	// Icon //
	// //// //

	Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(username, currants:-100);
	}

	Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsRuminated", 11);
		return await ItemUser.trySetMetabolics(username, mood:50);
	}

	Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsRevered", 11);
		return await ItemUser.trySetMetabolics(username, energy:50);
	}

	Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(username, img:50);
	}

	// //// //
	// Item //
	// //// //

	// ground -> inventory

	Future pickup({WebSocket userSocket, String email, String username}) async {
		onGround = false;
		Item item = new Item.clone(itemType)
			..onGround = false
			..metadata = this.metadata;
		await InventoryV2.addItemToUser(email, item.getMap(), 1, item_id);
		StatBuffer.incrementStat("itemsPickedup", 1);
	}

	// inventory -> ground

	Future drop({WebSocket userSocket, Map map, String streetName, String email, String username}) async {

		Item droppedItem = await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], map['count']);
		if (droppedItem == null) {
			return;
		}

		droppedItem.putItemOnGround(map['x'],map['y'],streetName);

		StatBuffer.incrementStat("itemsDropped", map['count']);
	}

	putItemOnGround(num x, num y, String streetName) {
		String randString = new Random().nextInt(1000).toString();
		String id = "i" + createId(x, y, itemType, streetName+randString);
		Item item = new Item.clone(itemType)
			..x = x
			..y = y
			..item_id = id
			..onGround = true
			..metadata = this.metadata;

		StreetUpdateHandler.streets[streetName].groundItems[id] = item;
	}

	// /////// //
	// Recipes //
	// /////// //

	// Alchemical Tongs
	Future alchemize({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Awesome Pot
	Future cook({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.awesome_pot_uses++;
			stats.write();
			if (stats.awesome_pot_uses >= 11) {
				Achievement.find("1star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 23) {
				Achievement.find("2star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 41) {
				Achievement.find("3star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 79) {
				Achievement.find("4star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 101) {
				Achievement.find("5star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 137) {
				Achievement.find("golden_ladle_award").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Beaker
	// Test Tube
	Future stir({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Bean Seasoner
	// Egg Seasoner
	Future season({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			if (map["itemType"] == "bean_seasoner") {
				stats.beans_seasoned++;
				if (stats.beans_seasoned >= 53) {
					Achievement.find("beanorator_2nd_class").awardTo(email);
				} else if (stats.beans_seasoned >= 503) {
					Achievement.find("beanorator_1st_class").awardTo(email);
				} else if (stats.beans_seasoned >= 2003) {
					Achievement.find("generalissimo_beanorator").awardTo(email);
				}
			} else if (map["itemType"] == "egg_seasoner") {
				stats.eggs_seasoned++;
				if (stats.eggs_seasoned >= 53) {
					Achievement.find("egg_transmutator_apprentice").awardTo(email);
				} else if (stats.eggs_seasoned >= 503) {
					Achievement.find("egg_transmutator_pro").awardTo(email);
				} else if (stats.eggs_seasoned >= 2003) {
					Achievement.find("egg_transmutator_maxi_pro").awardTo(email);
				}
			}
			stats.write();
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Blender
	Future blend({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.blender_uses++;
			stats.write();
			if (stats.blender_uses >= 11) {
				Achievement.find("pulse_frappe_mix_blend").awardTo(email);
			} else if (stats.blender_uses >= 23) {
				Achievement.find("high_speed_commingler").awardTo(email);
			} else if (stats.blender_uses >= 41) {
				Achievement.find("blendmaster").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Bubble Tuner
	Future tuneBubbles({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.bubbles_transformed++;
			stats.write();
			StatCollection.find(email).then((StatCollection stats) {
				stats.bubbles_transformed++;
				stats.write();
				if (stats.bubbles_transformed >= 53) {
					Achievement.find("bubble_coaxer").awardTo(email);
				} else if (stats.bubbles_transformed >= 503) {
					Achievement.find("effervescence_consultant").awardTo(email);
				} else if (stats.bubbles_transformed >= 2003) {
					Achievement.find("bubble_transubstantiator").awardTo(email);
				}
			});
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Cauldron
	Future brew({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Cocktail Shaker
	Future shake({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.cocktail_shaker_uses++;
			stats.write();
			if (stats.cocktail_shaker_uses >= 11) {
				Achievement.find("mediocre_mixologist").awardTo(email);
			} else if (stats.cocktail_shaker_uses >= 23) {
				Achievement.find("middling_mixologist").awardTo(email);
			} else if (stats.cocktail_shaker_uses >= 41) {
				Achievement.find("superior_mixologist").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Construction Tool
	Future construct({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Famous Pugilist Grill
	Future grill({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.grill_uses++;
			stats.write();
			if (stats.grill_uses >= 11) {
				Achievement.find("brazier_apprentice").awardTo(email);
			} else if (stats.grill_uses >= 23) {
				Achievement.find("grill_jockey").awardTo(email);
			} else if (stats.grill_uses >= 41) {
				Achievement.find("master_carbonifier").awardTo(email);
			} else if (stats.grill_uses >= 79) {
				Achievement.find("killer_griller").awardTo(email);
			} else if (stats.grill_uses >= 137) {
				Achievement.find("broil_king").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Fruit Changing Machine
	Future convertFruit({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.fruit_converted++;
			stats.write();
			if (stats.fruit_converted >= 53) {
				Achievement.find("novice_fruit_metamorphosizer").awardTo(email);
			} else if (stats.fruit_converted >= 503) {
				Achievement.find("intermediate_fruit_metamorphosizer").awardTo(email);
			} else if (stats.fruit_converted >= 2003) {
				Achievement.find("fruit_metamorphosizin_tycoon").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Gassifier
	Future convertGas({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.gas_converted++;
			stats.write();
			if (stats.gas_converted >= 53) {
				Achievement.find("gas_dabbler").awardTo(email);
			} else if (stats.gas_converted >= 503) {
				Achievement.find("bonafide_gas_wrangler").awardTo(email);
			} else if (stats.gas_converted >= 2003) {
				Achievement.find("gastronaut").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Grinders
	Future crush({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Frying Pan
	Future fry({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.frying_pan_uses++;
			stats.write();
			if (stats.frying_pan_uses >= 11) {
				Achievement.find("decent_hash_slinger").awardTo(email);
			} else if (stats.frying_pan_uses >= 23) {
				Achievement.find("pretty_good_griddler").awardTo(email);
			} else if (stats.frying_pan_uses >= 41) {
				Achievement.find("grease_monkey").awardTo(email);
			} else if (stats.frying_pan_uses >= 79) {
				Achievement.find("saute_savant").awardTo(email);
			} else if (stats.frying_pan_uses >= 137) {
				Achievement.find("sizzler_supreme").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Knife and Board
	Future chop({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.knife_board_uses++;
			stats.write();
			if (stats.knife_board_uses >= 11) {
				Achievement.find("able_chopper").awardTo(email);
			} else if (stats.knife_board_uses >= 23) {
				Achievement.find("fine_mincer").awardTo(email);
			} else if (stats.knife_board_uses >= 41) {
				Achievement.find("nice_dicer").awardTo(email);
			} else if (stats.knife_board_uses >= 79) {
				Achievement.find("silver_cleaver_award").awardTo(email);
			} else if (stats.knife_board_uses >= 137) {
				Achievement.find("master_whacker").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Loomer
	Future loom({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Saucepan
	Future simmer({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.sauce_pan_uses++;
			stats.write();
			if (stats.sauce_pan_uses >= 11) {
				Achievement.find("rolling_boiler").awardTo(email);
			} else if (stats.sauce_pan_uses >= 23) {
				Achievement.find("roux_guru").awardTo(email);
			} else if (stats.sauce_pan_uses >= 41) {
				Achievement.find("gravy_maven").awardTo(email);
			} else if (stats.sauce_pan_uses >= 79) {
				Achievement.find("super_saucier").awardTo(email);
			} else if (stats.sauce_pan_uses >= 137) {
				Achievement.find("a1_saucier").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Smelter
	Future smelt({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Spice Mill
	Future mill({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatCollection.find(email).then((StatCollection stats) {
			stats.spice_milled++;
			stats.write();
			if (stats.spice_milled >= 53) {
				Achievement.find("spice_intern").awardTo(email);
			} else if (stats.spice_milled >= 503) {
				Achievement.find("assistant_spice_manager").awardTo(email);
			} else if (stats.spice_milled >= 2003) {
				Achievement.find("executive_in_charge_of_spice_reformatation").awardTo(email);
			}
		});
		return Recipe.useItem(map, userSocket,email);
	}

	// Spindles
	Future spin({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Tincturing Kit
	Future tincture({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}

	// Tinkertool
	Future tinker({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket,email);
	}
}