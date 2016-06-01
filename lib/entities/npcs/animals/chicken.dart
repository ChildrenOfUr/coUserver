part of entity;

class Chicken extends NPC {
	static final Map<String, String> EGG_ANIMALS = {
		"butterfly_egg": "caterpillar",
		"chicken_egg": "chick",
		"piggy_egg": "piglet"
	};

	bool incubating = false;

	Chicken(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actions.add({"action":"squeeze",
			            "enabled":true,
			            "timeRequired":actionTime,
			            "actionWord":"squeezing",
			            "requires":[
				            {
					            'num':5,
					            'of':['energy']
				            }
			            ]});
		actions.add({
			"action": "incubate",
			"enabled": mapdata_streets[streetName] != null &&
				mapdata_streets[streetName]["tsid"] != null,
			"actionWord": "incubating",
			"timeRequired": 0,
			"requires": [
				{
					"num": 1,
					"of": EGG_ANIMALS.keys.toList()
				}
			]
		});

		type = "Chicken";
		speed = 75; //pixels per second

		states =
		{
			"fall" : new Spritesheet("fall", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_fall_png_1354830392.png", 740, 550, 148, 110, 25, true),
			"flying_back" : new Spritesheet("flying_back", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_flying_back_png_1354830391.png", 888, 330, 148, 110, 17, true),
			"flying_no_feathers" : new Spritesheet("flying_no_feathers", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_flying_no_feathers_png_1354830388.png", 888, 770, 148, 110, 42, true),
			"flying" : new Spritesheet("flying", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_flying_png_1354830387.png", 888, 770, 148, 110, 42, true),
			"idle1" : new Spritesheet("idle1", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_idle1_png_1354830404.png", 888, 1320, 148, 110, 67, false),
			"idle2" : new Spritesheet("idle2", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_idle2_png_1354830405.png", 888, 880, 148, 110, 47, false),
			"idle3" : new Spritesheet("idle3", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_idle3_png_1354830407.png", 888, 1650, 148, 110, 86, false),
			"incubate" : new Spritesheet("incubate", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_incubate_png_1354830403.png", 888, 3520, 148, 110, 190, false),
			"land_on_ladder" : new Spritesheet("land_on_ladder", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_land_on_ladder_png_1354830390.png", 888, 550, 148, 110, 26, false),
			"land" : new Spritesheet("land", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_land_png_1354830389.png", 740, 550, 148, 110, 25, false),
			"pause" : new Spritesheet("pause", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_pause_png_1354830395.png", 888, 2420, 148, 110, 131, false),
			"pecking_once" : new Spritesheet("pecking_once", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_pecking_once_png_1354830398.png", 888, 660, 148, 110, 32, false),
			"pecking_twice" : new Spritesheet("pecking_twice", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_pecking_twice_png_1354830400.png", 888, 770, 148, 110, 27, false),
			"rooked2" : new Spritesheet("rooked2", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_rooked2_png_1354830409.png", 888, 550, 148, 110, 27, false),
			"sit" : new Spritesheet("sit", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_sit_png_1354830401.png", 740, 440, 148, 110, 20, false),
			"verb" : new Spritesheet("verb", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_verb_png_1354830397.png", 888, 1100, 148, 110, 55, false),
			"walk" : new Spritesheet("walk", "http://childrenofur.com/assets/entityImages/npc_chicken__x1_walk_png_1354830385.png", 888, 440, 148, 110, 24, true)
		};

		setState('walk');

		responses = {
			"squeeze": [
				"Yeeeeeeeeeeeeeks!",
				"Oh my beak and giblets, you scared me!",
				"You made me drop my GRAIN, squeezefiend!",
				"Squeeze. Grain. Grain. Squeeze. It's a chicken's life.",
				"BUK! Take the grain! Take it!",
				"Again with the squeezing?!?",
				"So take it - I didn't want that grain anyway.",
				"Squeezed again? Oy. Such imagination you show.",
				"What IS this, the world chicken wrestling featheration?",
				"One day, chickens squeeze YOU.",
				"Another squeeze? Really?!?",
				"HELP! Chickenmuggings!",
				"Fine. Take it. And enjoy, grain-finagler.",
				"Buk-buk-buk. That what you want to hear?",
				"Squeeze squeeze squeeze squeeze squeeze. Buk.",
				"Not so hard, you'll tangle my intestinal noodles.",
				"Yes, because chickens don't need personal space too? Pah.",
				"Consider my feathers ruffled. Buk.",
				"Chicken-ruffler! Alarm! Alarm!",
				"Always with the squeezing!",
				"Oh look. It's Chicken Wrestler. Again.",
				"Rummage all you like, I've only got grain.",
				"Grain! Grain if you'll stop!",
				"Buk! Off! Get off! Buk buk.",
				"Do YOU like to be squeezed by random strangers? Hmn?",
				"Oooh, CHASE ME!",
				"Chicken-botherer begone! Take the grain already!",
				"Consider me squeezed. Squoozed? Squzz?",
				"Psssst! I don't mind really.",
				"One day: revenge. Until that day: grain.",
				"Buy grain on auction, maybe? No? Just squeezing? OK!",
				"Oh go on then: one more squeeze. Hic!"
			],
			"squeezeExtra": [
				"Take it! Take it ALL!",
				"Well done you.",
				"All the grain. Happy?",
				"If give you this, will you hold off on the squeezing?",
				"Take it all! Take it and go!",
				"So now you want extra? Buk.",
				"Like you deserve this, squeezy scourge of chicken.",
				"Happy now?",
				"Congrainulations, you superscored.",
				"STOP SQUEEZING ME!",
				"THERE! Anything else? Arm? Leg? Gravy? Peh.",
				"Happy chickenannoying day.",
				"My little hot pockets are emptied of grain.",
				"Are we done here?",
				"Grain. Because that's ALL I'm good for. *sigh*.",
				"Your reward for all your chickensquooging! Buk.",
				"Oh! So hard a squeeze! Supergrain!",
				"Yes, yes. A squeeze, some grain, same old…",
				"You either really like grain, or get some kick out of this.",
				"Yes, yes: congrainulations, squeezefiend.",
				"You deserve this, squeezefiend. Your arms must be tired.",
				"You've emptied my chicken pockets! Happy now?",
				"Truth? I quite like squeezing. Don't stop."
			],
			"squeezeFail": [
				"Squaaaaaaahahaha! Too fast for you!",
				"Buk! No squeeze! I greased my feathers!"
			],
			"incubateStart": [
				"Now the chicken is superior, eh? Wait here ONE MINUTE and I'll give it back.",
				"No squeezing while I sit? Ok deal. But, you can't leave for a whole minute. Stay, if you want your animal.",
				"Well, comfortable it isn't... but ok. Deal is that you have to wait a full minute.",
				"I'm egg-static to be of service. That was sarcasm. But whatever ... if you stick around for a minute I'll get 'er done.",
				"At least you appreciate my warm underfeatheredside.  Love it! Also, stick around for sixty seconds or lose it!"
			],
			"incubateEnd": [
				"Ping!",
				"Done! What were you expecting, 3 1\/2 minutes?",
				"Buk! It bit my butt! You owe me a beer.",
				"Here. Another new life. A miracle. Thank me later.",
				"Ta DA!"
			]
		};
	}

	Future<bool> squeeze({WebSocket userSocket, String email}) async {
		bool success = await trySetMetabolics(email, energy:-2, mood:2, imgMin:3, imgRange:2);
		if(!success) {
			say(responses['squeezeFail'].elementAt(rand.nextInt(responses['squeezeFail'].length)));
			return false;
		}

		if(rand.nextInt(5) == 1) {
			// 1/5 chance of bonus
			await InventoryV2.addItemToUser(email, items['grain'].getMap(), 3, id);
			say(responses['squeezeExtra'].elementAt(rand.nextInt(responses['squeezeExtra'].length)));
		} else {
			await InventoryV2.addItemToUser(email, items['grain'].getMap(), 1, id);
			say(responses['squeeze'].elementAt(rand.nextInt(responses['squeeze'].length)));
		}

		StatManager.add(email, Stat.chickens_squeezed);
		return true;
	}

	Future<bool> incubate({WebSocket userSocket, String email}) async {
		if (!incubating) {
			// Not busy
			userSocket.add(JSON.encode({
				"action": "incubate2",
				"id": id,
				"openWindow": "itemChooser",
				"filter": "itemType=${EGG_ANIMALS.keys.join("|")}",
				"windowTitle": "Incubate what?"
			}));
			return true;
		} else {
			// Busy
			say("Can't you see I'm busy right now?");
			return false;
		}
	}

	Future<bool> incubate2(
		{WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot}
	) async {
		incubating = true;

		// Take egg from player
	 	if ((await InventoryV2.takeItemFromUser(email, slot, subSlot, 1)) == null) {
			// Taking item failed
			incubating = false;
			return false;
		}

		// Say a random starting message
		say(responses["incubateStart"][rand.nextInt(responses["incubateStart"].length)]);

		// Sit down on the egg
		setState("incubate");

		// Wait 1 minute
		await new Future.delayed(new Duration(minutes: 1));

		// Sit down without the egg
		setState("sit");

		// Say a random ending message
		say(responses["incubateEnd"][rand.nextInt(responses["incubateEnd"].length)]);

		// Give the baby animal to the player
		Item animal = new Item.clone(EGG_ANIMALS[itemType]);
		bool invSuccess = (await InventoryV2.addItemToUser(email, animal.getMap(), 1)) == 1;

		if (!invSuccess) {
			// Giving animal to player failed
			incubating = false;
			return false;
		} else {
			// Giving animal to player succeeded
			incubating = false;
			return true;
		}
	}

	void update() {
		super.update();

		//update x and y
		if(currentState.stateName == "walk" || currentState.stateName == "flying") {
			moveXY();
		}

		//if respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 8 chance to change direction
			if(rand.nextInt(8) == 1)
				facingRight = !facingRight;

			if (!incubating) {
				int num = rand.nextInt(20);
				switch(num) {
					case 1:
						setState('idle1');
						break;
					case 2:
						setState('idle2');
						break;
					case 3:
						setState('idle3');
						break;
					case 4:
						setState('pause');
						break;
					case 5:
						setState('pecking_once');
						break;
					case 6:
						setState('pecking_twice');
						break;
					case 7:
						setState('flying');
						break;
					default:
						setState('walk');
				}
			}
		}
	}
}
