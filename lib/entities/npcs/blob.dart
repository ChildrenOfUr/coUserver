part of entity;

class Blob extends NPC {
	static final double MAX_VEL = 50.0; // px/tick
	static final double DECCEL = 1.0; // px/tick
	static final int COLLIDE_DIST = 300; // px

	double xVel = 0.0, yVel = 0.0;

	Blob(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Blob';
		speed = 0;
		facingRight = false;

		states = {
			'blob': new Spritesheet('blob',
				'https://www.robiotic.net/hosted/pepper.png',
				149, 184, 149, 184, 1, true)
		};

		setState('blob');
	}

	@override
	void update({simulateTick: false}) {
		super.update(simulateTick: simulateTick);

		/* Collide with players */ {
			final CollisionSet collisions = getCollidingPlayers();

			if (collisions.netVertical.abs() > collisions.netHorizontal.abs()) {
				// More vertical motion
				yVel += (collisions.netVertical + 1) * 10;
			} else {
				// More horizontal motion
				xVel += (collisions.netHorizontal + 1) * 10;
			}
		}

		/* Deccelerate over time */ {
			if (xVel > 0) {
				xVel -= DECCEL;
			} else if (xVel < 0) {
				xVel += DECCEL;
			}

			if (yVel > 0) {
				yVel -= DECCEL;
			} else if (yVel < 0) {
				yVel += DECCEL;
			}
		}

		// Reverse at horizontal street bounds
		if (x <= 0 || x >= StreetUpdateHandler.streets[streetName].bounds.right) {
			xVel *= -1;
		}

		// Reverse at vertical street bounds
		if (y <= 0 || y >= StreetUpdateHandler.streets[streetName].bounds.bottom) {
			yVel *= -1;
		}

		// Sanity check
		xVel = xVel.clamp(-MAX_VEL, MAX_VEL);
		yVel = yVel.clamp(-MAX_VEL, MAX_VEL);

		// Move
		moveXY(xAction: () {
			x += xVel;
		}, yAction: () {
			y += yVel;
		}, wallAction: () {
			return;
		}, ledgeAction: () {
			return;
		});
	}

	CollisionSet getCollidingPlayers() {
		final CollisionSet collisions = new CollisionSet();
		final Point thisLoc = new Point(x, y);
		Point playerLoc;

		for (Identifier player in PlayerUpdateHandler.users.values) {
			if (player.currentStreet != streetName) {
				// Not on this street
				continue;
			}

			playerLoc = new Point(player.currentX, player.currentY);
			if (thisLoc.distanceTo(playerLoc) > COLLIDE_DIST) {
				// Too far away
				continue;
			}

			if (x > playerLoc.x) {
				collisions.left++;
			}

			if (x < playerLoc.x) {
				collisions.right++;
			}

			if (y > playerLoc.y) {
				collisions.top++;
			}

			if (y < playerLoc.y) {
				collisions.bottom++;
			}
		}

		return collisions;
	}
}

/// A count of objects colliding with this object on each side
class CollisionSet {
	int top, right, bottom, left;
	CollisionSet({this.top: 0, this.right: 0, this.bottom: 0, this.left: 0});

	/// Net vertical collisions.
	/// Negative iff more at bottom, positive iff more at top, zero iff equal.
	int get netVertical => top - bottom;

	/// Net horizontal collisions.
	/// Negative iff more at right, positive iff more at left, zero iff equal.
	int get netHorizontal => left - right;

	@override
	String toString() => 'Top: $top, Right: $right, Bottom: $bottom, Left: $left';
}
