part of entity;

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
		// Remain a visiting stone (the status is set in stone)
	}

	visitAStreet({String email, WebSocket userSocket}) {
		randomUnvisitedTsid(email, inclHidden: false).then((String tsid) {
			userSocket.add(JSON.encode({
				"gotoStreet": "true",
				"tsid": tsid
			}));
		});
	}
}
