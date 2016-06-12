part of entity;

abstract class NPC extends Entity {
	/**
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 * */

	/// 1px x 1px transparent gif.
	/// The client will not enable interaction on this state by checking the url string,
	/// so update it in the client as well as the server if you change it.
	static final Spritesheet TRANSPARENT_SPRITE = new Spritesheet('_hidden',
		'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
		1, 1, 1, 1, 1, true);

	static int updateFps = 20;

	String id, type, streetName;
	int x,
		y,
		speed = 0,
		ySpeed = 0,
		yAccel = -2400,
		previousX,
		previousY;
	bool facingRight = true, grounded = false;
	MutableRectangle _collisionsRect;

	NPC(this.id, this.x, this.y, this.streetName) {
		respawn = new DateTime.now();
	}

	void restoreState(Map<String, String> metadata) {
		if (metadata['facingRight'] == 'false') {
			facingRight = false;
		}
	}

	Map<String,String> getPersistMetadata() {
		return {'facingRight': facingRight.toString()};
	}

	int get width => currentState.frameWidth;

	int get height => currentState.frameHeight;

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

	void update() {
		previousX = x;
		previousY = y;
	}

	void defaultWallAction(Wall wall) {
		facingRight = !facingRight;

		if(wall == null) {
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
		x += speed * (facingRight ? 1 : -1) ~/ NPC.updateFps;
	}

	void defaultYAction() {
		ySpeed -= yAccel ~/ NPC.updateFps;
		y += ySpeed ~/ NPC.updateFps;
		y = street.getYFromGround(x, previousY, width, height);
	}

	///Move the entity 'forward' according to which direction they are facing
	///and based on the platform lines available on the street
	///
	///If the entity should perform actions other than the defaults at certain
	///conditions (such as walls and ledges etc.) then pass those as function  pointers
	///else the default action will be taken
	void moveXY({Function xAction, Function yAction, Function wallAction, Function ledgeAction}) {
		if(previousY == null) {
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

	Map getMap() => super.getMap()
		..addAll({
			"id": id,
			"url": currentState.url,
			"type": type,
			"numRows": currentState.numRows,
			"numColumns": currentState.numColumns,
			"numFrames": currentState.numFrames,
			"x": x,
			"y": y,
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
}
