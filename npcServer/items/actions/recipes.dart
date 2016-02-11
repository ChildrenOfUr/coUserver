part of coUserver;

class Recipe {
	@Field() String id;
	@Field() String tool;
	@Field() Map<String, int> input;
	@Field() String output;
	@Field() int output_amt;
	@Field() int time;
	@Field() int energy = 0;
	@Field() int img = 0;

	// Items are initialized in street_update_handler.dart after all of the items are loaded
	Recipe();

	toString() {
		return "Recipe to make ${output_amt} x $output with $tool using ${input.toString()} taking $time seconds";
	}

	static Future useItem(Map map, WebSocket userSocket, String email) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		userSocket.add(JSON.encode({
			"useItem": itemInSlot.itemType,
			"useItemName": itemInSlot.name
		}));
	}
}

@app.Group("/recipes")
class RecipeBook extends Object with MetabolicsChange {
	static List<Recipe> recipes = [];

	// Client Communication

	@app.Route("/list")
	Future<String> listRecipes(@app.QueryParam("email") String email, @app.QueryParam("tool") String tool, @app.QueryParam("token") String token) async {
		if (token != redstoneToken) {
			return "Invalid token";
		}

		List<Map> toolRecipes = [];
		await Future.forEach(recipes, (Recipe recipe) async {

			// If the recipe is made with the requested tool (if requested)
			if ((tool == "" || tool == null) || tool == items[recipe.tool].itemType) {

				// Define a returned recipe
				Map toolRecipe = new Map()
					..["id"] = recipe.id
					..["tool"] = recipe.tool
					..["input"] = []
					..["output_map"] = items[recipe.output].getMap()
					..["output_amt"] = recipe.output_amt
					..["time"] = recipe.time
					..["energy"] = recipe.energy
					..["img"] = recipe.img;

				// Provide user-specific data if an email is provided
				if (email != null && email != "") {

					List<int> itemMax = [];

					// For every item it requires...
					await Future.forEach(recipe.input.keys, (String itemType) async {
						int qty = recipe.input[itemType];

						// Get the item data to send
						Map itemMap = items[itemType].getMap();

						// Compare against the user's inventory
						InventoryV2 inv = await getInventory(email);

						// Figure out how many they have
						int userHas = inv.countItem(itemType);

						// Add user inventory data to the item data
						itemMap.addAll(({
							"userHas": userHas,
							"qtyReq": qty
						}));

						// Add item data to the recipe input data
						(toolRecipe["input"] as List<Map>).add(itemMap);

						// Find out how many of the recipe they can make

						if (userHas >= qty) {
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

					});
					// End input items loop

				}
				// End user-specific data

				toolRecipes.add(toolRecipe);

			}
			// End tool recipe filter

		}); // End recipes loop

		return JSON.encode(toolRecipes);
	}

	@app.Route("/make")
	Future makeRecipe(@app.QueryParam("token") String token,
	                  @app.QueryParam("id") String id,
	                  @app.QueryParam("email") String email,
	                  @app.QueryParam("username") String username) async {

		if (token != redstoneToken) {
			return false;
		}

		// Get the recipe info
		Recipe recipe;
		List<Recipe> rList = recipes.where((Recipe recipe) => recipe.id == id).toList();
		if (rList.length != 1) {
			return false;
		} else {
			recipe = rList.first;
		}

		// Take away energy
		bool takeEnergySuccess = await trySetMetabolics(email, energy: recipe.energy);
		if (!takeEnergySuccess) {
			// If they don't have enough energy, they're not frying an egg
			return false;
		}

		// Take all of the items
		Future.forEach(recipe.input.keys, (String itemType) async {
			int qty = recipe.input[itemType];
			int got = (await InventoryV2.takeAnyItemsFromUser(email, itemType, qty));
			if (got != qty) {
				// If they didn't have a required item, they're not making a smoothie
				throw "Not enough itemType. Took $got but wanted $qty";
			}
		});

		// Wait for it to make it, then give the item
		new Timer(new Duration(seconds: recipe.time), () async {
			// Add the item after we finish "making" one
			await InventoryV2.addItemToUser(email, items[recipe.output].getMap(), 1);
			// Award iMG
			await trySetMetabolics(email, imgMin: recipe.img);

			//send possible quest event
			messageBus.publish(new RequirementProgress('makeRecipe_${recipe.output}',email));

			// Count stat for achievements
			StatAchvManager.update(email, recipe.tool);
		});

		return true;
	}
}