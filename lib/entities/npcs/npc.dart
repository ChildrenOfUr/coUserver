part of entity;

abstract class NPC extends Entity {
	/**
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 * */

	/// 1px x 1px transparent gif.
	/// The client will disable interaction on this state by checking the url string,
	/// so update it in the client as well as the server if you change it.
	static final Spritesheet TRANSPARENT_SPRITE = new Spritesheet('_hidden',
		'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
		1, 1, 1, 1, 1, true);

	static int updateFps = 12;

	static Map<int, Function> pendingBubbleCallbacks = {};

	String id, type, streetName;
	num x, y, z, rotation = 0, previousX, previousY, speed = 0, ySpeed = 0, yAccel = -2400;
	bool facingRight = true, grounded = false, h_flip = false, dontFlip = false;
	bool renameable = false;
	String nameOverride;
	MutableRectangle _collisionsRect;
	Map<String, String> metadata = {};

	/// Username and chat bubble text
	Map<String, String> personalBubbles = {};

	NPC(this.id, this.x, this.y, this.z, this.rotation, this.h_flip, this.streetName) {
		respawn = new DateTime.now();
	}

	@override
	Future<List<Action>> customizeActions(String email) async {
		List<Action> customActions = new List.from(actions);

		if (renameable && await SkillManager.getLevel('animal_kinship', email) >= 5) {
			customActions.add(new Action.withName('rename'));
		}

		return customActions;
	}

	void restoreState(Map<String, String> metadata) {
		this.metadata = metadata;

		if (metadata['facingRight'] == 'false') {
			facingRight = false;
		}

		if (metadata['nameOverride'] != null) {
			nameOverride = metadata['nameOverride'];
		}
	}

	Map<String, String> getPersistMetadata() {
		metadata
			..['facingRight'] = facingRight.toString();

		if (nameOverride != null && renameable) {
			metadata['nameOverride'] = nameOverride;
		}

		return this.metadata;
	}

	int get width => currentState.frameWidth;

	int get height => currentState.frameHeight;

	bool get hasMoved => x != previousX || y != previousY;

	Street get street => StreetUpdateHandler.streets[streetName];

	Rectangle get collisionsRect {
		if (_collisionsRect == null) {
			_collisionsRect = new MutableRectangle(x, y, width, height);
		} else {
			_collisionsRect.left = x;
			_collisionsRect.top = y;
			_collisionsRect.width = width;
			_collisionsRect.height = height;
		}

		return _collisionsRect;
	}

	///update() will be called [NPC.updateFps] times per second. This is usually intended to setState and update the
	///x,y coordinates. If you want do something more expensive, probably it should only be done when [simualteTick] is true
	void update({bool simulateTick: false}) {
		previousX = x;
		previousY = y;
	}

	void defaultWallAction(Wall wall) {
		facingRight = !facingRight;

		if (wall == null) {
			return;
		}

		if (facingRight) {
			if (collisionsRect.right >= wall.bounds.left) {
				x = wall.bounds.left - width - 1;
			}
		} else {
			if (collisionsRect.left < wall.bounds.left) {
				x = wall.bounds.right + 1;
			}
		}
	}

	void defaultLedgeAction() {
		y = previousY;
		x = previousX;
		facingRight = !facingRight;
	}

	void defaultXAction() {
		x += speed * (facingRight ? 1 : -1) / NPC.updateFps;
	}

	void defaultYAction() {
		ySpeed -= yAccel / NPC.updateFps;
		y += ySpeed / NPC.updateFps;
		y = street.getYFromGround(x, previousY, width, height);
	}

