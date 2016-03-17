part of entity;

class HellGrapes extends Plant {
	static final int ENERGY_AWARD = 3;
	static final int ENERGY_REQ = 9;

	HellGrapes(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actionTime = 3000;
		type = "Hellish Grapes";

		actions.add({
			"action": "squish",
			"actionWord": "squishing",
			"description": "You have to work to get out.",
			"timeRequired": 0,
			"enabled": true,
			"requires": []
		});

		states = {
			"grapes": new Spritesheet(
				"1-2-3-4",
				"http://childrenofur.com/assets/entityImages/bunch_of_grapes__x1_1_x1_2_x1_3_x1_4_png_1354829730.png",
				228,
				30,
				57,
				30,
				1,
				true)
		};
		currentState = states["grapes"];
		state = 0;
		maxState = 0;
	}

	@override
	void update() {
		if (state == 0) {
			setActionEnabled("squish", true);
		}

		if (respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("squish", true);
			respawn = null;
		}

		if (state < maxState) {
			state = maxState;
		}
	}

	Future<bool> squish({WebSocket userSocket, String email}) async {
		int energy = (await getMetabolics(email: email)).energy;
		if (state > 1) {
			return false;
		}
		bool success = await trySetMetabolics(email, energy: ENERGY_AWARD);
		if (!success) {
			;
			return false;
		} else {
			int remain = (ENERGY_REQ - (energy + ENERGY_AWARD)) ~/ ENERGY_AWARD;
			toast(
				remain == 0 ? "Ur done!" :
				"${remain.toString()} bunch${remain == 1 ? "" : "es"} of grapes to go!",
				userSocket
			);
		}

		// Update global stat
		StatBuffer.incrementStat("grapesSquished", 1);
		// Hide
		setActionEnabled("squish", false);
		state = 5;
		// Show after 2 minutes
		respawn = new DateTime.now().add(new Duration(minutes: 2));
		return success;
	}
}
