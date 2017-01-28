part of buffs;

class PlayerBuff extends Buff {
	static Map<String, List<PlayerBuff>> cache = new Map();

	static PlayerBuff getFromCache(String id, String email) {
		if (cache[email] == null) {
			return null;
		}

		for (PlayerBuff buff in cache[email]) {
			if (buff.id == id) {
				return buff;
			}
		}

		return null;
	}

	PlayerBuff(Buff base, this.email, [dynamic remaining]) : super.fromMap(base.toMap()) {
		if (remaining == null) {
			this.remaining = length;
		} else if (remaining is Duration) {
			this.remaining = remaining;
		} else if (remaining is int) {
			this.remaining = new Duration(seconds: remaining);
		} else {
			throw new ArgumentError(
				"PlayerBuff parameter remaining must be Duration or int,"
					" but it is of type ${remaining.runtimeType}"
			);
		}

		_cache();
	}

	PlayerBuff.fromMap(Map<String, dynamic> map, [String id]) : super.fromMap(map, id) {
		email = map["player_email"];
		remaining = new Duration(seconds: map["player_remaining"]);

		_cache();
	}

	@override
	Map<String, dynamic> toMap() => super.toMap()
		..addAll({
			"player_email": email,
			"player_remaining": remaining.inSeconds
		});

	@override
	String toString() => "<Buff $id>";

	String email;
	Duration remaining;
	Timer _updateTimer;

	void _cache() {
		if (getFromCache(id, email) == null) {
			if (cache[email] == null) {
				cache[email] = new List();
			}
			cache[email].add(this);
		}
	}

	Future startUpdating() async {
		if (!indefinite) {
			// Subtract 1 second from the remaining time every second
			_updateTimer = new Timer.periodic((new Duration(seconds: 1)), (_) async {
				remaining = new Duration(seconds: remaining.inSeconds - 1);

				if (remaining.inSeconds <= 0) {
					// Buff is over
					await stopUpdating();
				} else if (remaining.inSeconds % 10 == 0) {
					// Write every 10 seconds
					await _write();
				}
			});
		}

		// Save the current status to the database
		await _write();
	}

	Future stopUpdating({bool write: true}) async {
		// Pause the counter
		_updateTimer?.cancel();

		// Save the current status to the database
		if (write) {
			await _write();
		}
	}

	Future remove() async {
		await stopUpdating(write: false);
		remaining = new Duration(milliseconds: 0);
		await _write(remove: true);
		cache.remove(this);
	}

	Future extend(Duration additional) async {
		remaining += additional;
		await _write();
		StreetUpdateHandler.userSockets[email].add(JSON.encode({
			'buff_extend': id,
			'buff_extend_secs': additional.inSeconds
		}));
	}

	Future<bool> _write({remove: false}) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get existing data
			Map<String, int> buffsData = JSON.decode(
				(await dbConn.query(BuffManager.CELL_QUERY, Metabolics, {"email": email})
			).first.buffsJson);

			// Modify
			buffsData[id] = remaining.inSeconds;
			if ((!indefinite || remove) && remaining.inSeconds <= 0) {
				buffsData.remove(id);
			}
			String newJson = JSON.encode(buffsData);

			// Write new data
			return (await (dbConn.execute(
				"UPDATE metabolics AS m SET buffs_json = @newJson"
					" FROM users AS u"
					" WHERE m.user_id = u.id"
					" AND u.email = @email",
				{"newJson": newJson, "email": email}
			)) == 1);
		} catch (e, st) {
			Log.error('Error setting buff $id for <email=$email>', e, st);
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}
