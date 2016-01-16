part of coUserver;

class Item_Consumable {
	static Map<String, Map> consumeValues = {};

	static Future<bool> consume(Map map, WebSocket userSocket, String username, String email) async {
		Item consumed = await InventoryV2.takeItemFromUser(email, map['slot'],map['subSlot'], map['count']);
		if (consumed == null) {
			return false;
		}

		int energyAward = consumeValues[consumed.itemType]['energy'];
		int moodAward = consumeValues[consumed.itemType]['mood'];
		int imgAward = consumeValues[consumed.itemType]['img'];

		toast("Consuming that ${consumed.name} gave you $energyAward energy, $moodAward mood, and $imgAward iMG", userSocket);

		return await ItemUser.trySetMetabolics(username, energy:energyAward, mood:moodAward, img:imgAward);
	}
}