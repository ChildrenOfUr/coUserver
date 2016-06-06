library stats;

import 'dart:async';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';

import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';

class BufferedStat {
	Stat stat;
	int bufferedValue;
	DateTime bufferExpirey;

	BufferedStat(this.stat, this.bufferedValue, [this.bufferExpirey]) {
		bufferExpirey = new DateTime.now().add(new Duration(seconds: 10));
	}
}

@app.Group('/stats')
class StatManager {
	static String _statToString(Stat stat) => stat.toString().split('.')[1];

	static Map<String, BufferedStat> statBuffer = {};

	/// Returns the value of stat `stat` for user with email `email`
	static Future<int> get(String email, Stat stat) async {
		String statName = _statToString(stat);
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query =
				'SELECT * '
				'FROM stats '
				'JOIN users u ON u.id = user_id '
				'WHERE u.email = @email'
			;
			Map<String, dynamic> values = {
				'email': email
			};
			List rows = await dbConn.innerConn.query(query, values).toList();
			if (rows.length == 0) {
				return 0;
			} else {
				return rows.single.toMap()[statName];
			}
		} catch (e, st) {
			Log.error('Error reading stat $statName for <email=$email>', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// Returns all combined stats from all players
	static Future<Map<String, num>> getAllSums() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			List<String> sums = new List();
			for (Stat stat in Stat.values) {
				String statName = _statToString(stat);
				sums.add('SUM($statName) AS $statName');
			}

			String query = 'SELECT ${sums.join(', ')} FROM stats';
			return (await dbConn.innerConn.query(query).single).toMap();
		} catch (e, st) {
			Log.error('Error summing stats', e, st);
			return new Map();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// Returns a combined stat from all players
	static Future<num> getSum(Stat stat) async {
		String statName = _statToString(stat);
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'SELECT SUM($statName) AS $statName FROM stats';
			return (await dbConn.innerConn.query(query).single).toMap()[statName];
		} catch (e, st) {
			Log.error('Error summing stat $statName', e, st);
			return 0;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// Increments stat `stat` for user with email `email` by `increment` (defaults to 1)
	/// Returns the new value of `stat` for the user
	static Future<int> add(String email, Stat stat, {int increment: 1, bool buffer: false}) async {
		if (buffer) {
			BufferedStat bufferedStat = statBuffer[email] ?? new BufferedStat(stat, increment);
			if (bufferedStat.bufferExpirey.compareTo(new DateTime.now()) <= 0) {
				int ret = await _flushStatToDb(bufferedStat.stat, bufferedStat.bufferedValue, email);
				if (ret != null) {
					statBuffer.remove(email);
				}
				return ret;
			} else {
				bufferedStat.bufferedValue += increment;
				statBuffer[email] = bufferedStat;
				return bufferedStat.bufferedValue;
			}
		}

		return await _flushStatToDb(stat, increment, email);
	}

	static Future<int> _flushStatToDb(Stat stat, int increment, String email) async {
		int userId = await User.getIdFromEmail(email);
		String statName = _statToString(stat);
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'INSERT INTO stats'
				' AS s (user_id, $statName)'
				' VALUES (@userId, @increment)'
				' ON CONFLICT (user_id)'
				' DO UPDATE SET $statName = s.$statName + @increment'
				' RETURNING *';
			Map<String, dynamic> values = {
				'increment': increment,
				'userId': userId
			};
			return (await dbConn.innerConn.query(query, values).single).toMap()[statName];
		} catch (e, st) {
			Log.error('Error writing stat $statName', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}

enum Stat {
	awesome_pot_uses,
	barnacles_scraped,
	bean_trees_petted,
	bean_trees_watered,
	beans_harvested,
	beans_seasoned,
	blender_uses,
	bubble_trees_petted,
	bubble_trees_watered,
	bubbles_harvested,
	bubbles_transformed,
	butterflies_massaged,
	butterflies_milked,
	cherries_harvested,
	chickens_squeezed,
	cocktail_shaker_uses,
	cubimal_boxes_opened,
	cubimals_set_free,
	dirt_dug,
	egg_plants_petted,
	egg_plants_watered,
	eggs_harveted,
	eggs_seasoned,
	emblems_caressed,
	emblems_collected,
	emblems_considered,
	emblems_contemplated,
	favor_earned,
	fruit_converted,
	fruit_trees_petted,
	fruit_trees_watered,
	frying_pan_uses,
	gas_converted,
	gas_harvested,
	gas_plants_petted,
	gas_plants_watered,
	grapes_squished,
	grill_uses,
	heli_kitties_petted,
	ice_scraped,
	icons_collected,
	icons_tithed,
	icons_revered,
	icons_ruminated,
	items_dropped,
	items_picked_up,
	items_from_vendors,
	jellisac_harvested,
	jumps,
	knife_board_uses,
	paper_harvested,
	peat_harvested,
	piggies_nibbled,
	piggies_petted,
	planks_harvested,
	quoins_collected,
	rocks_mined,
	salmon_pocketed,
	sauce_pan_uses,
	shrine_donations,
	smelter_uses,
	spice_harvested,
	spice_milled,
	spice_plants_petted,
	spice_plants_watered,
	steps_taken,
	tinkertool_uses,
	wood_trees_petted,
	wood_trees_watered
}

@app.Route('/getGameStats')
Future<Map<String, num>> getGameStats() async => await StatManager.getAllSums();
