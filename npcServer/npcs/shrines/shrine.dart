part of coUserver;

class Shrine extends NPC {
	String description;

	Shrine(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;

		actions
			..add({"action":"Commune With",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""});
	}

	@override
	void update() {}

	communeWith({WebSocket userSocket, String email}) async {
		Metabolics m = await getMetabolics(email:email);

		String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
		Map map = {};
		map['giantName'] = giantName.substring(0, 1).toUpperCase() + giantName.substring(1, giantName.length);
		map['favor'] = m.favor[giantName];
		map['maxFavor'] = 1000;
		userSocket.add(JSON.encode(map));
	}

	donate({WebSocket userSocket, String itemName, int num, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, itemName, num);

		if(success) {
			Item item = items[itemName];

			String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
			Metabolics m = await getMetabolics(email:email);
			m.favor[giantName] += (item.price * num * .35) ~/ 1;
			setMetabolics(m);
		}
	}
}