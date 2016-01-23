part of coUserver;

class StatCollection {
	static Future<StatCollection> find({int userId, String email}) async {
		PostgreSql dbConn = await dbManager.getConnection();

		Future<List<StatCollection>> _query(int userId) async {
			List<StatCollection> results = await dbConn.query(
				"SELECT * FROM stats WHERE user_id = @user_id",
				StatCollection, {"user_id": userId});
			return results;
		}

		try {
			List<StatCollection> results = (await _query(userId)) ?? [];
			if (results.length > 0) {
				return results.first;
			} else {
				if ((await dbConn.execute(
					"INSERT INTO stats (user_id) VALUES (@user_id)",
					{"user_id": userId})) == 1) {
					return (await _query(userId)).first;
				} else {
					throw new Exception();
				}
			}
		} catch (e, st) {
			log("Error getting stats for user ${userId.toString()}: $e");
			print(st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	Future<bool> write() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			return (
				(await dbConn.execute(
					"UPDATE stats SET "
						+ "awesome_pot_uses = @awesome_pot_uses,"
						+ "barnacles_scraped = @barnacles_scraped,"
						+ "bean_trees_petted = @bean_trees_petted,"
						+ "bean_trees_watered = @bean_trees_watered,"
						+ "beans_harvested = @beans_harvested,"
						+ "beans_seasoned = @beans_seasoned,"
						+ "blender_uses = @blender_uses,"
						+ "bubble_trees_petted = @bubble_trees_petted,"
						+ "bubble_trees_watered = @bubble_trees_watered,"
						+ "bubbles_harvested = @bubbles_harvested,"
						+ "bubbles_transformed = @bubbles_transformed,"
						+ "butterflies_massaged = @butterflies_massaged,"
						+ "cherries_harvested = @cherries_harvested,"
						+ "chickens_squeezed = @chickens_squeezed,"
						+ "cocktail_shaker_uses = @cocktail_shaker_uses,"
						+ "dirt_dug = @dirt_dug,"
						+ "egg_plants_petted = @egg_plants_petted,"
						+ "egg_plants_watered = @egg_plants_watered,"
						+ "eggs_harveted = @eggs_harveted,"
						+ "eggs_seasoned = @eggs_seasoned,"
						+ "emblems_collected = @emblems_collected,"
						+ "fruit_converted = @fruit_converted,"
						+ "fruit_trees_petted = @fruit_trees_petted,"
						+ "fruit_trees_watered = @fruit_trees_watered,"
						+ "frying_pan_uses = @frying_pan_uses,"
						+ "gas_converted = @gas_converted,"
						+ "gas_harvested = @gas_harvested,"
						+ "gas_plants_petted = @gas_plants_petted,"
						+ "gas_plants_watered = @gas_plants_watered,"
						+ "grill_uses = @grill_uses,"
						+ "ice_scraped = @ice_scraped,"
						+ "jellisac_harvested = @jellisac_harvested,"
						+ "jumps = @jumps,"
						+ "knife_board_uses = @knife_board_uses,"
						+ "paper_harvested = @paper_harvested,"
						+ "peat_harvested = @peat_harvested,"
						+ "piggies_nibbled = @piggies_nibbled,"
						+ "planks_harvested = @planks_harvested,"
						+ "rocks_mined = @rocks_mined,"
						+ "sauce_pan_uses = @sauce_pan_uses,"
						+ "shrine_donations = @shrine_donations,"
						+ "spice_harvested = @spice_harvested,"
						+ "spice_milled = @spice_milled,"
						+ "spice_plants_petted = @spice_plants_petted,"
						+ "spice_plants_watered = @spice_plants_watered,"
						+ "steps_taken = @steps_taken,"
						+ "wood_trees_petted = @wood_trees_petted,"
						+ "wood_trees_watered = @wood_trees_watered"
						+ " WHERE user_id = @user_id",
					{
						"awesome_pot_uses": awesome_pot_uses,
						"barnacles_scraped": barnacles_scraped,
						"bean_trees_petted": bean_trees_petted,
						"bean_trees_watered": bean_trees_watered,
						"beans_harvested": beans_harvested,
						"beans_seasoned": beans_seasoned,
						"blender_uses": blender_uses,
						"bubble_trees_petted": bubble_trees_petted,
						"bubble_trees_watered": bubble_trees_watered,
						"bubbles_harvested": bubbles_harvested,
						"bubbles_transformed": bubbles_transformed,
						"butterflies_massaged": butterflies_massaged,
						"cherries_harvested": cherries_harvested,
						"chickens_squeezed": chickens_squeezed,
						"cocktail_shaker_uses": cocktail_shaker_uses,
						"dirt_dug": dirt_dug,
						"egg_plants_petted": egg_plants_petted,
						"egg_plants_watered": egg_plants_watered,
						"eggs_harveted": eggs_harveted,
						"eggs_seasoned": eggs_seasoned,
						"emblems_collected": emblems_collected,
						"fruit_converted": fruit_converted,
						"fruit_trees_petted": fruit_trees_petted,
						"fruit_trees_watered": fruit_trees_watered,
						"frying_pan_uses": frying_pan_uses,
						"gas_converted": gas_converted,
						"gas_harvested": gas_harvested,
						"gas_plants_petted": gas_plants_petted,
						"gas_plants_watered": gas_plants_watered,
						"grill_uses": grill_uses,
						"ice_scraped": ice_scraped,
						"jellisac_harvested": jellisac_harvested,
						"jumps": jumps,
						"knife_board_uses": knife_board_uses,
						"paper_harvested": paper_harvested,
						"peat_harvested": peat_harvested,
						"piggies_nibbled": piggies_nibbled,
						"planks_harvested": planks_harvested,
						"rocks_mined": rocks_mined,
						"sauce_pan_uses": sauce_pan_uses,
						"shrine_donations": shrine_donations,
						"spice_harvested": spice_harvested,
						"spice_milled": spice_milled,
						"spice_plants_petted": spice_plants_petted,
						"spice_plants_watered": spice_plants_watered,
						"steps_taken": steps_taken,
						"wood_trees_petted": wood_trees_petted,
						"wood_trees_watered": wood_trees_watered,
						"user_id": user_id
					})
				) == 1
			);
		} catch (e) {
			log("Error writing stats for user ${user_id.toString()}: $e");
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	String get encoded => encode(this);

	@Field() int id;
	@Field() int user_id;

	@Field() int awesome_pot_uses;
	@Field() int barnacles_scraped;
	@Field() int bean_trees_petted;
	@Field() int bean_trees_watered;
	@Field() int beans_harvested;
	@Field() int beans_seasoned;
	@Field() int blender_uses;
	@Field() int bubble_trees_petted;
	@Field() int bubble_trees_watered;
	@Field() int bubbles_harvested;
	@Field() int bubbles_transformed;
	@Field() int butterflies_massaged;
	@Field() int cherries_harvested;
	@Field() int chickens_squeezed;
	@Field() int cocktail_shaker_uses;
	@Field() int dirt_dug;
	@Field() int egg_plants_petted;
	@Field() int egg_plants_watered;
	@Field() int eggs_harveted;
	@Field() int eggs_seasoned;
	@Field() int emblems_collected;
	@Field() int fruit_converted;
	@Field() int fruit_trees_petted;
	@Field() int fruit_trees_watered;
	@Field() int frying_pan_uses;
	@Field() int gas_converted;
	@Field() int gas_harvested;
	@Field() int gas_plants_petted;
	@Field() int gas_plants_watered;
	@Field() int grill_uses;
	@Field() int ice_scraped;
	@Field() int jellisac_harvested;
	@Field() int jumps;
	@Field() int knife_board_uses;
	@Field() int paper_harvested;
	@Field() int peat_harvested;
	@Field() int piggies_nibbled;
	@Field() int planks_harvested;
	@Field() int rocks_mined;
	@Field() int sauce_pan_uses;
	@Field() int shrine_donations;
	@Field() int spice_harvested;
	@Field() int spice_milled;
	@Field() int spice_plants_petted;
	@Field() int spice_plants_watered;
	@Field() int steps_taken;
	@Field() int wood_trees_petted;
	@Field() int wood_trees_watered;
}