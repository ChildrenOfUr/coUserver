part of coUserver;

class Item_Consumable {
	static Map<String, Map> consumeValues = {};

	static Future<bool> consume(Map map, WebSocket userSocket, String email) async {
		int success = await InventoryV2.takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
		if (success == -1) {
			return false;
		}

		int energyAward = consumeValues[map['dropItem']['itemType']]['energy'];
		int moodAward = consumeValues[map['dropItem']['itemType']]['mood'];
		int imgAward = consumeValues[map['dropItem']['itemType']]['img'];

		toast("Consuming that ${map["dropItem"]["name"]} gave you $energyAward energy, $moodAward mood, and $imgAward iMG", userSocket);

		return await ItemUser.trySetMetabolics(email, energy:energyAward, mood:moodAward, img:imgAward);
	}
}