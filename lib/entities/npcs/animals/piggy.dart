part of entity;

class Piggy extends NPC {
	static final String SKILL = 'animal_kinship';
	static final int NIBBLE_ENERGY = -5;
	static final int PET_ENERGY = -4;
	List<String> petList = [], nibbleList = [];
	DateTime lastReset = new DateTime.now();

	Piggy(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		ItemRequirements itemReq = new ItemRequirements()
			..any = ['broccoli','cabbage','carrot','corn','cucumber','onion',
							'parsnip','potato','pumpkin','rice','spinach','tomato','zucchini']
			..error = "You don't have anything that looks good right now";
		actions.addAll([
			 new Action.withName('nibble')
				 ..timeRequired = actionTime
				 ..actionWord = 'nibbling'
				 ..energyRequirements = new EnergyRequirements(energyAmount: NIBBLE_ENERGY)
				..associatedSkill = SKILL,
			new Action.withName('pet')
				..timeRequired = actionTime
				..actionWord = 'petting'
				..energyRequirements = new EnergyRequirements(energyAmount: PET_ENERGY)
				..associatedSkill = SKILL,
			new Action.withName('feed')
				..itemRequirements = itemReq
				..associatedSkill = SKILL
				  ]);
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
		setState('walk');

		responses =
		{
			"nibble": [
				"Ya bacon me crazy!"
			],
			"pet": [
				"Do I boar you?"
			]
		};

		Clock clock = new Clock();
		clock.onNewDay.listen((_) => _resetLists());
	}

	void _resetLists() {
		petList.clear();
		nibbleList.clear();
		lastReset = new DateTime.now();
	}

	void restoreState(Map<String, String> metadata) {
		if (metadata.containsKey('petList')) {
			petList = JSON.decode(metadata['petList']);
		}
		if (metadata.containsKey('nibbleList')) {
			nibbleList = JSON.decode(metadata['nibbleList']);
		}
		if (metadata.containsKey('lastReset')) {
			lastReset = new DateTime.fromMillisecondsSinceEpoch(int.parse(metadata['lastReset']));
			Clock lastResetClock = new Clock.stoppedAtDate(lastReset);
			Clock currentClock = new Clock.stoppedAtDate(new DateTime.now());
			if (lastResetClock.dayInt < currentClock.dayInt ||
			    lastResetClock.hourInt < 6 && currentClock.hourInt >= 6) {
				_resetLists();
			}
		}
	}

	Map<String, String> getPersistMetadata() {
		Map<String, String> map = {
			'petList': JSON.encode(petList),
			'nibbleList': JSON.encode(nibbleList),
			'lastReset': lastReset.millisecondsSinceEpoch.toString()
		};

		return map;
	}

	Future<bool> _setLevelBasedMetabolics(int level, String action, String email) async {
		int mood = 2;
		int imgMin = 5;
		int energy = 0;

		if (action == 'pet') {
			energy = PET_ENERGY;
		} else if (action == 'nibble') {
			energy = NIBBLE_ENERGY;
		}

		if (level > 0) {
			mood *= level+1;
			imgMin *= level+1;
			energy ~/= level;
		}

		return trySetMetabolics(email, energy: energy, mood: mood, imgMin: imgMin, imgRange: 4);
	}

	Future<bool> nibble({WebSocket userSocket, String email}) async {
		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'nibble', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_nibbled);
		SkillManager.learn(SKILL, email);
		nibbleList.add(email);

		//give the player the 'fruits' of their labor
		int odds = 100000;
		int count = 1;
		if (level == 7) {
			count = 4;
			odds = 3;
		} else if (level > 4) {
			count = 3;
			odds = 10;
		} else if (level > 3) {
			odds = 20;
		} else if (level > 1) {
			count = 2;
		}
		if (rand.nextInt(odds) == 7) {
			count += 5;
		}

		await InventoryV2.addItemToUser(email, items['meat'].getMap(), count, id);

		setState('nibble');
		say(responses['nibble'].elementAt(rand.nextInt(responses['nibble'].length)));

		return true;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'pet', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_petted);
		SkillManager.learn(SKILL, email);
		petList.add(email);

		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		QuestEndpoint.questLogCache[email].offerQuest('Q9');

		return true;
	}

	Future<bool> feed({WebSocket userSocket, String email}) async {
		Map map = {};
		map["action"] = "feedItem";
		map['id'] = id;
		map['openWindow'] = 'itemChooser';
		map['filter'] = 'category=Croppery & Gardening Supplies|||itemType=^(?!.+(?:_seed|_bean)).+\$';
		map['windowTitle'] = 'Feed Piggy What?';
		userSocket.add(JSON.encode(map));
		return true;
	}

	Future<bool> feedItem({WebSocket userSocket, String itemType, int count, String email, int slot, int subSlot}) async {
		bool success = (await InventoryV2.takeItemFromUser(email, slot, subSlot, count)) != null;
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_fed);
		SkillManager.learn(SKILL, email);

		Item item = new Item.clone('piggy_plop');
		item.metadata['seedType'] = itemType;
		item.putItemOnGround(x,y,streetName);
		setState('chew', repeat:2);
		return true;
	}

	/**
	 * Will simulate piggy movement and send updates to clients if needed
	 */
	update() {
		super.update();

		//update x and y
		if(currentState.stateName == "walk") {
			moveXY();
		}

		//if respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 8 chance to change direction
			if(rand.nextInt(8) == 1) {
				facingRight = !facingRight;
			}

			int num = rand.nextInt(20);
			if(num == 6) {
				setState('look_screen');
			} else {
				setState('walk');
			}
		}
	}

	@override
	Future<List<Action>> customizeActions(String email) async {
		int akLevel = await SkillManager.getLevel(SKILL, email);
		List<Action> personalActions = [];
		await Future.forEach(actions, (Action action) async {
			Action personalAction = new Action.clone(action);
			if (action.actionName == 'nibble') {
				//player must have petted first unless their level is > 5
				//also they can only nibble once per day
				if (akLevel > 5) {
					int times = _countNibbles(email);
					if (times >= 2) {
						personalAction.enabled = false;
						personalAction.error = 'You can only nibble this piggy twice per day';
					}
				} else {
					if (!petList.contains(email)) {
						personalAction.enabled = false;
						personalAction.error = 'Try petting first';
					} else if (nibbleList.contains(email)) {
						personalAction.enabled = false;
						personalAction.error = 'You can only nibble this piggy once per day';
					}
				}

				if (akLevel > 5) {
					personalAction.energyRequirements.energyAmount = 2;
				} else if (akLevel > 2) {
					personalAction.energyRequirements.energyAmount = 4;
				}
			}
			personalActions.add(personalAction);
		});
		return personalActions;
	}

	int _countNibbles(String email) {
		int times = 0;
		for (String e in nibbleList) {
			if (e == email) {
				times++;
			}
		}
		return times;
	}
}
