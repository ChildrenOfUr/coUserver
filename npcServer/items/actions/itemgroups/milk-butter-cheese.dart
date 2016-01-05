part of coUserver;

abstract class Item_Milk {
	static Future<bool> sniff(WebSocket userSocket, String username) async {
		int mood = await ItemUser.getMood(username);
		if (mood <= 40) {
			toast("Butterfly milk smells like perfume from France. You experience a momentary surge of elation.", userSocket);
			return await ItemUser.trySetMetabolics(username, mood: 12);
		} else {
			toast("Sniffing Butterfly Milk only works when you're feeling down.", userSocket);
			return false;
		}
	}

	static Future<bool> shakeBottle(WebSocket userSocket, String username) async {
		if (await ItemUser.getEnergy(username) <= 2) {
			toast("You don't have enough energy to shake that.", userSocket);
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(userSocket, username, "butterfly_milk", 1) == 1) {
				toast("Shaking...", userSocket);
				new Timer(new Duration(seconds: 1), () async {
					toast("You shake the butterfly milk vigorously. Butterfly butter!", userSocket);
					bool success1 = (await InventoryV2.addItemToUser(userSocket, username, items["butterfly_butter"].getMap(), 1, "_self") > 0);
					bool success2 = await ItemUser.trySetMetabolics(username, energy: -2);
					if (success1 && success2) {
						return true;
					} else {
						return false;
					}
				});
			} else {
				return false;
			}
		}

		return false;
	}
}

abstract class Item_Butter {
	static Future<bool> compress(WebSocket userSocket, String email) async {
		if (await ItemUser.getEnergy(email) <= 3) {
			toast("You don't have enough energy to compress that.", userSocket);
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(userSocket, email, "butterfly_butter", 1) == 1) {
				toast("Compressing...", userSocket);
				new Timer(new Duration(seconds: 2), () async {
					toast("You squeeze the butterfly butter with all your might and cheese appears!", userSocket);
					bool success1 = (await InventoryV2.addItemToUser(userSocket, email, items["cheese"].getMap(), 1, "_self") > 0);
					bool success2 = await ItemUser.trySetMetabolics(email, energy: -3);
					if (success1 && success2) {
						return true;
					} else {
						return false;
					}
				});
			} else {
				return false;
			}
		}

		return false;
	}
}

abstract class Item_Cheese {
	static Future<bool> age(Map map, WebSocket userSocket, String email) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		int energyReq, moodReq;
		String doneMsg;
		String energyFailMsg = "You are way too tired to age that much cheese. Maybe you should eat something first.";
		String moodFailMsg = "You are way too depressed to feel like aging that much cheese. Maybe you should drink a tasty drink instead.";
		String itemIn, itemOut;
		int time;

		switch (itemInSlot.itemType) {
			case "cheese":
				energyReq = 4;
				moodReq = 2;
				doneMsg = "You put the cheese in your pocket for a while and it ages nicely. It left a bit of a smell in your pocket though.";
				itemIn = "cheese";
				itemOut = "stinky_cheese";
				time = 3;
				break;

			case "stinky_cheese":
				energyReq = 5;
				moodReq = 3;
				doneMsg = "If you concentrate really hard on it, the cheese does indeed age.";
				itemIn = "stinky_cheese";
				itemOut = "very_stinky_cheese";
				time = 4;
				break;

			case "very_stinky_cheese":
				energyReq = 6;
				moodReq = 4;
				doneMsg = "Wow, is that ever draining. But the cheese *is* visibly aged.";
				itemIn = "very_stinky_cheese";
				itemOut = "very_very_stinky_cheese";
				time = 5;
				break;
		}

		bool fail = false;

		if (await ItemUser.getEnergy(email) <= 4) {
			toast(energyFailMsg, userSocket);
			fail = true;
		}

		if (await ItemUser.getMood(email) <= 2) {
			toast(moodFailMsg, userSocket);
			fail = true;
		}

		if (fail) {
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(userSocket, email, itemIn, 1) == 1) {
				toast("Aging...", userSocket);
				new Timer(new Duration(seconds: time), () async {
					toast(doneMsg, userSocket);
					bool success1 = (await InventoryV2.addItemToUser(userSocket, email, items[itemOut].getMap(), 1, "_self") > 0);
					bool success2 = await ItemUser.trySetMetabolics(email, energy: -energyReq, mood: -moodReq);
					if (success1 && success2) {
						return true;
					} else {
						return false;
					}
				});
			} else {
				return false;
			}
		}

		return false;
	}

	static Future<bool> prod(WebSocket userSocket, String email) async {
		if (await ItemUser.getMood(email) <= 50) {
			toast("You need more mood to do that.", userSocket);
			return false;
		}

		toast("Not a good idea. It's going to take a while for that finger-stink to wear off.", userSocket);

		return (await InventoryV2.addItemToUser(userSocket, email, items["small_worthless"].getMap(), 1, "_self") > 0);
	}

	static Future<bool> sniff(WebSocket userSocket, String email) async {
		if (await ItemUser.getEnergy(email) <= 50) {
			toast("You are too weak to do that.", userSocket);
			return false;
		}

		toast("*deep sniff*", userSocket);

		new Timer(new Duration(seconds: 1), () {
			toast("*deeper sniff*", userSocket);
		});

		new Timer(new Duration(seconds: 2), () async {
			toast(
				"At first sniff, this is one of the worst olfactory experiences of your life. "
				"On your second sniff, you experience an epiphany, which you forget almost immediately."
				, userSocket);

			// 50% chance to destroy it
			if (ItemUser.rand.nextBool()) {
				await InventoryV2.takeAnyItemsFromUser(userSocket, email, "very_very_stinky_cheese", 1);
				toast("The cheese was destroyed by your intense sniffing.", userSocket);
			}

			return await ItemUser.trySetMetabolics(email, energy: -10, mood: 10);
		});

		return false;
	}
}