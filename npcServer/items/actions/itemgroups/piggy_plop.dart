part of coUserver;

abstract class PiggyPlop extends Object with MetabolicsChange {
	static Future<bool> sniff(WebSocket userSocket) async {
		toast('Wow, no. Nope, bad idea', userSocket);
		return true;
	}

	static Future<bool> taste(WebSocket userSocket) async {
		toast("I don't think you're doing this right", userSocket);
		return true;
	}

	static Future<bool> examine(WebSocket userSocket, String email, Map map) async {
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