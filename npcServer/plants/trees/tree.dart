part of coUserver;

abstract class Tree extends Plant with Events {
	int maturity;

	Tree(String id, int x, int y) : super(id, x, y) {
		actions
			..add({"action":"harvest",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":"harvesting",
				      "requires":[
					      {
						      'num':5,
						      'of':['energy'],
						      "error": "You need at least 5 energy to harvest."
					      }
				      ]})
			..add({"action":"water",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":"watering",
				      "requires":[
					      {
						      "num":1,
						      "of":["watering_can", "irrigator_9000"],
						      "error": "Trees don't like to be peed on. Go find some clean water, please."
					      },
					      {
						      "num": 2,
						      "of": ['energy'],
						      "error": "You need at least 2 energy to water."
					      }
				      ]})
			..add({"action":"pet",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":"petting",
				      "requires":[
					      {
						      'num':2,
						      'of':['energy']
					      }
				      ]});
	}

	void update() {
		super.update();

		if(state > 0)
			setActionEnabled("harvest", true);
		else
			setActionEnabled("harvest", false);
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		//make sure the player has 5 energy to perform this action
		//if so, allow the action and subtract 5 from their energy
		bool success = await trySetMetabolics(email, energy:-5, mood:1, imgMin:10, imgRange:5);
		if(!success) {
			return false;
		}

		if(state == 0) {
			return false;
		}

		//say a witty thing
		say(responses['harvest'].elementAt(rand.nextInt(responses['harvest'].length)));

		StatBuffer.incrementStat("treesHarvested", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;

		if(state < 0) {
			state = 0;
		}

		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await trySetMetabolics(email, energy:-2, mood:2, imgMin:3, imgRange:2);
		if(!success) {
			return false;
		}

		if(state == maxState) {
			return false;
		}

		//say a witty thing
		say(responses['water'].elementAt(rand.nextInt(responses['water'].length)));

		StatBuffer.incrementStat("treesWatered", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;

		if(state > maxState) {
			state = maxState;
		}

		return true;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await trySetMetabolics(email, energy:-2, mood:2, imgMin:3, imgRange:2);
		if(!success) {
			return false;
		}

		//say a witty thing
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		emit('treePet',null);
		StatBuffer.incrementStat("treesPetted", 1);

		return true;
	}
}