	///Move the entity 'forward' according to which direction they are facing
	///and based on the platform lines available on the street
	///
	///If the entity should perform actions other than the defaults at certain
	///conditions (such as walls and ledges etc.) then pass those as function pointers
	///else the default action will be taken
	void moveXY({Function xAction, Function yAction, Function wallAction, Function ledgeAction}) {
		if (previousY == null) {
			throw "Did you forget to call super.update()?";
		}

		if (wallAction == null) {
			wallAction = defaultWallAction;
		}
		if (ledgeAction == null) {
			ledgeAction = defaultLedgeAction;
		}
		if (xAction == null) {
			xAction = defaultXAction;
		}
		if (yAction == null) {
			yAction = defaultYAction;
		}

		xAction();
		yAction();

		//if our new y value is more than 10 pixels away from the old one
		//we probably changed platforms (dropped down) so decide what to do about that
		if (grounded && (y - previousY).abs() > 10) {
			ledgeAction();
		} else if ((y - previousY).abs() < 10) {
			grounded = true;
		}

		//stop walking into walls, take an action if we're colliding with one
		for (Wall wall in street.walls) {
			if (collisionsRect.intersects(wall.bounds)) {
				wallAction(wall);
			}
		}

		//treat the sides of the street as walls too
		if (x < 0) {
			wallAction(null);
			x = 0;
		}

		if ((street?.bounds) != null && x > street.bounds.width - width) {
			wallAction(null);
			x = street.bounds.width - width;
		}
	}

	@override
	Map getMap([String username]) {
		Map entity = super.getMap()
			..addAll({
				"id": id,
				"url": currentState.url,
				"type": type,
				"nameOverride": nameOverride,
				"numRows": currentState.numRows,
				"numColumns": currentState.numColumns,
				"numFrames": currentState.numFrames,
				"x": x,
				"y": y,
				"z": z,
				"rotation": rotation,
				"h_flip": h_flip,
				"dontFlip": dontFlip,
				'speed': speed,
				'ySpeed': ySpeed,
				'animation_name': currentState.stateName,
				"width": width,
				"height": height,
				'loops': currentState.loops,
				'loopDelay': currentState.loopDelay,
				"facingRight": facingRight,
				"actions": encode(actions)
			});

		if (username != null) {
			// Customize bubble text for player
			entity['bubbleText'] = personalBubbles[username] ?? bubbleText;
		}

		return entity;
	}

	Future<bool> rename({WebSocket userSocket, String email}) async {
		final int NAME_LEN_LIMIT = 10;

		if (!renameable) {
			return false;
		}

		Function renameCallback = (String ref, String name) {
			Map<String, dynamic> data = JSON.decode(ref);

			if (this.id != data['id']) {
				return;
			}

			if (name.length > NAME_LEN_LIMIT) {
				name = name.substring(0, NAME_LEN_LIMIT);
			}

			this.nameOverride = name;
		};

		promptString('Choose a name', userSocket, JSON.encode({'id': id, 'email': email}), renameCallback, charLimit: NAME_LEN_LIMIT);
		return true;
	}

	@override
	void say([String message, String toUsername, Map<String, Function> buttons]) {
		message = (message ?? '').trim();

		if (buttons == null || buttons.length == 0) {
			// No interaction needed, use normal bubble
			message = (message ?? '').trim();

			DateTime now = new DateTime.now();
			if (sayTimeout == null || sayTimeout.compareTo(now) < 0) {
				if (toUsername == null) {
					bubbleText = message;
				} else {
					personalBubbles[toUsername] = message;
				}

				int timeToLive = message.length * 30 + 3000; // Minimum 3s plus 0.3s per character
				if (timeToLive > 10000) {
					// Messages over 10s will only display for 10s
					timeToLive = 10000;
				}

				Duration messageDuration = new Duration(milliseconds: timeToLive);
				sayTimeout = now.add(messageDuration);

				new Timer(messageDuration, () {
					if (toUsername == null) {
						bubbleText = null;
					} else {
						personalBubbles[toUsername] = null;
					}
					resetGains();
				});
			}
		} else {
			/// Message format:
			/// message|||id1,text1|id2,text2
			message += '|||';

			// Add buttons to message
			buttons.forEach((String name, Function callback) {
				int id = rand.nextInt(999999);
				message += '$id,$name|';

				// Register handler
				pendingBubbleCallbacks[id] = () {
					// Call callback
					callback();

					// Close bubble
					if (toUsername == null) {
						bubbleText = null;
					} else {
						personalBubbles[toUsername] = null;
					}
					resetGains();

					// Remove handler
					pendingBubbleCallbacks.remove(id);
				};
			});

			// Remove trailing pipes
			if (message.endsWith('|')) {
				message = message.substring(0, message.length - 1);
			}

			// Send buttons to the client and wait for a response
			if (toUsername == null) {
				bubbleText = message;
			} else {
				personalBubbles[toUsername] = message;
			}
		}
	}
}