part of coUserver;

abstract class Rock extends Plant {
	Rock(String id, int x, int y) : super(id,x,y) {
		maxState = 0;
		actionTime = 5000;

		actions.add({"action":"mine",
					 "actionWord":"mining",
					 "timeRequired":actionTime,
					 "enabled":true,
					 "requires":[
					               {
								     "num":1,
								     "of":["Pick","Fancy Pick"]
								   }
								]
					 });

		responses = {
			'gone' : [
				"Oof, where'd I go?",
				"brb",
				"kbye",
				"A la peanut butter sammiches",
				"Alakazam!",
				"*poof*",
				"I'm all mined out!",
				"Gone to the rock quarry in the sky",
				"Yes. You hit rock bottom",
				"All rocked out for now"
			]
		};
	}

	void update()
	{
		if(state >= currentState.numFrames) {
			say(responses['gone'].elementAt(rand.nextInt(responses['gone'].length)));
			setActionEnabled("mine", false);
		}

		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("mine",true);
			respawn = null;
		}

		if(state < maxState) {
			state = maxState;
		}
	}

	void mine({WebSocket userSocket, String email})
	{
		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number

		say(responses['mine_$type'].elementAt(rand.nextInt(responses['mine_$type'].length)));

		StatBuffer.incrementStat("rocksMined", 1);
		state++;
		if(state >= currentState.numFrames) {
			respawn = new DateTime.now().add(new Duration(minutes:2));
		}

		//chances to get gems:
		//amber = 1 in 5
		//sapphire = 1 in 7
		//ruby = 1 in 10
		//moonstone = 1 in 15
		//diamond = 1 in 20
		if(rand.nextInt(5) == 5) {
			addItemToUser(userSocket, email, items['Pleasing Amber'].getMap(), 1, id);
		}
		if(rand.nextInt(7) == 5) {
			addItemToUser(userSocket, email, items['Showy Sapphire'].getMap(), 1, id);
		}
		if(rand.nextInt(10) == 5) {
			addItemToUser(userSocket, email, items['Modestly Sized Ruby'].getMap(), 1, id);
		}
		if(rand.nextInt(15) == 5) {
			addItemToUser(userSocket, email, items['Luminous Moonstone'].getMap(), 1, id);
		}
		if(rand.nextInt(20) == 5) {
			addItemToUser(userSocket, email, items['Walloping Big Diamond'].getMap(), 1, id);
		}
	}
}