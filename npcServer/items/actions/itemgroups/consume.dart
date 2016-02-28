part of coUserver;

// //// //
// Food //
// //// //

// takes away item and gives the stats specified in items/actions/consume.json
class Consumable extends Object with MetabolicsChange {
	Future<bool> eat({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
		if(consumed != null) {
			for(int i=0; i<map['count']; i++) {
				messageBus.publish(new RequirementProgress('eat_${consumed.itemType}', email));
			}
		}
		return consumed != null;
	}
	Future<bool> drink({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
		if(consumed != null) {
			for(int i=0; i<map['count']; i++) {
				messageBus.publish(new RequirementProgress('drink_${consumed.itemType}', email));
			}
		}
		return consumed != null;
	}

	Future<Item> consume({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await InventoryV2.takeItemFromUser(email, map['slot'],map['subSlot'], map['count']);
		if (consumed == null) {
			return null;
		}

		int count = map['count'];
		int energyAward = consumed.consumeValues['energy']*count;
		int moodAward = consumed.consumeValues['mood']*count;
		int imgAward = consumed.consumeValues['img']*count;

		toast("Consuming that ${consumed.name} gave you $energyAward energy, $moodAward mood, and $imgAward iMG", userSocket);

		await trySetMetabolics(email, energy:energyAward, mood:moodAward, imgMin:imgAward);
		return consumed;
	}
}