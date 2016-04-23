part of item;

abstract class Potions extends Object with MetabolicsChange {
	Future growYourself({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		await BuffManager.removeFromUser("shrink", email, userSocket);
		BuffManager.addToUser("grow", email, userSocket);
	}

	Future shrinkYourself({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		await BuffManager.removeFromUser("grow", email, userSocket);
		BuffManager.addToUser("shrink", email, userSocket);
	}
}