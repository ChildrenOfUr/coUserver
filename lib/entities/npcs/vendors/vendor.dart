part of entity;

Map<String, String> vendorTypes = {};

abstract class Vendor extends NPC {
	static Future<int> loadVendorTypes() async {
		String filePath = path.join(
			serverDir.path, 'lib', 'entities', 'npcs', 'vendors', 'vendors.json');
		JSON.decode(await new File(filePath).readAsString()).forEach((String street, String type) {
			vendorTypes[street] = type;
		});
		Log.verbose('[Vendor] Loaded ${vendorTypes.length} vendor types');
		return vendorTypes.length;
	}

	List<Map> itemsForSale = new List();
	String vendorType;
	List<Item> itemsToSell;
	bool itemsPredefined = false;

	/**
		FYI:
		'type' is the NPC type that is passed to the client for rendering, and is displayed to the user
		'vendorType' decides which items to sell, and is never displayed to the user
	 **/

	Vendor(String id, String streetName, String tsid, num x, num y, num z, num rotation, bool h_flip) : super(id, x, y, z, rotation, h_flip, streetName) {
		//vendor actions are instant
		actionTime = 0;
		type = "Street Spirit";
		actions.addAll([
						   new Action.withName('buy'),
						   new Action.withName('sell')
					   ]);

		if (!itemsPredefined) {
			itemsForSale.clear();

			String vendorType = vendorTypes[streetName];
			if (vendorType == null) {
				vendorType = getRandomVendorType();
			}

			switch (vendorType) {
				case 'alchemical':
					type = "Street Spirit: Alchemical Goods";
					itemsForSale = [
						items["still"].getMap(),
						items["tincturing_kit"].getMap(),
						items["cauldron"].getMap(),
						items["elemental_pouch"].getMap(),
						items["alchemistry_kit"].getMap(),
						items["alchemical_tongs"].getMap(),
						items["test_tube"].getMap(),
						items["beaker"].getMap(),
						items["pick"].getMap(),
						items["fancy_pick"].getMap(),
						items["scraper"].getMap(),
						items["grinder"].getMap(),
						items["smelter"].getMap(),
						items["crystalmalizing_chamber"].getMap(),
						items["firefly_jar"].getMap(),
					];
					break;

				case 'animal':
					type = "Street Spirit: Animal Goods";
					itemsForSale = [
						items["spindle"].getMap(),
						items["loomer"].getMap(),
						items["pig_stick"].getMap(),
						items["butterfly_stick"].getMap(),
						items["chicken_stick"].getMap(),
						items["butterfly_lotion"].getMap(),
						items["pig_bait"].getMap(),
						items["quill"].getMap(),
						items["egg_seasoner"].getMap(),
						items["butterfly_milker"].getMap(),
						items["piggy_feeder"].getMap(),
						items["meat_collector"].getMap()
					];
					break;

				case 'gardening':
					type = "Street Spirit: Gardening Goods";
					itemsForSale = [
						items["hoe"].getMap(),
						items["watering_can"].getMap(),
						items["hatchet"].getMap(),
						items["bean_seasoner"].getMap(),
						items["shovel"].getMap(),
						items["garden_gnome"].getMap(),
						items['broccoli_seed'].getMap(),
						items['cabbage_seed'].getMap(),
						items['carrot_seed'].getMap(),
						items['corn_seed'].getMap(),
						items['cucumber_seed'].getMap(),
						items['onion_seed'].getMap(),
						items['parsnip_seed'].getMap(),
						items['potato_seed'].getMap(),
						items['pumpkin_seed'].getMap(),
						items['rice_seed'].getMap(),
						items['spinach_seed'].getMap(),
						items['tomato_seed'].getMap(),
						items['zucchini_seed'].getMap()
					];
					break;

				case 'groceries':
					type = "Street Spirit: Groceries";
					itemsForSale = [
						items["coffee"].getMap(),
						items["honey"].getMap(),
						items["mushroom"].getMap(),
						items["mustard"].getMap(),
						items["oats"].getMap(),
						items["oily_dressing"].getMap(),
						items["olive_oil"].getMap(),
						items["sesame_oil"].getMap(),
						items["birch_syrup"].getMap(),
						items["beer"].getMap(),
						items["garlic"].getMap(),
						items["bun"].getMap()
					];
					break;

				case 'hardware':
					type = "Street Spirit: Hardware";
					itemsForSale = [
						items["gassifier"].getMap(),
						items["bubble_tuner"].getMap(),
						items["pick"].getMap(),
						items["fancy_pick"].getMap(),
						items["focusing_orb"].getMap(),
						items["grinder"].getMap(),
						items["tinkertool"].getMap(),
						items["hatchet"].getMap(),
						items["emotional_bear"].getMap(),
						items["lips"].getMap(),
						items["moon"].getMap(),
						items["smelter"].getMap(),
						items["alchemical_tongs"].getMap(),
						items["scraper"].getMap(),
						items["shovel"].getMap(),
						items["garden_gnome"].getMap(),
						items["crystalmalizing_chamber"].getMap(),
						items["machine_stand"].getMap(),
						items["blockmaker_chassis"].getMap(),
						items["blockmaker_plates"].getMap(),
						items["machine_engine"].getMap(),
						items["fuelmaker_case"].getMap(),
						items["fuelmaker_core"].getMap(),
						items["cauldron"].getMap(),
						items["tincturing_kit"].getMap(),
						items["still"].getMap(), //
						items["metalmaker_mechanism"].getMap(),
						items["metalmaker_tooler"].getMap(),
						items["woodworker_chassis"].getMap(),
						items["spindle"].getMap(), //
						items["loomer"].getMap(),
						items["construction_tool"].getMap(),
						items["bulb"].getMap()
					];
					itemsForSale.addAll(pickItems(["Storage"]));
					break;

				case 'kitchen':
					type = "Street Spirit: Kitchen Tools";
					itemsForSale = [
						items["knife_and_board"].getMap(),
						items["blender"].getMap(),
						items["frying_pan"].getMap(),
						items["saucepan"].getMap(),
						items["cocktail_shaker"].getMap(),
						items["famous_pugilist_grill"].getMap(),
						items["awesome_pot"].getMap(),
						items["fruit_changing_machine"].getMap(),
						items["spice_mill"].getMap(),
						items["spicerack"].getMap()
					];
					break;

				case 'mining':
					type = "Street Spirit: Mining";
					itemsForSale = [
						items["earthshaker"].getMap(),
						items["face_smelter"].getMap(),
						items["flaming_humbaba"].getMap(),
						items["pick"].getMap(),
						items["fancy_pick"].getMap(),
						items["grinder"].getMap(),
                        items["grand_ol_grinder"].getMap(),
						items["smelter"].getMap(),
						items["tinkertool"].getMap(),
						items["elemental_pouch"].getMap(),
						items["alchemical_tongs"].getMap()
					];
					break;

				case 'produce':
					type = "Street Spirit: Produce";
					itemsForSale = [
						items["garlic"].getMap(),
						items["broccoli"].getMap(),
						items["carrot"].getMap(),
						items["cabbage"].getMap(),
						items["corn"].getMap(),
						items["cucumber"].getMap(),
						items["onion"].getMap(),
						items["parsnip"].getMap(),
						items["potato"].getMap(),
						items["rice"].getMap(),
						items["spinach"].getMap(),
						items["tomato"].getMap(),
						items["zucchini"].getMap(),
						items["bubble_tuner"].getMap(),
						items["gassifier"].getMap()
					];
					break;

				case 'toy':
					type = "Street Spirit: Toys";
					itemsForSale = [
						items["dice"].getMap(),
						items["12_sided_die"].getMap(),
						items["fortune_cookie"].getMap(),
						items["cubimal_series_1_box"].getMap(),
						items["cubimal_series_2_box"].getMap(),
						items["cubimal_case"].getMap(),
						items["emotional_bear"].getMap(),
						items["lips"].getMap(),
						items["moon"].getMap(),
						items["garden_gnome"].getMap(),
						items["glitchmas_cracker"].getMap(),
						items["glitchmas_card"].getMap(),
						items["party_aquarius"].getMap(),
						items["party_double_rainbow"].getMap(),
						items["party_mazzala_gala"].getMap(),
						items["party_nylon_phool"].getMap(),
						items["party_pitchen_lilliputt"].getMap(),
						items["party_taster_aquarius"].getMap(),
						items["party_taster_double_rainbow"].getMap(),
						items["party_taster_mazzala_gala"].getMap(),
						items["party_taster_nylon_phool"].getMap(),
						items["party_taster_pitchen_lilliputt"].getMap(),
						items["party_taster_toxic_moon"].getMap(),
						items["party_taster_val_holla"].getMap(),
						items["party_taster_winter_wingding"].getMap(),
						items["party_toxic_moon"].getMap(),
						items["party_val_holla"].getMap(),
						items["party_winter_wingding"].getMap(),
						items["wrappable_gift_box"].getMap(),
						items["camera"].getMap(),
						items["million_currant_trophy"].getMap()
					];
					break;
			}
		}
	}

