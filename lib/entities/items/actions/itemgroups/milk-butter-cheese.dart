part of item;

/// Used to disambiguate & dispatch calls
abstract class MilkButterCheese {
	// Milk
	Future<bool> shakeBottle({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();
		int count = map['count'] ?? 1;
		if (await mc.getEnergy(username: username) <= 2*count) {
			toast("You don't have enough energy to shake that.", userSocket);
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(email, "butterfly_milk", count) == count) {
				toast("Shaking...", userSocket);
				new Timer(new Duration(seconds: 1), () async {
					bool success1 = (await InventoryV2.addItemToUser(email, items["butterfly_butter"].getMap(), count) > 0);
					bool success2 = await mc.trySetMetabolics(username, energy: -2);
					if (success1 && success2) {
						toast("You shake the butterfly milk vigorously. Butterfly butter!", userSocket);
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

	Future<bool> sniffMilk({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();
		int mood = await mc.getMood(email: email, username: username);
		if (mood <= 40) {
			toast("Butterfly milk smells like perfume from France. You experience a momentary surge of elation.", userSocket);
			return await mc.trySetMetabolics(username, mood: 12);
		} else {
			toast("Sniffing Butterfly Milk only works when you're feeling down.", userSocket);
			return false;
		}
	}

	// Butter
	Future<bool> compress({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();
		int count = map['count'] ?? 1;
		if (await mc.getEnergy(email: email) <= 3*count) {
			toast("You don't have enough energy to compress that.", userSocket);
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(email, "butterfly_butter", count) == count) {
				toast("Compressing...", userSocket);
				new Timer(new Duration(seconds: 2), () async {
					bool success1 = (await InventoryV2.addItemToUser(email, items["cheese"].getMap(), count) > 0);
					bool success2 = await mc.trySetMetabolics(username, energy: -3);
					if (success1 && success2) {
						toast("You squeeze the butterfly butter with all your might and cheese appears!", userSocket);
						Achievement.find("cheesemongerer").awardTo(email);
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

	// Cheese
	Future<bool> age({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();
		int count = map['count'] ?? 1;
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		int energyReq, moodReq;
		String doneMsg;
		final String energyFailMsg = "You are way too tired to age that much cheese. Maybe you should eat something first.";
		final String moodFailMsg = "You are way too depressed to feel like aging that much cheese. Maybe you should drink a tasty drink instead.";
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

		energyReq *= count;
		moodReq *= count;

		bool fail = false;

		if (await mc.getEnergy(email: email) <= energyReq) {
			toast(energyFailMsg, userSocket);
			fail = true;
		}

		if (await mc.getMood(email: email) <= moodReq) {
			toast(moodFailMsg, userSocket);
			fail = true;
		}

		if (fail) {
			return false;
		} else {
			if (await InventoryV2.takeAnyItemsFromUser(email, itemIn, count) == count) {
				toast("Aging...", userSocket);
				new Timer(new Duration(seconds: time), () async {
					toast(doneMsg, userSocket);
					bool success1 = (await InventoryV2.addItemToUser(email, items[itemOut].getMap(), count) > 0);
					bool success2 = await mc.trySetMetabolics(email, energy: -energyReq, mood: -moodReq);
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

		return false;	}

	// Cheese
	Future<bool> prod({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();

		if (await mc.getMood(email: email) <= 50) {
			toast("You need more mood to do that.", userSocket);
			return false;
		}

		toast("Not a good idea. It's going to take a while for that finger-stink to wear off.", userSocket);

		return (await InventoryV2.addItemToUser(email, items["small_worthless"].getMap(), 1) > 0);
	}

	Future<bool> sniffCheese({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		MetabolicsChange mc = new MetabolicsChange();

		if (await mc.getEnergy(email: email) <= 50) {
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
			if (rand.nextBool()) {
				await InventoryV2.takeAnyItemsFromUser(email, "very_very_stinky_cheese", 1);
				toast("The cheese was destroyed by your intense sniffing.", userSocket);
			}

			return await mc.trySetMetabolics(email, energy: -10, mood: 10);
		});

		return false;
	}
}
