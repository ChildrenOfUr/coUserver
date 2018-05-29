part of entity;

class Rube extends NPC {
	static final int FOLLOW_SPEED = 50;
	static final int MAX_TRADE_ATTEMPTS = 3;

	static final List<String> CUBIMAL_TYPES = [
		'cubimal_batterfly',
		'cubimal_bureaucrat',
		'cubimal_butler',
		'cubimal_butterfly',
		'cubimal_cactus',
		'cubimal_chick',
		'cubimal_crab',
		'cubimal_craftybot',
		'cubimal_deimaginator',
		'cubimal_dustbunny',
		'cubimal_emobear',
		'cubimal_firebogstreetspirit',
		'cubimal_firefly',
		'cubimal_fox',
		'cubimal_foxranger',
		'cubimal_frog',
		'cubimal_gnome',
		'cubimal_greeterbot',
		'cubimal_groddlestreetspirit',
		'cubimal_gwendolyn',
		'cubimal_helga',
		'cubimal_hellbartender',
		'cubimal_ilmenskiejones',
		'cubimal_juju',
		'cubimal_magicrock',
		'cubimal_mealvendor',
		'cubimal_phantom',
		'cubimal_piggy',
		'cubimal_rook',
		'cubimal_rube',
		'cubimal_scionofpurple',
		'cubimal_senorfunpickle',
		'cubimal_sloth',
		'cubimal_smuggler',
		'cubimal_snoconevendor',
		'cubimal_squid',
		'cubimal_toolvendor',
		'cubimal_trisor',
		'cubimal_unclefriendly',
		'cubimal_uraliastreetspirit',
		'cubimal_yeti',
		'cubimal_factorydefect_chick',
		'cubimal_gardeningtoolsvendor',
		'cubimal_maintenancebot'
	];

	static final Map<String, List<String>> RESPONSES = {
		'giveCubimal': [
			'Pour moi? How kind of you! I feel all fluttery inside!',
			'Oh yes, this is very handsome. Thank you so much!',
			'A passable likeness. Always nice to know that someone is thinking of little old me!',
			'Well what have we here? It\'s a bit... square. But it captures the essence, doesn\'t it?',
			'Cubimals are my favorite! And this one is my favoritest favorite!',
			'I shall carry it with me always, and cherish the memory of your kindness'
		]
	};

	static final Action ACTION_CUBIMAL = new Action.withName('Give Cubimal')
		..description = 'Give Rube a cubimal'
		..itemRequirements = new ItemRequirements.set(any: CUBIMAL_TYPES)
		..error = "You don't have any cubimals";

	static final Action ACTION_TALK = new Action.withName('Talk To')
		..description = 'The Rube is bad at trading. Try it!';

	static Future<bool> maybeSpawn(String tsid, String username) async {
		// TODO: fix rube before enabling
		return false;

		// 0.05% chance of spawn when the minute is the number of players online
//		if (rand.nextInt(2000) == 0 && new DateTime.now().minute == PlayerUpdateHandler.users.length.clamp(0, 59)) {
//			Identifier target = PlayerUpdateHandler.users[username];
//			if (target == null) {
//				return false;
//			}
//
//			if ((await StreetEntities.getEntities(tsid)).where((StreetEntity entity) => entity.type == 'Rube').isNotEmpty) {
//				// Rube is already on this street
//				return false;
//			}
//
//			StreetEntity entity = new StreetEntity.create(
//				id: createId(target.currentX ?? 0, target.currentY ?? 0, 'Rube', tsid),
//				type: 'Rube',
//				tsid: tsid,
//				x: target.currentX ?? 0,
//				y: target.currentY ?? 0,
//				metadata_json: JSON.encode({'targetUsername': username}));
//			return await StreetEntities.setEntity(entity);
//		} else {
//			return false;
//		}
	}

	Identifier target;
	String targetUsername;
	String tsid;

	bool announced = false;
	int tradeAttempts = 0;
	Completer<TradeBtn> playerResponse;

