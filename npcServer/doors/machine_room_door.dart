part of coUserver;

class MachineRoomDoor extends Door {
	MachineRoomDoor(String id, String streetName, int x, int y) : super (id, streetName, x, y) {
		if(streetName.toLowerCase().contains("machine room")) {
			switch(streetName) {
				case "Besara Community Machine Room":
					toLocation = "LA9G6MA4P6923PH";
					// Canary Send
					break;

				case "Forest Community Machine Room":
					toLocation = "LLI23FELDHD1O3C";
					// Middle Valley Clearing
					break;

				case "Meadow Community Machine Room":
					toLocation = "LCR10K3BPJK1U6F";
					// Otterlane
					break;
			}
			outside = false;
			actions.add({
				"action": "exit",
				"timeRequired": 0,
				"enabled": true,
				"actionWord": "walking out"
			});
			currentState = new Spritesheet("door_mr_int", "http://childrenofur.com/assets/game/doors/machine_room_door_int.png", 57, 244, 57, 244, 1, true);
		} else {
			switch(streetName) {
				case "Canary Send":
					toLocation = "LA9MU59GB792T80";
					// Besara Community Machine Room
					break;

				case "Middle Valley Clearing":
					toLocation = "LIF16EM56A12FSB";
					// Forest Community Machine Room
					break;

				case "Otterlane":
					toLocation = "LCR101Q98A12EHH";
					// Meadow Community Machine Room
					break;
			}
			outside = true;
			actions.add({
				"action": "exit",
				"timeRequired": 0,
				"enabled": true,
				"actionWord": "walking out"
			});
			currentState = new Spritesheet("door_mr_ext", "http://childrenofur.com/svgs/door_asset_community_machine_room_ext.svg", 57, 244, 57, 244, 1, true);
		}
		type = "Machine Room";
	}
}