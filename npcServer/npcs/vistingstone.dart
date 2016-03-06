part of coUserver;

class VisitingStone extends NPC {
	String streetName;

	VisitingStone(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Visting Stone";
		actionTime = 0;
		speed = 0;
		actions = [
			{
				"action": "visit a street",
				"timeRequired": actionTime,
				"enabled": true,
				"actionWord": "visiting"
			}
		];
		states = {
			"_": new Spritesheet(
				"up",
				"http://childrenofur.com/assets/entityImages/visiting_stone__x1_1_png_1354840181.png",
				101, 155, 101, 155, 1, true
			)
		};
		setState("_");
	}

	@override
	update() {
		// Remain a visiting stone
	}

	Future<String> _randomUnvisitedTsid(String email) async {
		String _randomTsid() {
			List<Map> streetdata = mapdata_streets.values.toList();
			return streetdata[rand.nextInt(streetdata.length - 1)]["tsid"] ?? mapdata_streets["Cebarkul"]["tsid"];
		}

		List<String> streetsVisited = await getLocationHistory(email);

		String tsid;
		int loopCount = 0;
		while ((tsid == null || streetsVisited.contains(tsid)) && loopCount <= 5) {
			tsid = _randomTsid();
			loopCount++;
		}
		return tsid;
	}

	visitAStreet({String email, WebSocket userSocket}) {
		_randomUnvisitedTsid(email).then((String tsid) {
			userSocket.add(JSON.encode({
				"gotoStreet": "true",
				"tsid": tsid
			}));
		});
	}
}