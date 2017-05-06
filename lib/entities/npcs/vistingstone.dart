part of entity;

class VisitingStone extends NPC {
	VisitingStone(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Visiting Stone";
		actionTime = 0;
		speed = 0;
		actions = [
			{
				"actionName": "visit a street",
				"timeRequired": actionTime,
				"enabled": true,
				"actionWord": "visiting"
			}
		];
		states = {
			"_": new Spritesheet(
				"up",
				"https://childrenofur.com/assets/entityImages/visiting_stone__x1_1_png_1354840181.png",
				101, 155, 101, 155, 1, true
			)
		};
		setState("_");

		// Automatically face the correct direction
		if (x <= 500) {
			// Probably on the left end of the street, face right
			facingRight = true;
		} else {
			// Probably on the right end of the street, face left
			facingRight = false;
		}
	}

	@override
	update({bool simulateTick: false}) {
		// Remain a visiting stone (the status is set in stone)
	}

	Future visitAStreet({String email, WebSocket userSocket}) async {
		String tsid = await randomUnvisitedTsid(email, inclHidden: false);

		if (tsid == 'ALL_VISITED') {
			toast("You've visited every street in the game!", userSocket);
		} else if (tsid != null) {
			userSocket.add(JSON.encode({
				"gotoStreet": "true",
				"tsid": tsid
			}));
		} else {
			toast('Something went wrong :(', userSocket);
		}
	}
}
