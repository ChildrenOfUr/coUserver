part of coUserver;

@app.Group("/recipes")
class Recipes {
	// Items are initialized in street_update_handler.dart after all of the items are loaded
	static List<Map> recipes = [];

	@app.Route("/list")
	Future<String> listRecipes(@app.QueryParam("email") String email, @app.QueryParam("tool") String tool) async {
		List<Map> toolRecipes = [];
		recipes.forEach((Map recipe) {
			if ((tool == "" || tool == null) || tool == items[recipe["tool"]].getMap()["name"]) {
				Map toolRecipe = new Map()
					..["id"] = recipe["id"]
					..["tool"] = recipe["tool"]
					..["input"] = []
					..["output_map"] = items[recipe["output"]].getMap()
					..["output_amt"] = recipe["output_amt"]
					..["time"] = recipe["time"]
					..["canMake"] = new Random().nextBool(); //TODO: check user inv

				if (recipe["energy"] != null) {
					toolRecipe["energy"] = recipe["energy"];
				} else {
					toolRecipe["energy"] = 0;
				}

				if (recipe["img"] != null) {
					toolRecipe["img"] = recipe["img"];
				} else {
					toolRecipe["img"] = 0;
				}

				(recipe["input"] as Map<String, int>).forEach((String itemType, int qty) {
					Map itemMap = items[itemType].getMap();
					itemMap.addAll(({
						"userHas": (new Random().nextBool()), // TODO: check against inventory provided by "email"
						"qtyReq": qty
					}));
					(toolRecipe["input"] as List<Map>).add(itemMap);
				});

				toolRecipes.add(toolRecipe);
			}
		});
		return await JSON.encode(toolRecipes);
	}

	@app.Route("/make")
	Future<String> makeRecipe(@app.QueryParam("id") String id) async {
		//TODO: do the action
		return await JSON.encode(recipes.where((Map recipe) => recipe["id"] == id).toList());
	}

	@app.Route("/getAnimUrl")
	String getAnimUrl(@app.QueryParam("tool") String itemType) {
		switch (itemType) {
			case "awesome_pot":
				return "http://c2.glitch.bz/items/2012-12-10/awesome_pot__x1_tool_animation_scale5_quality10_loop_1355189258.gif";
			case "bean_seasoner":
				return "http://c2.glitch.bz/items/2012-12-06/bean_seasoner__x1_tool_animation_png_1354830309.png"; // TODO: make into gif
			case "blender":
				return "http://c2.glitch.bz/items/2012-12-10/blender__x1_tool_animation_scale2_5_quality10_loop_1355189919.gif";
			case "bubble_tuner":
				return "http://c2.glitch.bz/items/2012-12-10/bubble_tuner__x1_tool_animation_scale3_quality10_loop_1355189670.gif";
			case "cocktail_shaker":
				return "http://c2.glitch.bz/items/2012-12-06/cocktail_shaker__x1_tool_animation_png_1354830094.png"; //TODO: make into gif
			case "egg_seasoner":
				return "http://c2.glitch.bz/items/2012-12-06/egg_seasoner__x1_tool_animation_png_1354830313.png"; //TODO: make into gif
			case "famous_pugilist_grill":
				return "http://c2.glitch.bz/items/2012-12-10/mike_tyson_grill__x1_tool_animation_scale2_5_quality10_loop_1355198530.gif";
			case "fruit_changing_machine":
				return "http://c2.glitch.bz/items/2012-12-10/fruit_changing_machine__x1_tool_animation_scale3_quality10_loop_1355195459.gif";
			case "frying_pan":
				return "http://c2.glitch.bz/items/2012-12-10/frying_pan__x1_tool_animation_scale3_quality10_loop_1355195661.gif";
			case "gassifier":
				return "http://c2.glitch.bz/items/2012-12-10/gassifier__x1_tool_animation_scale3_quality10_loop_1355196632.gif";
			case "knife_and_board":
				return "http://c2.glitch.bz/items/2012-11-18/knife_and_board__x1_tool_animation_quality10_loop_1353299118.gif";
			case "loomer":
				return "http://c2.glitch.bz/items/2012-12-10/loomer__x1_tool_animation_scale2_5_quality10_loop_1355198373.gif";
			case "saucepan":
				return "http://c2.glitch.bz/items/2012-12-13/saucepan__x1_tool_animation_quality10_loop_1355432134.gif";
			case "spice_mill":
				return "http://c2.glitch.bz/items/2012-12-13/spice_mill__x1_tool_animation_quality10_loop_1355432978.gif";
		}
	}
}