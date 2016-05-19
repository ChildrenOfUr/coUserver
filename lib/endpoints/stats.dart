library stats;

import 'dart:async';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:redstone_mapper_pg/manager.dart';

class StatManager {
	static String _statToString(Stat stat) => stat.toString().split('.')[1];

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
		} catch (e) {
			log('Error reading stat $statName for user $email: $e');
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// Increments stat `stat` for user with email `email` by `increment` (defaults to 1)
	/// Returns the new value of `stat` for the user
	static Future<int> add(String email, Stat stat, [int increment = 1]) async {
		int userId = await User.getIdFromEmail(email);
		String statName = _statToString(stat);
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = "INSERT INTO stats AS s (user_id, $statName) VALUES (@userId, @increment)"
				" ON CONFLICT (user_id) DO UPDATE SET $statName = s.$statName + @increment RETURNING *";
			Map<String, dynamic> values = {
				'increment': increment,
				'userId': userId
			};
			return (await dbConn.innerConn.query(query, values).single).toMap()[statName];
		} catch (e) {
			log('Error writing stat $statName for user $email: $e');
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
	cherries_harvested,
	chickens_squeezed,
	cocktail_shaker_uses,
	dirt_dug,
	egg_plants_petted,
	egg_plants_watered,
	eggs_harveted,
	eggs_seasoned,
	emblems_collected,
	fruit_converted,
	fruit_trees_petted,
	fruit_trees_watered,
	frying_pan_uses,
	gas_converted,
	gas_harvested,
	gas_plants_petted,
	gas_plants_watered,
	grill_uses,
	ice_scraped,
	jellisac_harvested,
	jumps,
	knife_board_uses,
	paper_harvested,
	peat_harvested,
	piggies_nibbled,
	planks_harvested,
	rocks_mined,
	sauce_pan_uses,
	shrine_donations,
	spice_harvested,
	spice_milled,
	spice_plants_petted,
	spice_plants_watered,
	steps_taken,
	wood_trees_petted,
	wood_trees_watered
}
