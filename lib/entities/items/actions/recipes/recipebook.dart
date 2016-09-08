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
		Map<String, int> skillCache = {};
		await Future.forEach(recipes, (Recipe recipe) async {
			bool skillTooLow = false;

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

					// For every skill it requires...
					if (recipe.skills != null) {
						await Future.forEach(recipe.skills.keys, (String skillId) async {
							// Already missing a skill, skip checking the rest
							if (skillTooLow) {
								return;
							}

							// Skil skills that aren't possible to get in the game
							if (SkillManager.SKILL_DATA[skillId] == null) {
								return;
							}

							// Check player's skill level
							int level = recipe.skills[skillId];
							int playerLevel = skillCache[skillId] ?? await SkillManager.getLevel(skillId, email);
							skillCache[skillId] = playerLevel;
							if (Skill.find(skillId) != null && playerLevel < level) {
								// Player's skill level is too low
								skillTooLow = true;
							}
						});
					}
				}
				// End user-specific data

				if (!skillTooLow) {
					toolRecipes.add(toolRecipe);
				}

			}
			// End tool recipe filter

		}); // End recipes loop

		return JSON.encode(toolRecipes);
	}

	// Returned string is displayed as "You had to stop using your {tool} because {reason}
	// in the client. Returning "OK" will not display a message.
	@app.Route("/make")
	Future makeRecipe(@app.QueryParam("token") String token,
		@app.QueryParam("id") String id,
		@app.QueryParam("email") String email,
		@app.QueryParam("username") String username) async {

		Log.verbose('<username=$username> is making <id=$id>');

		if (token != redstoneToken) {
			Log.verbose('<username=$username> has an unauthorized client');
			return "the client is unauthorized";
		}

		// Stop if the tool breaks
		if (!(await InventoryV2.hasUnbrokenItem(email, findRecipe(id).tool, 1))) {
			Log.verbose('<username=$username> just broke their <tool=${findRecipe(id).tool}>');
			return "it broke";
		}

		// Get the recipe info
		Recipe recipe;
		List<Recipe> rList = recipes.where((Recipe recipe) => recipe.id == id).toList();
		if (rList.length != 1) {
			Log.verbose('<username=$username> tried to make nonexistent recipe <id=$id>');
			return "the recipe is missing";
		} else {
			recipe = rList.first;
		}

		Log.verbose('recipe makes ${recipe.output_amt} ${recipe.output}');

		if (items[recipe.tool].durability != null) {
			//take away tool durability
			bool durabilitySuccess = await InventoryV2.decreaseDurability(email, recipe.tool);
			if (!durabilitySuccess) {
				Log.verbose('<username=$username> is missing their <recipe.tool=${recipe.tool}>');
				return "it's missing";
			}
		}

		// Take away energy
		bool takeEnergySuccess = await trySetMetabolics(email, energy: recipe.energy);
		if (!takeEnergySuccess) {
			// If they don't have enough energy, they're not frying an egg
			Log.verbose('<username=$username> ran out of energy');
			return "you are out of energy";
		}

		String missingItem = null;
		// Test all of the items
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
		});

		if (missingItem != null) {
			Log.verbose('<username=$username> ran out of $missingItem');
			return "you ran out of ${missingItem}s";
		}

		// Take all of the items
		await Future.forEach(recipe.input.keys, (String itemType) async {
			// Remove the item
			int qty = recipe.input[itemType];
			int got = (await InventoryV2.takeAnyItemsFromUser(email, itemType, qty));
			if (got != qty) {
				// If they didn't have a required item, they're not making a smoothie
				Log.verbose('<username=$username> threw an error because an item ran out');
				throw "Not enough $itemType. Took $got but wanted $qty";
			}
		});

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
			StatAchvManager.update(email, recipe.tool, recipe.output);
		});

		return "OK";
	}
}
