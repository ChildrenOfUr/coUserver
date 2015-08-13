part of coUserver;

@app.Group("/recipes")
class Recipes {
	// Items are initialized in street_update_handler.dart after all of the items are loaded
	static List<Map> recipes = [];

	@app.Route("/list")
	String listRecipes(@app.QueryParam("email") String email, @app.QueryParam("tool") String tool, @app.QueryParam("token") String token) {
		if (token != redstoneToken) {
			return "Invalid token";
		}

		List<Map> toolRecipes = [];
		recipes.forEach((Map recipe) {

			if ((tool == "" || tool == null) || tool == items[recipe["tool"]].getMap()["name"]) {

				// Define a returned recipe
				Map toolRecipe = new Map()
					..["id"] = recipe["id"]
					..["tool"] = recipe["tool"]
					..["input"] = []
					..["output_map"] = items[recipe["output"]].getMap()
					..["output_amt"] = recipe["output_amt"]
					..["time"] = recipe["time"];

				// Energy used to make it
				if (recipe["energy"] != null) {
					toolRecipe["energy"] = recipe["energy"];
				} else {
					toolRecipe["energy"] = 0;
				}

				// iMG gained from making it
				if (recipe["img"] != null) {
					toolRecipe["img"] = recipe["img"];
				} else {
					toolRecipe["img"] = 0;
				}

				// Provide user-specific data if an email is provided
				if (email != null && email != "") {

					// For every item it requires...
					// TODO: wait for this forEach to finish looping before moving on ("moving on" => anything after "End input items loop" below)
					(recipe["input"] as Map<String, int>).forEach((String itemType, int qty) {

						// Get the item data
						Map itemMap = items[itemType].getMap();

						// Compare against the user's inventory
						getUserInventory(email).then((Inventory inventory) {

							// Figure out how many they have

							List<int> itemMax = [];
							int userHas = 0;

							inventory.getItems().forEach((Map item) {
								if (item['itemType'] == itemType) {
									userHas++;
								}
							});

							// Add user inventory data to the item data
							itemMap.addAll(({
								"userHas": userHas,
								"qtyReq": qty
							}));

							// Add item data to the recipe input data
							(toolRecipe["input"] as List<Map>).add(itemMap);

							// Find out how many of the recipe they can make

							if (userHas > qty) {
								itemMax.add((userHas / qty).floor());
							} else {
								itemMax.add(0);
							}

							itemMax.sort();

							if (itemMax.length > 0) {
								toolRecipe["canMake"] = itemMax.first;
							} else {
								toolRecipe["canMake"] = 0;
							}

						}); // End inventory .then()

					}); // End input items loop

				} // End user-specific data

				toolRecipes.add(toolRecipe);

			} // End tool recipe filter

		}); // End recipes loop

		return JSON.encode(toolRecipes);
	}

	@app.Route("/make")
	Future makeRecipe(@app.QueryParam("token") String token, @app.QueryParam("id") String id, @app.QueryParam("email") String email, @app.QueryParam("username") String username) async {

		if (token != redstoneToken) {
			return false;
		}

		WebSocket ws = PlayerUpdateHandler.users[username].webSocket;

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
			if (!await takeItemFromUser(ws, email, recipe["output"], qty)) {
				// If they didn't have a required item, they're not making a smoothie
				return false;
			}
		});

		// Take away energy
		if (!await Item.trySetMetabolics(email, energy: recipe["energy"])) {
			// If they don't have enough energy, they're not frying an egg
			return false;
		}

		new Timer(new Duration(seconds: recipe["time"]), () {
			// Add the item after we finish "making" one
			addItemToUser(ws, email, items[recipe["output"]].getMap(), 1, recipe["tool"]);
			// Award iMG
			Item.trySetMetabolics(email, img: recipe["img"]);
			return true;
		});
	}
}