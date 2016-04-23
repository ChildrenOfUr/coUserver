part of entity;

class Crab extends NPC {
	static final Map HEADPHONES = items["crabpod_headphones"].getMap();
	static final Map CRABATO = items["crabato_juice"].getMap();

	static final String ERROR_NO_MUSIC = "You're musicblock-broke, yo.";
	static final String ERROR_BUSY = "Go away, I'm busy right now!";
	static final String WARN_HEADPHONES = "You stole my headphones! No juice for you!";

	static final List<String> MUSICBLOCK_TYPES = [
		"musicblock_bb_1",  "musicblock_bb_2",  "musicblock_bb_3",  "musicblock_bb_4",  "musicblock_bb_5",
		"musicblock_db_1",  "musicblock_db_2",  "musicblock_db_3",  "musicblock_db_4",  "musicblock_db_5",
		"musicblock_dg_1",  "musicblock_dg2",   "musicblock_dg3",   "musicblock_dg4",   "musicblock_dg5",
		"musicblock_dr_1",  "musicblock_dr_2",  "musicblock_dr_3",  "musicblock_dr_4",  "musicblock_dr_5",
		"musicblock_xs_1",  "musicblock_xs_2",  "musicblock_xs_3",  "musicblock_xs_4",  "musicblock_xs_5",
		"musicblock_gng",   "musicblock_stoot", "musicblock_trumpets"
	];
	static final List<String> MUSICBLOCK_RARES = [
		"musicblock_gng", "musicblock_stoot", "musicblock_trumpets"
	];

	static String randomMusicblock() {
		return MUSICBLOCK_TYPES[rand.nextInt(MUSICBLOCK_TYPES.length)];
	}

	final int IDLE_TYPE = rand.nextInt(3);

	String busyWithEmail = "";
	bool get busy => (busyWithEmail.length > 0);

	List<String> listenHistory = new List();

	Crab(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Crab";
		speed = 60; // pixels per second

		actionTime = 0;
		actions.add({
			"action": "Talk To",
			"timeRequired": actionTime,
			"enabled": true,
			"actionWord": "crabbing",
			"requires": [{
				"num": 1,
				"of": MUSICBLOCK_TYPES,
				"error": ERROR_NO_MUSIC
			}]
		});

		states = {
			"dislike_off": new Spritesheet(
				"dislike_off", "http://childrenofur.com/assets/entityImages/npc_crab__x1_dislike_off_png_1354831193.png",
				786, 516, 131, 129, 22, true),
			"dislike_on": new Spritesheet(
				"dislike_on", "http://childrenofur.com/assets/entityImages/npc_crab__x1_dislike_on_png_1354831191.png",
				786, 516, 131, 129, 30, true),
			"idle0": new Spritesheet(
				"idle0", "http://childrenofur.com/assets/entityImages/npc_crab__x1_idle0_png_1354831199.png",
				786, 645, 131, 129, 30, true),
			"idle1": new Spritesheet(
				"idle1", "http://childrenofur.com/assets/entityImages/npc_crab__x1_idle1_png_1354831200.png",
				786, 645, 131, 129, 30, true),
			"idle2": new Spritesheet(
				"idle2", "http://childrenofur.com/assets/entityImages/npc_crab__x1_idle2_png_1354831201.png",
				786, 645, 131, 129, 30, true),
			"like_off": new Spritesheet(
				"like_off", "http://childrenofur.com/assets/entityImages/npc_crab__x1_like_off_png_1354831189.png",
				786, 516, 131, 129, 24, true),
			"like_on": new Spritesheet(
				"like_on", "http://childrenofur.com/assets/entityImages/npc_crab__x1_like_on_png_1354831187.png",
				786, 516, 131, 129, 24, true),
			"listen": new Spritesheet(
				"listen", "http://childrenofur.com/assets/entityImages/npc_crab__x1_listen_png_1354831185.png",
				786, 516, 131, 129, 24, true),
			"talk": new Spritesheet(
				"talk", "http://childrenofur.com/assets/entityImages/npc_crab__x1_talk_png_1354831203.png",
				917, 1161, 131, 129, 58, false),
			"walk": new Spritesheet(
				"walk", "http://childrenofur.com/assets/entityImages/npc_crab__x1_walk_png_1354831183.png",
				786, 516, 131, 129, 24, true)
		};

		goIdle();
	}