	String getRandomVendorType() {
		final List<String> types = [
			"alchemical",
			"animal",
			"gardening",
			"groceries",
			"hardware",
			"kitchen",
			"mining",
			"produce",
			"toy"
		];

		return types[rand.nextInt(types.length)];
	}

	buy({WebSocket userSocket, String email}) {
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = itemsForSale;
		userSocket.add(JSON.encode(map));
	}

	sell({WebSocket userSocket, String email}) {
		//prepare the buy window at the same time
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = itemsForSale;
		map['openWindow'] = 'vendorSell';
		userSocket.add(JSON.encode(map));
	}

	buyItem({WebSocket userSocket, String itemType, int num, String email}) async {
		if (!items.containsKey(itemType)) {
			return;
		}

		Item item = new Item.clone(itemType);
		Metabolics m = await getMetabolics(email: email);
		if (m.currants >= calcPrice(item) * num) {
			m.currants -= calcPrice(item) * num;
			setMetabolics(m);
			await InventoryV2.addItemToUser(email, item.getMap(), num, id);

			if (item.itemType == 'knife_and_board') {
				//offer the make me a sammich quest
				QuestEndpoint.questLogCache[email]?.offerQuest('Q1');
			}
		}

		StatManager.add(email, Stat.items_from_vendors, increment: num);
	}

	sellItem({WebSocket userSocket, String itemType, int num, String email}) async {
		if (!items.containsKey(itemType)) {
			return;
		}

		bool success = (await InventoryV2.takeAnyItemsFromUser(email, itemType, num) == num);

		if (success) {
			Item item = items[itemType];

			Metabolics m = await getMetabolics(email: email);
			m.currants += (item.price * num * .7) ~/ 1;
			setMetabolics(m);
		}
	}

	int calcPrice(Item item) {
		return (item.price * item.discount).toInt();
	}

	List<Map> pickItems(List<String> categories) {
		itemsToSell = items.values.where((Item m) {
			if (categories.contains(m.getMap()["category"])) {
				return true;
			} else {
				return false;
			}
		}).toList();

		List<Map> sellList = new List();

		itemsToSell.forEach((Item content) {
			sellList.add(content.getMap());
		});

		return sellList;
	}
}
