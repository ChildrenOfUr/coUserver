part of coUserver;

abstract class Item
{
	String iconUrl, spriteUrl, name, description;
	int price, stacksTo, iconNum = 4;
	Map<String,String> actions = {};
	
	Map getMap()
	{
		return {"iconUrl":iconUrl,
				"spriteUrl":spriteUrl,
				"name":name,
				"description":description,
				"price":price,
				"stacksTo":stacksTo,
				"iconNum":iconNum};
	}
}