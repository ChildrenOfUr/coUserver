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
					..["time"] = recipe["time"];

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

				List<int> itemMax = [];
				(recipe["input"] as Map<String, int>).forEach((String itemType, int qty) {
					Map itemMap = items[itemType].getMap();
					int userHas = (new Random().nextInt(20)); // TODO: check against inventory provided by "email"
					itemMap.addAll(({
						"userHas": userHas,
						"qtyReq": qty
					}));
					(toolRecipe["input"] as List<Map>).add(itemMap);

					if (userHas > qty) {
						itemMax.add((userHas / qty).floor());
					} else {
						itemMax.add(0);
					}
				});

				itemMax.sort();
				toolRecipe["canMake"] = itemMax.first;

				toolRecipes.add(toolRecipe);
			}
		});
		return await JSON.encode(toolRecipes);
	}

	@app.Route("/make")
	Future makeRecipe(@app.QueryParam("id") String id, @app.QueryParam("email") String email) async {

		print("making $id for $email");

		// Get the recipe info
		List<Map> rList = recipes.where((Map recipe) => recipe["id"] == id).toList();
		Map recipe;
		if (rList.length != 1) {
			return false;
		} else {
			recipe = rList.first;
		}

		// Take all of the items
		(recipe["input"] as Map<String, int>).forEach((String itemType, int qty) async {
			if (!await takeItemFromUser(null, email, recipe["output"], qty)) {
				// If they didn't have a required item, they're not making a smoothie
				return false;
			}
		});

		new Timer(new Duration(seconds: recipe["time"]), () {
			// Add the item after we finish "making" one
			addItemToUser(null, email, items[recipe["output"]].getMap(), 1, recipe["tool"]);
			return true;
		});
	}

	//TODO: get the user's websocket and put it in place of null above (2x)
}