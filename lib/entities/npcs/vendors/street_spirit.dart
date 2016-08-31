part of entity;

class StreetSpirit extends Vendor {
	int openCount = 0;
	Clock clock = new Clock();
	int currentBob = 0, minBob = -15, maxBob = 15;
	bool bobbingUp = true;

	StreetSpirit(String id, String streetName, String tsid, num x, num y, num z) : super(id, streetName, tsid, x, y, z) {
		speed = 75;
	}

	@override
	void update() {
		super.update();

		Function yAction = () {
			// bob up and down a bit
			if (bobbingUp) {
				y--;
				currentBob--;
				if (currentBob < minBob) {
					bobbingUp = false;
				}
			} else {
				y++;
				currentBob++;
				if (currentBob > maxBob) {
					bobbingUp = true;
				}
			}
		};

		if(currentState.stateName == 'idle_move') {
			moveXY(yAction: yAction);
		}
		if(currentState.stateName == 'still' || currentState.stateName == 'idle_hold' ||
		   currentState.stateName == 'turn' || currentState.stateName == 'hover_idle' ||
		   currentState.stateName == 'hover_talk' || currentState.stateName == 'idle_cry' ||
		   currentState.stateName == 'talk') {
			moveXY(xAction: () {}, yAction: yAction);
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.sell(userSocket:userSocket, email:email);
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			setState('close');
		}
	}
}