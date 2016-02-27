part of coUserver;

class Piggy extends NPC {
	Piggy(String id, int x, int y) : super(id, x, y) {
		actions
			..add({"action":"nibble",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":"nibbling",
				      "requires":[
					      {
						      'num':3,
						      'of':['energy']
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
				      ]})
			..add({'action':'feed',
					'timeRequired':0,
					'enabled':true,
					'actionWord':'feeding',
					'requires': [
						{
							'num':1,
							'of':['broccoli','cabbage','carrot','corn','cucumber','onion',
							'parsnip','potato','pumpkin','rice','spinach','tomato','zucchini'],
							'error': "You don't have anything that looks good right now."
						}
					]});
		type = "Piggy";
		speed = 75; //pixels per second

		states =
		{
			"chew" : new Spritesheet("chew", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_chew_png_1354829433.png", 968, 310, 88, 62, 53, true),
			"look_screen" : new Spritesheet("look_screen", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_look_screen_png_1354829434.png", 880, 310, 88, 62, 48, false),
			"nibble" : new Spritesheet("nibble", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_nibble_png_1354829441.png", 880, 372, 88, 62, 60, false),
			"rooked1" : new Spritesheet("rooked1", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_rooked1_png_1354829442.png", 880, 62, 88, 62, 10, true),
			"rooked2" : new Spritesheet("rooked2", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_rooked2_png_1354829443.png", 704, 186, 88, 62, 24, false),
			"too_much_nibble" : new Spritesheet("too_much_nibble", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_too_much_nibble_png_1354829441.png", 968, 372, 88, 62, 65, false),
			"walk" : new Spritesheet("walk", "http://childrenofur.com/assets/entityImages/npc_piggy__x1_walk_png_1354829432.png", 704, 186, 88, 62, 24, true)
		};
		currentState = states['walk'];

		responses =
		{
			"nibble": [
				"Ya bacon me crazy!"
			],
			"pet": [
				"Do I boar you?"
			]
		};
	}

	Future<bool> nibble({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email, energy:-3, mood:2, imgMin:7, imgRange:4);
		if(!success) {
			return false;
		}

		StatBuffer.incrementStat("piggiesNibbled", 1);
		//give the player the 'fruits' of their labor
		await InventoryV2.addItemToUser(email, items['meat'].getMap(), 1, id);

		setState('nibble');
		say(responses['nibble'].elementAt(rand.nextInt(responses['nibble'].length)));

		return true;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email, energy:-2, mood:3, imgMin:5, imgRange:3);
		if(!success) {
			return false;
		}

		StatBuffer.incrementStat("piggiesPetted", 1);
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		return true;
	}

	Future<bool> feed({WebSocket userSocket, String email}) async {
		Map map = {};
		map['id'] = id;
		map['openWindow'] = 'itemChooser';
		map['windowTitle'] = 'Feed $type';
		userSocket.add(JSON.encode(map));
		return true;
	}

	Future<bool> feedItem({WebSocket userSocket, String itemType, int count, String email}) async {
		setState('chew', repeat:2);
		return true;
	}

	/**
	 * Will simulate piggy movement and send updates to clients if needed
	 */
	update() {
		//we need to update x to hopefully stay in sync with clients
		if(currentState.stateName == "walk") {
			if(facingRight) {
				//75 pixels/sec is the speed set on the client atm
				x += speed;
			} else {
				x -= speed;
			}

			if(x < 0) {
				x = 0;
			}
			//TODO temporary
			if(x > 4000) {
				x = 4000;
			}

			//hard to check right bounds without actually loading the street
			//which we aren't doing right now.  we're just making everything up in the constructor
			//but at some point, we should get real street info
			//if(x > street.width-width)
			//x = street.width-width;
		}

		//if respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 4 chance to change direction
			if(rand.nextInt(4) == 1) {
				facingRight = !facingRight;
			}

			int num = rand.nextInt(10);
			if(num == 6 || num == 7) {
				setState('look_screen');
			} else {
				setState('walk');
			}
		}
	}
}