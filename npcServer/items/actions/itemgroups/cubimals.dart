part of coUserver;

// /////// //
// Cubimal //
// /////// //

abstract class Cubimal extends Object with MetabolicsChange {

	Future<bool> race({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);

		// number 1 to 50
		int base = ItemUser.rand.nextInt(49) + 1;
		// number 0.0 (incl) to 1.0 (excl)
		double multiplier = ItemUser.rand.nextDouble();
		// multiply them for more variety
		num result = base * multiplier;
		// 80% chance to cut numbers at least 17 in half
		if (result >= 17 && ItemUser.rand.nextInt(4) <= 3) result /= 2;
		// cut to two decimal places (and a string)
		String twoPlaces = result.toStringAsFixed(2);
		// back to number format
		num distance = num.parse(twoPlaces);

		String plural;
		if (distance == 1) {
			plural = "";
		} else {
			plural = "s";
		}

		String message;

		if (itemInSlot.itemType == 'npc_cubimal_factorydefect_chick') {
			distance = -(distance / 2);
			message = "$username's defective chick cubimal travelled ${distance.toString()} plank$plural, and broke";
		} else {
			message = "$username's ${itemInSlot.name} travelled ${distance.toString()} plank$plural before stopping";
		}

		StreetUpdateHandler.streets[streetName].occupants.forEach((String username, WebSocket ws) => toast(message, ws));

		return true;
	}

	Future<bool> setFree({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		String cubiType = itemInSlot.itemType;
		bool success = (await InventoryV2.takeAnyItemsFromUser(email, cubiType, 1) == 1);
		if (!success) return false;
		int img = ((freeValues[itemInSlot.itemType.substring(8)] / 2) * (ItemUser.rand.nextDouble() + 0.1)).truncate();
		trySetMetabolics(email, mood: 10, imgMin: img);
		StatBuffer.incrementStat("cubisSetFree", 1);
		toast("Your cubimal was released back into the wild. You got $img iMG.", userSocket);
		return success;
	}

	static Map<String, double> freeValues = {
		"chick": 17.000,
		"piggy": 34.000,
		"butterfly": 50.000,
		"crab": 58.000,
		"batterfly": 66.000,
		"frog": 74.000,
		"firefly": 82.000,
		"bureaucrat": 84.000,
		"cactus": 86.000,
		"snoconevendor": 88.000,
		"squid": 90.000,
		"juju": 92.000,
		"smuggler": 93.250,
		"deimaginator": 94.500,
		"greeterbot": 95.750,
		"dustbunny": 97.000,
		"gwendolyn": 97.500,
		"unclefriendly": 98.000,
		"helga": 98.500,
		"magicrock": 99.000,
		"yeti": 99.500,
		"rube": 99.750,
		"rook": 100.00,
		"fox": 14.500,
		"sloth": 29.000,
		"emobear": 37.000,
		"foxranger": 45.000,
		"groddlestreetspirit": 54.000,
		"uraliastreetspirit": 61.000,
		"firebogstreetspirit": 69.000,
		"gnome": 77.000,
		"butler": 81.000,
		"craftybot": 85.000,
		"phantom": 89.000,
		"ilmenskiejones": 93.000,
		"trisor": 94.000,
		"toolvendor": 95.000,
		"mealvendor": 96.000,
		"gardeningtoolsvendor": 97.000,
		"maintenancebot": 98.000,
		"senorfunpickle": 99.000,
		"hellbartender": 99.500,
		"scionofpurple": 100.50
	};
}

// /////////// //
// Cubimal Box //
// /////////// //

abstract class CubimalBox {

	Future<bool> takeOutCubimal({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		int series;
		Map<String, String> cubis;
		if (itemInSlot.itemType == 'cubimal_series_1_box') {
			series = 1;
			cubis = series1;
		} else if (itemInSlot.itemType == 'cubimal_series_2_box') {
			series = 2;
			cubis = series2;
		} else {
			return false;
		}
		String cubimal = "cubimal_";
		String box = "cubimal_series_" + series.toString() + "_box";
		num seek = ItemUser.rand.nextInt(10000) / 100;
		for (String cubiChance in cubis.keys) {
			if (seek <= num.parse(cubiChance)) {
				cubimal += cubis[cubiChance];
				break;
			}
		}
		bool success = (await InventoryV2.takeAnyItemsFromUser(email, box, 1) == 1);
		await InventoryV2.addItemToUser(email, items[cubimal].getMap(), 1, box);
		StatBuffer.incrementStat("cubiBoxesOpened", 11);
		return success;
	}

	static Map<String, String> series1 = {
		"17.000": "chick",
		"34.000": "piggy",
		"50.000": "butterfly",
		"58.000": "crab",
		"66.000": "batterfly",
		"74.000": "frog",
		"82.000": "firefly",
		"84.000": "bureaucrat",
		"86.000": "cactus",
		"88.000": "snoconevendor",
		"90.000": "squid",
		"92.000": "juju",
		"93.250": "smuggler",
		"94.500": "deimaginator",
		"95.750": "greeterbot",
		"97.000": "dustbunny",
		"97.500": "gwendolyn",
		"98.000": "unclefriendly",
		"98.500": "helga",
		"99.000": "magicrock",
		"99.500": "yeti",
		"99.750": "rube",
		"100.00": "rook"
	};

	static Map<String, String> series2 = {
		"14.500": "fox",
		"29.000": "sloth",
		"37.000": "emobear",
		"45.000": "foxranger",
		"54.000": "groddlestreetspirit",
		"61.000": "uraliastreetspirit",
		"69.000": "firebogstreetspirit",
		"77.000": "gnome",
		"81.000": "butler",
		"85.000": "craftybot",
		"89.000": "phantom",
		"93.000": "ilmenskiejones",
		"94.000": "trisor",
		"95.000": "toolvendor",
		"96.000": "mealvendor",
		"97.000": "gardeningtoolsvendor",
		"98.000": "maintenancebot",
		"99.000": "senorfunpickle",
		"99.500": "hellbartender",
		"100.50": "scionofpurple"
	};
}