part of coUserver;

class StreetSpiritGroddle extends NPC
{
	StreetSpiritGroddle(String id, int x, int y) : super(id,x,y)
	{
		actionTime = 0;
		actions..add({"action":"buy",
					  "timeRequired":actionTime,
					  "enabled":true,
        			  "actionWord":""})
			   ..add({"action":"sell",
 					  "timeRequired":actionTime,
 					  "enabled":true,
         			  "actionWord":""});

		type = "Street Spirit Groddle";
		speed = 0;

		//has 19 animation frames but I put one because this is it's open animation and it looks weird to loop
		states = {
		          "still":new Spritesheet("still",'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png',980,300,98,150,1,false),
		          "open":new Spritesheet("open",'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png',980,300,98,150,19,false)
				};
		currentState = states['still'];
	}

	void update()
	{

	}

	void buy({WebSocket userSocket, String username})
	{
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		userSocket.add(JSON.encode(map));
	}

	void sell({WebSocket userSocket, String username})
	{
		//prepare the buy window at the same time
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		map['openWindow'] = 'vendorSell';
		userSocket.add(JSON.encode(map));
	}

	void buyItem({WebSocket userSocket, String itemName, int num, String username})
	{
		StatBuffer.incrementStat("itemsBoughtFromVendors", num);
		ClassMirror classMirror = findClassMirror(itemName.replaceAll(" ", ""));
        Item item = classMirror.newInstance(new Symbol(""), []).reflectee;
		addItemToUser(userSocket,username,item.getMap(),num,id);
	}

	void sellItem({WebSocket userSocket, String itemName, int num, String username})
	{
		//TODO: obviously do checks to see if this can succeed
		takeItemFromUser(userSocket,username,itemName,num);
	}

	List _getItemsForSale()
	{
		List<Map> items = [];
		items.add(new Pick().getMap());
		items.add(new Shovel().getMap());
		items.add(new HighClassHoe().getMap());
		items.add(new FancyPick().getMap());
		items.add(new Bean().getMap());
		items.add(new Cherry().getMap());

		return items;
	}
}