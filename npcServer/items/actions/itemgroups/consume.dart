part of coUserver;

// //// //
// Food //
// //// //

// takes away item and gives the stats specified in items/actions/consume.json
class Consumable extends Object with MetabolicsChange {
	static Map<String, Map> consumeValues = {};

	Future<bool> eat({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
	}
	Future<bool> drink({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
	}

	Future<bool> consume({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await InventoryV2.takeItemFromUser(email, map['slot'],map['subSlot'], map['count']);
		if (consumed == null) {
			return false;
		}

		int energyAward = consumeValues[consumed.itemType]['energy'];
		int moodAward = consumeValues[consumed.itemType]['mood'];
		int imgAward = consumeValues[consumed.itemType]['img'];

		toast("Consuming that ${consumed.name} gave you $energyAward energy, $moodAward mood, and $imgAward iMG", userSocket);

		return await trySetMetabolics(email, energy:energyAward, mood:moodAward, imgMin:imgAward);
	}
}