part of item;

abstract class PiggyPlop {
	Future<bool> sniffPlop({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		toast('Wow, no. Nope, bad idea', userSocket);
		return true;
	}

	// Piggy Plop
	Future<bool> tastePlop({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);

		if(itemInSlot.itemType == 'butterfly_lotion') {
			toast("That didn't taste as good as it smells. -5 mood", userSocket);
			MetabolicsChange mc = new MetabolicsChange();
			return await mc.trySetMetabolics(username, mood: -5);
		} else if(itemInSlot.itemType == 'piggy_plop') {
			toast("I don't think you're doing this right", userSocket);
			return true;
		} else {
			return false;
		}
	}

	Future<bool> examinePlop({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		//1 in 5 chance to get 2
		int count = 1 + (rand.nextInt(5) == 3 ? 1 : 0);
		String quantifier = count == 1 ? 'a pack' : '$count packs';

		Item item = await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], map['count']);
		if(item == null) {
			return false;
		}

		messageBus.publish(new RequirementProgress('examine_piggy_plop', email));

		Map seedMap = items['${item.metadata['seedType']}_seed'].getMap();
		toast('You found $quantifier of ${seedMap['name']}s in that plop!', userSocket);
		return (await InventoryV2.addItemToUser(email, seedMap, count)) == count;
	}
}