	/// Switch to this crab's idle state
	void goIdle() => setState("idle$IDLE_TYPE");

	/// Walk around the street
	void update() {
		if (!busy) {
			super.update();
			bool walking = (currentState.stateName == "walk");

			if (walking) {
				moveXY();
			}

			if (respawn != null && new DateTime.now().compareTo(respawn) > 0) {
				// 1 in 8 chance to change direction
				if (rand.nextInt(8) == 1) {
					facingRight = !facingRight;
				}

				int chance = rand.nextInt(5);
				if (chance > 3 || (chance > 2 && walking)) {
					setState("walk");
				} else {
					goIdle();
				}
			}
		}
	}

	/// Called from the client menu
	void talkTo({WebSocket userSocket, String email}) {
		if (!busy) {
			// Allow interaction
			busyWithEmail = email;

			userSocket.add(JSON.encode({
				"action": "playMusic",
				"id": id,
				"openWindow": "itemChooser",
				"filter": "itemType=musicblock*",
				"windowTitle": "Play what for Crab?"
			}));
		} else {
			// Only 1 player at a time
			say(ERROR_BUSY);
		}
	}

	/// Adds a song to the history of the crab.
	/// If it is already in the list, it is moved to the end.
	void addToHistory(String music) {
		listenHistory
			..remove(music) // Remove from where it was before (if it was at all)
			..add(music); // Add to end of list
	}

	/// A crab likes a song if it is in the first half of the list (sorted oldest to newest)
	bool likesSong(String music) => listenHistory.indexOf(music) < listenHistory.length ~/ 2;

	/// How long the song plays for
	Duration randSongLength() => new Duration(seconds: rand.nextInt(11) + 5);

	/// How long the crab animates
	Duration randReactLength() => randSongLength() ~/ 2;

	/// Make the crab hear this noise
	Future playMusic({WebSocket userSocket, String email, String itemType, int count}) async {
		assert (userSocket != null);
		assert (email != null);
		assert (itemType != null && MUSICBLOCK_TYPES.contains(itemType));

		Future _takeMusicblock() => InventoryV2.takeAnyItemsFromUser(email, itemType, 1);
		Future _giveMusicblock() => InventoryV2.addItemToUser(email, items[itemType].getMap(), 1);
		Future _giveHeadphones() => InventoryV2.addItemToUser(email, HEADPHONES, 1, id);
		Future _takeHeadphones() => InventoryV2.takeAnyItemsFromUser(email, HEADPHONES["itemType"], 1);

		bool isRare = MUSICBLOCK_RARES.contains(itemType);

		if (await _takeMusicblock() < 1) {
			// Could not take musicblock from player
			say(ERROR_NO_MUSIC);
			return;
		}

		await _giveHeadphones();

		setState("listen");
		await new Future.delayed(randSongLength());

		// Reward player
		if (likesSong(itemType)) {
			// Dance for a bit

			setState("like_on");
			await new Future.delayed(randReactLength());

			setState("like_off");
			await _giveMusicblock();

			if (await _takeHeadphones() < 1) {
				// Headphones are gone (collectible)
				say(WARN_HEADPHONES);
			} else {
				// Headphones returned, award crabato juice
				await InventoryV2.addItemToUser(email, CRABATO, 1, id);
			}
		} else {
			// Be crabby

			setState("dislike_on");
			await new Future.delayed(randReactLength());

			setState("like_off");
			await _giveMusicblock();

			await _takeHeadphones();
		}

		await trySetMetabolics(email, energy: -1, mood: 1, imgMin: (isRare ? 5 : 1), imgRange: 2);

		// Affect future listens
		addToHistory(itemType);
		busyWithEmail = "";
	}
}