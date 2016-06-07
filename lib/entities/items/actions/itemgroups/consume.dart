part of item;

// //// //
// Food //
// //// //

// takes away item and gives the stats specified in items/actions/consume.json
class Consumable extends Object with MetabolicsChange {
	Future<bool> eat({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
		if(consumed != null) {
			messageBus.publish(new RequirementProgress('eat_${consumed.itemType}', email, count:map['count']));
		}
		return consumed != null;
	}
	Future<bool> drink({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
		if(consumed != null) {
			messageBus.publish(new RequirementProgress('drink_${consumed.itemType}', email, count:map['count']));
		}
		return consumed != null;
	}

	Future<bool> activate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		Item consumed = await consume(streetName:streetName, map:map, userSocket: userSocket, email: email, username:username);
		if (consumed != null && consumed.itemType == "spinach") {
			BuffManager.addToUser("spinach", email, userSocket);
		}
		return consumed != null;
	}

	Future<bool> taste({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		bool result = await trySetMetabolics(email, mood: -5);
		if (result) {
			toast(
				'Maybe you should use the lotion on a butterfly and not your tounge?',
				userSocket);
		}
		return result;
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

		//cap the energy and mood as appropriate
		Metabolics m = await getMetabolics(email: email);
		energyAward = min(energyAward, m.max_energy - m.energy);
		moodAward = min(moodAward, m.max_mood - m.mood);

		String message = "Consuming that ${consumed.name} gave you ";

		if (energyAward > 0) {
			message +=  "$energyAward energy";
		}

		if (moodAward > 0) {
			if (energyAward > 0 && imgAward == 0) {
				message += " and ";
			} else if (energyAward > 0) {
				message += ", ";
			}

			message += "$moodAward mood";

			if (imgAward > 0) {
				message += ", ";
			} else {
				message += " ";
			}
		}

		if (imgAward > 0) {
			if (energyAward > 0 || moodAward > 0) {
				message += " and ";
			}
			message += " $imgAward iMG";
		}

		message = message.trim() + ".";

		toast(message, userSocket);

		if (consumed.itemType == "pumpkin_pie") {
			BuffManager.addToUser("full_of_pie", email, userSocket);
		}

		await trySetMetabolics(email, energy:energyAward, mood:moodAward, imgMin:imgAward);
		return consumed;
	}
}
