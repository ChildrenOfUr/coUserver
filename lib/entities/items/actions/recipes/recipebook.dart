part of recipes;

@app.Group("/recipes")
class RecipeBook extends Object with MetabolicsChange {
	static List<Recipe> recipes = [];

	static Recipe findRecipe(String id) {
		return recipes.singleWhere((Recipe recipe) {
			return recipe.id == id;
		});
	}

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

					// For every item it requires...
					await Future.forEach(recipe.input.keys, (String itemType) async {
						int qty = recipe.input[itemType];

						// Get the item data to send
						Map itemMap = items[itemType].getMap();
						itemMap['qtyReq'] = qty;

						// Add item data to the recipe input data
						(toolRecipe["input"] as List<Map>).add(itemMap);

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

	// Returned string is displayed as "You had to stop using your {tool} because {reason}
	@app.Route("/make")
	Future makeRecipe(@app.QueryParam("token") String token,
		@app.QueryParam("id") String id,
		@app.QueryParam("email") String email,
		@app.QueryParam("username") String username) async {

		if (token != redstoneToken) {
			return "the client is unauthorized";
		}

		// Stop if the tool breaks
		if (!(await InventoryV2.hasUnbrokenItem(email, findRecipe(id).tool, 1))) {
			return "it broke";
		}

		// Get the recipe info
		Recipe recipe;
		List<Recipe> rList = recipes.where((Recipe recipe) => recipe.id == id).toList();
		if (rList.length != 1) {
			return "the recipe is missing";
		} else {
			recipe = rList.first;
		}

		if (items[recipe.tool].durability != null) {
			//take away tool durability
			bool durabilitySuccess = await InventoryV2.decreaseDurability(email, recipe.tool);
			if (!durabilitySuccess) {
				return "it's missing";
			}
		}

		// Take away energy
		bool takeEnergySuccess = await trySetMetabolics(email, energy: recipe.energy);
		if (!takeEnergySuccess) {
			// If they don't have enough energy, they're not frying an egg
			return "you are out of energy";
		}

		// Take all of the items
		String missingItem = null;
		await Future.forEach(recipe.input.keys, (String itemType) async {
			if (missingItem != null) {
				// Can't escape the async forEach,
				// but we can save inventory calls
				return;
			}

			int qty = recipe.input[itemType];

			// Test for the item
			int gotSim = (await InventoryV2.takeAnyItemsFromUser(
				email, itemType, qty, simulate: true));
			if (gotSim < qty) {
				missingItem = items[itemType].name;
				return;
			}

			// Remove the item
			int got = (await InventoryV2.takeAnyItemsFromUser(email, itemType, qty));
			if (got != qty) {
				// If they didn't have a required item, they're not making a smoothie
				throw "Not enough $itemType. Took $got but wanted $qty";
			}
		});

		if (missingItem != null) {
			return "you ran out of ${missingItem}s";
		}

		// Wait for it to make it, then give the item
		new Timer(new Duration(seconds: recipe.time), () async {
			// Add the item after we finish "making" one
			await InventoryV2.addItemToUser(
				email, items[recipe.output].getMap(), recipe.output_amt);

			// Award iMG
			await trySetMetabolics(email, imgMin: recipe.img);

			// Send possible quest event
			messageBus.publish(new RequirementProgress('makeRecipe_${recipe.output}',email));

			// Count stat for achievements
			StatAchvManager.update(email, recipe.tool);
		});

		return "OK";
	}
}
