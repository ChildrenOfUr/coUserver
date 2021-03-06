part of entity;

class DustTrap extends NPC implements EventHandler<PlayerPosition> {
	DateTime now;
	String tsid;

	@override
	Map<String, dynamic> headers;

	@override
	void handleEvent(PlayerPosition position) {
		if (currentState != states['up']) {
			return;
		}

		if(_approx(x,position.x) && _approx(y,position.y+140)) {
			stepOn(StreetUpdateHandler.userSockets[position.email], position.email);
		}
	}

	bool _approx(num compare, num to) {
		return (compare - to).abs() < 30;
	}

	DustTrap(String id, String streetName, this.tsid, num x, num y, num z, num rotation, bool h_flip) : super(id, x, y, z, rotation, h_flip, streetName) {
		messageBus.subscribe(PlayerPosition, this, whereFunc: (PlayerPosition position) {
			return position.streetName == streetName;
		});

		actionTime = 0;
		actions = [];
		type = "Dust Trap";
		speed = 0;

		states = {
			"smackDown": new Spritesheet("smackDown", "https://childrenofur.com/assets/entityImages/dust_trap__x1_smackDown_png_1354833768.png", 990, 1275, 110, 255, 45, false),
			"liftUp": new Spritesheet("liftUp", "https://childrenofur.com/assets/entityImages/dust_trap__x1_up_png_1354833769.png", 880, 510, 110, 255, 16, false),
			"down": new Spritesheet("down", "https://childrenofur.com/assets/entityImages/dust_trap__x1_down_png_1354833768.png", 110, 255, 110, 255, 1, true),
			"up": new Spritesheet("up", "https://childrenofur.com/assets/entityImages/dust_trap__x1_idle_png_1354833764.png", 110, 255, 110, 255, 1, true)
		};
		setState('up');
	}

	@override
	void update({bool simulateTick: false}) {
		// Update clock
		now = new DateTime.now();

		// Check if flipping down has finished
		if (currentState == states["smackDown"] && respawn.compareTo(now) <= 0) {
			// Switch to static down image
			setState('down');
			// Flip back up in 1 minute
			respawn = now.add(new Duration(minutes: 1));
		}

		// Check if flipping up has finished
		if (currentState == states["liftUp"] && respawn.compareTo(now) <= 0) {
			// Switch to static up image
			setState('up');
		}

		// Check if down and need to reset
		if (currentState == states["down"] && respawn.compareTo(now) <= 0) {
			// Switch to resetting animation
			setState('liftUp');
		}
	}

	Future stepOn(WebSocket userSocket, String email) async {
		setState('smackDown');
		switch (new Random().nextInt(3)) {
			case 0:
				toast("Oh snap!", userSocket);
				break;
			case 1:
			case 2:
				await InventoryV2.addItemToUser(email, items["paper"].getMap(), 1, id);
				toast("+1 piece of paper", userSocket);
				break;
			case 3:
				await InventoryV2.addItemToUser(email, items["bun"].getMap(), 1, id);
				toast("+1 bun", userSocket);
				break;
		}
		return;
	}
}