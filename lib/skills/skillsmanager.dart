library skills;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/street_update_handler.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';
import 'package:path/path.dart' as path;

part 'skill.dart';
part 'playerskill.dart';

@app.Group("/skills")
class SkillManager extends Object {
	/// String used for querying for a specific skills_json cell
	/// Will return a length-1 list of rows from metabolics with only the skills_json column
	static final String CELL_QUERY = "SELECT skills_json FROM metabolics AS m"
		" JOIN users AS u ON m.user_id = u.id"
		" WHERE u.email = @email";

	/// All loaded skills...do not edit after initial load!
	static Map<String, Skill> SKILL_DATA = new Map();

	/// Load status
	static bool get loaded => _loading.isCompleted;
	static final Completer _loading = new Completer();

	/// Read skills from JSON file
	static void loadSkills() {
		String directory;
		//this happens when running unit tests
		if(Platform.script.data != null) {
			directory = Directory.current.path;
		} else {
			directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
		}

		directory = directory.replaceAll('coUserver/test','coUserver');

		JSON.decode(
			new File(path.join(directory, 'lib', 'skills', 'skillsdata.json'))
				.readAsStringSync()
		).forEach((String id, Map data) {
			SKILL_DATA[id] = new Skill.fromMap(data, id);;
		});

		_loading.complete();
	}

	/// Add points to a player's skill
	static Future<bool> learn(String skillId, String email, [int newPoints = 1]) async {
		// Get existing skill or add if new
		PlayerSkill skill = await PlayerSkill.find(skillId, email);
		if (skill.points == 0) {
			toast(
				"You've started learning ${skill.name}!",
				StreetUpdateHandler.userSockets[email],
				onClick: "imgmenu"
			);
		}

		// Save to database
		Map success = await skill.addPoints(newPoints);

		if (success["level_up"]) {
			toast(
				"Your ${skill.name} skill is now at level ${skill.level}!",
				StreetUpdateHandler.userSockets[email],
				onClick: "imgmenu"
			);
		}

		return success["writing"];
	}

	/// Get a player's level of a certain skil
	static Future<int> getLevel(String skillId, String email) async {
		PlayerSkill skill = await PlayerSkill.find(skillId, email);
		return skill?.level ?? 0;
	}

	/// Get all skills data for a user
	static Future<List<Map<String, dynamic>>> getPlayerSkills({String email, String username}) async {
		if (email == null && username != null) {
			email = await User.getEmailFromUsername(username);
		} else if (email == null && username == null) {
			return null;
		}

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get data from database
			Map<String, int> playerSkillsData = JSON.decode(
				(await dbConn.query(CELL_QUERY, Metabolics, {"email": email})).first.skills_json
			);

			// Fill in skill information
			List<Map<String, dynamic>> playerSkillsList = new List();
			playerSkillsData.forEach((String id, int points) {
				playerSkillsList.add(new PlayerSkill(Skill.find(id), email, points).toMap());
			});

			return playerSkillsList;
		} catch (e) {
			log("Error getting skill list for email $email: $e");
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// API access to [getPlayerSkills] by email
	@app.Route("/get/:email")
	Future<List<Map<String, dynamic>>> getPlayerSkillsRoute(String email) async {
		return await getPlayerSkills(email: email);
	}

	/// API access to [getPlayerSkills] by username
	@app.Route("/getByUsername/:username")
	Future<List<Map<String, dynamic>>> getPlayerSkillsUsernameRoute(String username) async {
		return await getPlayerSkills(username: username);
	}

	List<Map<String, dynamic>> cachedData;
	@app.Route("/list")
	List<Map<String, dynamic>> allSkills(@app.QueryParam("token") String token) {
		if (token != redstoneToken) {
			return [{"error": "true"}, {"token": "invalid"}];
		}

		if (cachedData != null) {
			return cachedData;
		} else {
			List<Map<String, dynamic>> result = new List();
			SkillManager.SKILL_DATA.values.forEach((Skill skill) {
				result.add(skill.toMap());
			});
			cachedData = result;
			return result;
		}
	}
}