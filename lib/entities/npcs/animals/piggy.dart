part of entity;

class Piggy extends NPC {
	static final String SKILL = 'animal_kinship';
	static final int NIBBLE_ENERGY = -5;
	static final int PET_ENERGY = -4;
	Map<String, int> petCounts = {};
	Map<String, int> nibbleCounts = {};
	DateTime lastReset = new DateTime.now();

	Piggy(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		ItemRequirements itemReq = new ItemRequirements()
			..any = ['broccoli','cabbage','carrot','corn','cucumber','onion', 'parsnip','potato','pumpkin','rice','spinach','tomato','zucchini']
			..error = "You don't have anything that looks good right now";
		actions.addAll([
			new Action.withName('nibble')
				..timeRequired = actionTime
				..actionWord = 'nibbling'
				..description = 'Have a little nibble'
				..energyRequirements = new EnergyRequirements(energyAmount: NIBBLE_ENERGY)
				..associatedSkill = SKILL,
			new Action.withName('pet')
				..timeRequired = actionTime
				..actionWord = 'petting'
				..description = 'Give the piggy a pet'
				..energyRequirements = new EnergyRequirements(energyAmount: PET_ENERGY)
				..associatedSkill = SKILL,
			new Action.withName('feed')
				..description = 'Feed the piggy some produce and see what it produces'
				..itemRequirements = itemReq
				..associatedSkill = SKILL
		]);
		type = "Piggy";
		speed = 75; //pixels per second
		renameable = true;

		states = {
			"chew" : new Spritesheet("chew", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_chew_png_1354829433.png", 968, 310, 88, 62, 53, true),
			"look_screen" : new Spritesheet("look_screen", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_look_screen_png_1354829434.png", 880, 310, 88, 62, 48, false),
			"nibble" : new Spritesheet("nibble", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_nibble_png_1354829441.png", 880, 372, 88, 62, 60, false),
			"rooked1" : new Spritesheet("rooked1", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_rooked1_png_1354829442.png", 880, 62, 88, 62, 10, true),
			"rooked2" : new Spritesheet("rooked2", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_rooked2_png_1354829443.png", 704, 186, 88, 62, 24, false),
			"too_much_nibble" : new Spritesheet("too_much_nibble", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_too_much_nibble_png_1354829441.png", 968, 372, 88, 62, 65, false),
			"walk" : new Spritesheet("walk", "https://childrenofur.com/assets/entityImages/npc_piggy__x1_walk_png_1354829432.png", 704, 186, 88, 62, 24, true)
		};
		setState('walk');

		responses = {
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
		petCounts.clear();
		nibbleCounts.clear();
		lastReset = new DateTime.now();
	}

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);

		if (metadata.containsKey('petCounts')) {
			petCounts = JSON.decode(metadata['petCounts']);
		}

		if (metadata.containsKey('nibbleCounts')) {
			nibbleCounts = JSON.decode(metadata['nibbleCounts']);
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

	@override
	Map<String, String> getPersistMetadata() =>
		super.getPersistMetadata()
			..['petCounts'] = JSON.encode(petCounts)
			..['nibbleCounts'] = JSON.encode(nibbleCounts)
			..['lastReset'] = lastReset.millisecondsSinceEpoch.toString();

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
			mood *= level + 1;
			imgMin *= level + 1;
			energy ~/= level;
		}

		return trySetMetabolics(email, energy: energy, mood: mood, imgMin: imgMin, imgRange: 4);
	}

	Future<bool> nibble({WebSocket userSocket, String email}) async {
		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'nibble', email);
		if (!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_nibbled);
		SkillManager.learn(SKILL, email);
		nibbleCounts[email] = (nibbleCounts[email] ?? 0) + 1;
		messageBus.publish(new RequirementProgress('piggyNibble', email));
		QuestEndpoint.questLogCache[email]?.offerQuest('Q11');
		//Piggy Nibbler Quest

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

		// Award achievements
		int totalNibbled = await StatManager.get(email, Stat.piggies_nibbled);

		if (totalNibbled >= 503) {
			Achievement.find("transrational_meat_aficionado").awardTo(email);
		} else if (totalNibbled >= 137) {
			Achievement.find("ham_hocker").awardTo(email);
		} else if (totalNibbled >= 41) {
			Achievement.find("bacon_biter").awardTo(email);
		} else if (totalNibbled >= 17) {
			Achievement.find("piggy_nibbler").awardTo(email);
		}

		return true;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'pet', email);
		if (!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_petted);
		SkillManager.learn(SKILL, email);
		petCounts[email] = (petCounts[email] ?? 0) + 1;

		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		QuestEndpoint.questLogCache[email]?.offerQuest('Q9');

		// Award achievements
		int totalPetted = await StatManager.get(email, Stat.piggies_petted);

		if (totalPetted >= 137) {
			Achievement.find("pork_petter_extraordinaire").awardTo(email);
		} else if (totalPetted >= 41) {
			Achievement.find("swine_snuggler").awardTo(email);
		} else if (totalPetted >= 17) {
			Achievement.find("pork_fondler").awardTo(email);
		}


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
		if (!success) {
			return false;
		}

		StatManager.add(email, Stat.piggies_fed);
		SkillManager.learn(SKILL, email);

		Item item = new Item.clone('piggy_plop');
		item.metadata['seedType'] = itemType;
		item.putItemOnGround(x, y, streetName);
		setState('chew', repeat: 2);
		return true;
	}

	/**
	 * Will simulate piggy movement and send updates to clients if needed
	 */
	update({bool simulateTick: false}) {
		super.update();

		//update x and y
		if (currentState.stateName == "walk") {
			moveXY();
		}

		//if respawn is in the past, it is time to choose a new animation
		if (respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 8 chance to change direction
			if (rand.nextInt(8) == 1) {
				facingRight = !facingRight;
			}

			int num = rand.nextInt(20);
			if (num == 6) {
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
		await Future.forEach(await super.customizeActions(email), (Action action) async {
			Action personalAction = new Action.clone(action);
			if (action.actionName == 'nibble') {
				int maxNibbles = (akLevel >= 6 ? 2 : 1); // AK 6 gives 2 nibbles per day, otherwise 1

				// Player must have petted first unless their AK level is at least 6
				if ((nibbleCounts[email] ?? 0) >= maxNibbles) {
					personalAction.enabled = false;
					personalAction.error = 'You can only nibble this piggy ${maxNibbles == 2 ? 'twice' : 'once'} per day';
				} else if (akLevel < 6 && (petCounts[email] ?? 0) == 0) {
					personalAction.enabled = false;
					personalAction.error = 'Try petting first';
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
}
