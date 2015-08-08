part of coUserver;

@app.Group("/recipes")
class Recipes {
    // Items are initialized in street_update_handler.dart after all of the items are loaded
    static List<Map> recipes = [];
    
	@app.Route("/list")
	Future<String> listRecipes(@app.QueryParam("tool") String tool) {
	    List<Map> toolRecipes = [];
	        recipes.forEach((Map recipe) {
	        if ((tool == "" || tool == "null") || tool == recipe["tool"]) {
    		    Map toolRecipe = new Map()
    		      ..["id"] = recipe["id"]
    		      ..["tool"] = recipe["tool"]
    		      ..["input"] = recipe["input"]
    		      ..["output"] = recipe["output"]
    		      ..["output_amt"] = recipe["output_amt"]
    		      ..["time"] = recipe["time"]
    		      ..["image"] = items[recipe["output"]].getMap()["iconUrl"];
    		      
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
    		      
    		    toolRecipes.add(toolRecipe);
	           }
    		});
		return JSON.encode(toolRecipes);
	}
	
	@app.Route("/make")
	Future<String> makeRecipe(@app.QueryParam("id") String id) {
	    //TODO: do the action
	    return JSON.encode(recipes.where((Map recipe) => recipe["id"] == id).toList());
	}
}