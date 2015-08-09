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
}