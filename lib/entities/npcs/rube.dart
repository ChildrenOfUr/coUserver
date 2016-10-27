part of entity;

class Rube extends NPC {
	static final int FOLLOW_SPEED = 50;

	static Future<bool> maybeSpawn(String tsid, String username) async {
		// 1% chance of spawn when the minute is the number of players online
		if (rand.nextInt(100) == 0 && new DateTime.now().minute == PlayerUpdateHandler.users.length.clamp(0, 59)) {
			Identifier target = PlayerUpdateHandler.users[username];
			if (target == null) {
				return false;
			}

			if ((await StreetEntities.getEntities(tsid)).isNotEmpty) {
				// Rube is already on this street
				return false;
			}

			StreetEntity entity = new StreetEntity.create(
				id: createId(target.currentX, target.currentY, 'Rube', tsid),
				type: 'Rube',
				tsid: tsid,
				x: target.currentX,
				y: target.currentY,
				metadata_json: JSON.encode({'targetUsername': username}));
			return await StreetEntities.setEntity(entity);
		} else {
			return false;
		}
	}

	Identifier target;
	String targetUsername;
	String tsid;
	bool targetReached;

	Rube(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Rube';
		actionTime = 0;
		speed = FOLLOW_SPEED;
		actions = [];
		states = {
			'fade_out': new Spritesheet(
				'fade_out',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_fade_out_png_1354831089.png',
				972, 1848, 108, 154, 101, false),
			'offer_accept': new Spritesheet(
				'offer_accept',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_offer_accept_png_1354831080.png',
				972, 1232, 108, 154, 70, false),
			'offer_reject': new Spritesheet(
				'offer_reject',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_offer_reject_png_1354831084.png',
				972, 2310, 108, 154, 130, false),
			'offer_trade': new Spritesheet(
				'offer_trade',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_offer_trade_png_1354831077.png',
				3672, 1540, 108, 154, 340, true),
			'spawn_in': new Spritesheet(
				'spawn_in',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_spawn_in_png_1354831067.png',
				972, 3542, 108, 154, 205, false),
			'talk': new Spritesheet(
				'talk',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_talk_png_1354831071.png',
				756, 462, 108, 154, 20, true),
			'walk_end': new Spritesheet(
				'walk_end',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_walk_end_png_1354831070.png',
				756, 308, 108, 154, 14, false),
			'walk': new Spritesheet(
				'walk',
				'http://c2.glitch.bz/items/2012-12-06/npc_rube__x1_walk_png_1354831069.png',
				864, 308, 108, 154, 15, true)
		};
		setState('spawn_in');

		this.tsid = tsidL(MapData.getStreetByName(this.streetName)['tsid']);
	}

	@override
	update({bool simulateTick: false}) {
		super.update(simulateTick: simulateTick);

		// Walk toward the player
		facingRight = (target.currentX > this.x);

		// Stop 100px from the player
		speed = (target.currentX - this.x).abs() > 100 ? FOLLOW_SPEED : 0;
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

	Future remove() async {
		Future _removeFromStreet() async {
			try {
				List<StreetEntity> entities = await StreetEntities.getEntities(tsid);
				await Future.forEach(entities, (StreetEntity entity) async {
					StreetEntities.deleteEntity(entity.id);
				});
			} catch (e) {
				Log.error('Did not remove Rube from <tsid=$tsid>', e);
			}
		}

		setState('fade_out');

		await Future.wait([
			_removeFromStreet(),
			new Future.delayed(new Duration(seconds: 4))
		]);
	}
}
