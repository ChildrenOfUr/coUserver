part of entity;

class HellGrapes extends RespawningItem {
	static final int ENERGY_AWARD = 3;
	static final int ENERGY_REQ = 9;

	HellGrapes(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Hellish Grapes';
		itemType = 'bunch_of_grapes';
		actionTime = 3000;

		actions.add(
			new Action.withName('squish')
				..actionWord = 'squishing'
				..description = 'You have to work to get out.'
		);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/bunch_of_grapes__x1_1_x1_2_x1_3_x1_4_png_1354829730.png',
				228, 30, 57, 30, 4, true)
		};

		setState('1-2-3-4');
		maxState = 3;
	}

	@override
	void show() {
		super.show();
		setActionEnabled('squish', true);
	}

	@override
	void hide([Duration respawnIn]) {
		super.hide(respawnIn);
		setActionEnabled('squish', false);
	}

	Future<bool> squish({WebSocket userSocket, String email}) async {
		if (hidden) {
			return false;
		}

		int energy = (await getMetabolics(email: email)).energy;
		if (!(await trySetMetabolics(email, energy: ENERGY_AWARD))) {
			return false;
		} else {
			int remain = (ENERGY_REQ - (energy + ENERGY_AWARD)) ~/ ENERGY_AWARD;
			toast(
				remain == 0 ? 'Ur done!' :
				'${remain.toString()} bunch${remain == 1 ? '' : 'es'} of grapes to go!',
				userSocket
			);
		}

		// Update global stat
		StatManager.add(email, Stat.grapes_squished);

		// Prevent further actions
		hide(new Duration(minutes: 2));

		return true;
	}
}
