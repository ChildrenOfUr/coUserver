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

		print('m: ${m.FriendlyFavor}');

		String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
		InstanceMirror instanceMirror = reflect(m);
		int giantFavor = instanceMirror.getField(new Symbol(giantName+'Favor')).reflectee;

		print('giantFavor: $giantFavor');

		Map map = {};
		map['giantName'] = giantName;
		map['favor'] = giantFavor;
		map['maxFavor'] = 1000;
		map['id'] = id;
		userSocket.add(JSON.encode(map));
	}

	donate({WebSocket userSocket, String itemName, int num, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, itemName, num);

		if(success) {
			Item item = items[itemName];

			String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
			Metabolics m = await getMetabolics(email:email);
			InstanceMirror instanceMirror = reflect(m);
			int favAmt = (item.price * num * .35) ~/ 1;
			instanceMirror.setField(new Symbol(giantName+'Favor'),favAmt);
			await setMetabolics(m);
		}
	}
}