	Rube(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Rube';
		actionTime = 0;
		speed = FOLLOW_SPEED;
		actions = [ACTION_CUBIMAL, ACTION_TALK];
		states = {
			'fade_out': new Spritesheet(
				'fade_out',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_fade_out_png_1354831089.png',
				972, 1848, 108, 154, 101, false),
			'offer_accept': new Spritesheet(
				'offer_accept',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_offer_accept_png_1354831080.png',
				972, 1232, 108, 154, 70, false),
			'offer_reject': new Spritesheet(
				'offer_reject',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_offer_reject_png_1354831084.png',
				972, 2310, 108, 154, 130, false),
			'offer_trade': new Spritesheet(
				'offer_trade',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_offer_trade_png_1354831077.png',
				3672, 1540, 108, 154, 340, true),
			'spawn_in': new Spritesheet(
				'spawn_in',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_spawn_in_png_1354831067.png',
				972, 3542, 108, 154, 205, false),
			'talk': new Spritesheet(
				'talk',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_talk_png_1354831071.png',
				756, 462, 108, 154, 20, true),
			'walk_end': new Spritesheet(
				'walk_end',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_walk_end_png_1354831070.png',
				756, 308, 108, 154, 14, false),
			'walk': new Spritesheet(
				'walk',
				'https://childrenofur.com/assets/entityImages/npc_rube__x1_walk_png_1354831069.png',
				864, 308, 108, 154, 15, true)
		};
		setState('spawn_in');
		new Future.delayed(new Duration(seconds: 3)).then((_) => setState('walk'));

		this.tsid = tsidL(MapData.getStreetByName(this.streetName)['tsid']);
	}

	bool get targetIsHere => (PlayerUpdateHandler.users[targetUsername]?.currentStreet ?? '') == this.streetName;

