part of coUserver;

class Shrine extends NPC {
	String description;
	String giantName;

	Shrine(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;

		giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
		actions
			..add({"action":"donate",
				      "timeRequired":actionTime,
				      "enabled":false,
				      "actionWord":"Commune with $giantName"});
	}

	@override
	void update() {

	}

	donate({WebSocket userSocket, Map map, String email}) async {
		Metabolics m = await getMetabolics(email:email);

		Map map = {};
		map['giantName'] = giantName;
		map['favor'] = m.favor[giantName];
		map['maxFavor'] = 1000;
		userSocket.add(JSON.encode(map));
	}
}