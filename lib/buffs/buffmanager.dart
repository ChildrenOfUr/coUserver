library buffs;

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:coUserver/common/util.dart";
import "package:coUserver/common/user.dart";
import "package:coUserver/endpoints/metabolics/metabolics.dart";
import "package:path/path.dart" as path;
import "package:redstone/redstone.dart" as app;
import "package:redstone_mapper_pg/manager.dart";

part "buff.dart";
part "playerbuff.dart";

@app.Group("/buffs")
class BuffManager {
	/// String used for querying for a specific buffs_json cell
	/// Will return a length-1 list of rows from metabolics with only the buffs_json column
	static final String CELL_QUERY = "SELECT buffs_json FROM metabolics AS m"
		" JOIN users AS u ON m.user_id = u.id"
		" WHERE u.email = @email";

	static Map<String, Buff> buffs = new Map();

	static bool get loaded => _loading.isCompleted;
	static final Completer _loading = new Completer();

	static void loadBuffs() {
		String directory;
		//this happens when running unit tests
		if(Platform.script.data != null) {
			directory = Directory.current.path;
		} else {
			directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
		}

		JSON.decode(
			new File(path.join(directory, "lib", "buffs", "buffdata.json"))
				.readAsStringSync()
		).forEach((String id, Map data) {
			buffs[id] = new Buff.fromMap(data, id);;
		});

		_loading.complete();
	}

	/// Give a user a buff
	static void addToUser(String buffId, String email, WebSocket userSocket) {
		print("adding to user");
		PlayerBuff newBuff = new PlayerBuff(Buff.find(buffId), email);
		userSocket.add(JSON.encode({"buff": newBuff.toMap()}));
		newBuff.startUpdating();
	}

	/// Start updating all buffs for a user (login)
	static Future startUpdatingUser(String email) async {
		if (email != null) {
			try {
				(await getPlayerBuffs(email: email)).forEach((Map<String, dynamic> buffMap) {
					PlayerBuff buff = new PlayerBuff.fromMap(buffMap);
					buff.startUpdating();
				});
			} catch(e) {
				log("Could not resume buffs for $email: $e");
			}
		}
	}

	/// Stop updating all buffs for a user (logout)
	static Future stopUpdatingUser(String email) async {
		if (email != null) {
			try {
				(await getPlayerBuffs(email: email)).forEach((Map<String, dynamic> buffMap) {
					PlayerBuff buff = new PlayerBuff.fromMap(buffMap);
					buff.stopUpdating();
				});

				PlayerBuff.cache.remove(email);
			} catch (e) {
				log("Could not pause buffs for $email: $e");
			}
		}
	}

	/// Whether a player has a buff
	static Future<bool> playerHasBuff(String buffId, String email) async {
		if (PlayerBuff.cache.containsKey(email)) {
			// Check cache
			return (PlayerBuff.getFromCache(buffId, email) != null);
		} else {
			// Check database
			List<Map<String, dynamic>> buffs = await getPlayerBuffs(email: email);
			for (Map buff in buffs) {
				if (buff["id"] == buffId) {
					return true;
				}
			}
			return false;
		}
	}

	/// Get all buffs data for a user
	static Future<List<Map<String, dynamic>>> getPlayerBuffs({String email, String username}) async {
		if (email == null && username != null) {
			email = await User.getEmailFromUsername(username);
		} else if (email == null && username == null) {
			return null;
		}

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get data from database
			Map<String, int> playerBuffsData = JSON.decode(
				(await dbConn.query(CELL_QUERY, Metabolics, {"email": email})).first.buffs_json
			);

			// Fill in buff information
			List<Map<String, dynamic>> playerBuffsList = new List();
			playerBuffsData.forEach((String id, int remaining) {
				playerBuffsList.add(
					PlayerBuff.getFromCache(id, email)?.toMap() ??
					new PlayerBuff(Buff.find(id), email, remaining).toMap()
				);
			});

			return playerBuffsList;
		} catch (e, st) {
			log("Error getting buff list for email $email: $e$st");
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// API access to [getPlayerBuffs] by email
	@app.Route("/get/:email")
	Future<List<Map<String, dynamic>>> getPlayerSkillsRoute(String email) async {
		return await getPlayerBuffs(email: email);
	}

	/// API access to [getPlayerBuffs] by username
	@app.Route("/getByUsername/:username")
	Future<List<Map<String, dynamic>>> getPlayerSkillsUsernameRoute(String username) async {
		return await getPlayerBuffs(username: username);
	}
}