	@override
	update({bool simulateTick: false}) {
		super.update(simulateTick: simulateTick);

		if (simulateTick) {
			if (targetIsHere) {
				if (!announced) {
					say("Hey, $targetUsername! Come talk to me if you'd like to trade.");
					announced = true;
				}
			} else {
				// Target player left the street
				remove();
			}
		} else {
			// Walk toward the player
			num distFromTarget = this.x - (target?.currentX ?? 0);
			facingRight = distFromTarget < 0;

			if (distFromTarget.abs() > 100) {
				setState('walk');
				speed = FOLLOW_SPEED;
			} else {
				// Stop 100px from the player
				setState('walk_end');
				speed = 0;
			}
		}
	}

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);

		if (metadata['targetUsername'] == null) {
			// Missing data
			List<Identifier> onStreet = PlayerUpdateHandler.users.values
				.where((Identifier id) => id.currentStreet == this.tsid).toList();
			if (onStreet.isNotEmpty) {
				// Pick a random target on this street
				targetUsername = onStreet[rand.nextInt(onStreet.length)].username;
			}
		} else {
			targetUsername = metadata['targetUsername'];
		}

		if (targetUsername != null) {
			target = PlayerUpdateHandler.users[targetUsername];
			if (target == null || target.currentStreet != this.streetName) {
				// Player is not on this street
				remove();
			}
		}
	}

	@override
	Map<String, String> getPersistMetadata() => super.getPersistMetadata()
		..['targetUsername'] = targetUsername;

	/// Fade out and delete entity
	Future remove() async {
		Future _removeFromStreet() async {
			try {
				(await StreetEntities.getEntities(tsid))
					.where((StreetEntity entity) => entity.type == this.type)
					.forEach((StreetEntity entity) => StreetEntities.deleteEntity(entity.id));
			} catch (e) {
				Log.error('Did not remove Rube from <tsid=$tsid>', e);
			}
		}

		setState('fade_out');

		await Future.wait([
			_removeFromStreet(),
			new Future.delayed(new Duration(seconds: 4)) // fade out animation duration
		]);
	}

	@ActionCallback()
	Future<bool> giveCubimal({WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot}) async {
		if (itemType != null && slot != null && subSlot != null) {
			// Already picked a cubimal
			if ((await InventoryV2.takeItemFromUser(email, slot, subSlot, 1)) != 1) {
				return false;
			}

			MetabolicsChange mc = new MetabolicsChange();
			await mc.trySetMetabolics(email, imgMin: itemType.length ~/ 2, imgRange: 5);
			say(RESPONSES['giveCubimal'][rand.nextInt(RESPONSES['giveCubimal'].length)]);
			return true;
		} else {
			// Pick cubimal
			userSocket.add(jsonEncode({
				"action": "giveCubimal", // recursive call, but with more arguments
				"id": id,
				"openWindow": "itemChooser",
				"filter": "itemType=${CUBIMAL_TYPES.join('|')}",
				"windowTitle": "Give which cubimal?"
			}));
			return false;
		}
	}

	@ActionCallback()
	Future<bool> talkTo({WebSocket userSocket, String email}) async {
		String username = await User.getUsernameFromEmail(email);

		if (username != targetUsername) {
			say("I'm here for ${targetIsHere ? targetUsername : 'someone else'}.", username);
			return false;
		}

		if (tradeAttempts >= MAX_TRADE_ATTEMPTS) {
			say("I'm done trading for the time being", username);
			return false;
		}

		setState('talk');

		do {
			Item giveOffer = await _getNextOffer(email);
			Item takeOffer = await _getNextTake(email);

			playerResponse = new Completer();

			String urgency = {
				0: 'OK?',
				1: 'I only have so much patience!',
				2: 'Last chance!'
			}[tradeAttempts] ?? '';

			say("I'll give you my ${giveOffer.name} for one of your ${pluralize(takeOffer.name)}. $urgency", username, {
				'Sounds great!': () => playerResponse.complete(TradeBtn.YES),
				'What else do you have?': () => playerResponse.complete(TradeBtn.REDO),
				'No thanks.': () => playerResponse.complete(TradeBtn.NO)
			});

			TradeBtn clicked = await playerResponse.future;

			if (clicked == TradeBtn.REDO) {
				tradeAttempts++;
				continue;
			} else if (clicked == TradeBtn.NO) {
				setState('offer_reject');
				say('I cannot find anything else I wish to part with. Next time, next time...', username);
				await new Future.delayed(new Duration(seconds: 3));
				remove();
				return false;
			} else if (clicked == TradeBtn.YES) {
				// Take the trade deal
				setState('offer_accept');
				if ((await InventoryV2.takeAnyItemsFromUser(email, takeOffer.itemType, 1)) != 1) {
					say('Not sure where your item went...', username);
					await new Future.delayed(new Duration(seconds: 3));
					remove();
					return false;
				}

				// Give the player their new item
				if ((await InventoryV2.addItemToUser(email, giveOffer.itemType, 1)) != 1) {
					say('Oh dear. You do not have enough room to carry that. Please make some space and come back to talk to me.', username);
					tradeAttempts = 0;
					return false;
				}

				// Both operations went ok
				setState('offer_trade');
				say('Great deal, great deal!', username);
				await new Future.delayed(new Duration(seconds: 3));
				remove();
				return true;
			}
		} while (tradeAttempts < MAX_TRADE_ATTEMPTS);

		return false;
	}

	/// An item to offer the player
	Future<Item> _getNextOffer(String email) async {
		int minCost = await _getMinCost(email);

		List<Item> candidates = items.values.where((Item item) => item.price >= minCost).toList();
		candidates.sort((Item a, Item b) => a.price - b.price);

		return candidates[rand.nextInt(candidates.length)];
	}

	/// An item to take from the player
	Future<Item> _getNextTake(String email) async {
		InventoryV2 playerInv = await getInventory(email);
		int minCost = ((await _getMinCost(email)) / 2).ceil();

		List<Item> candidates = [];

		for (Map<String, dynamic> playerItem in playerInv.getItems()) {
			if (playerItem['metadata'] != null && playerItem['metadata'].length > 0) {
				// Don't take items with metadata
				continue;
			}

			Item obj = items[playerItem['itemType']];
			if (obj != null && obj.price >= minCost) {
				candidates.add(obj);
			}
		}

		return candidates[rand.nextInt(candidates.length)];
	}

	/// Minimum item cost based on the player's level
	Future<int> _getMinCost(String email) async {
		int playerLevel = (await getMetabolics(email: email)).level;

		int minCost = 1;

		if (playerLevel < 10) {
			minCost = 1;
		} else if (playerLevel < 20) {
			minCost = 10;
		} else if (playerLevel < 30) {
			minCost = 20;
		} else if (playerLevel < 40) {
			minCost = 30;
		} else if (playerLevel < 50) {
			minCost = 50;
		} else if (playerLevel < 60) {
			minCost = 100;
		}

		return minCost;
	}
}

enum TradeBtn {
	YES, REDO, NO
}