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

	void buy({WebSocket userSocket, String email})
	{
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		userSocket.add(JSON.encode(map));
	}

	void sell({WebSocket userSocket, String email})
	{
		//prepare the buy window at the same time
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		map['openWindow'] = 'vendorSell';
		userSocket.add(JSON.encode(map));
	}

	buyItem({WebSocket userSocket, String itemName, int num, String email}) async
	{
		StatBuffer.incrementStat("itemsBoughtFromVendors", num);
        Item item = items[itemName];

        Metabolics m = await getMetabolics(email:email);
        if(m.currants >= item.price*num)
        {
        	m.currants -= item.price*num;
        	setMetabolics(m);
			addItemToUser(userSocket,email,item.getMap(),num,id);
        }
	}

	sellItem({WebSocket userSocket, String itemName, int num, String email}) async
	{
		//TODO: obviously do checks to see if this can succeed
		Inventory inventory = await getUserInventory(email);
		int count = 0;
		inventory.getItems().forEach((Map slot)
		{
			if(slot['name'] == itemName)
				count++;
		});
		if(count >= num)
		{
			Item item = items[itemName];

			Metabolics m = await getMetabolics(email:email);
			m.currants += (item.price*num*.7)~/1;
			setMetabolics(m);


			takeItemFromUser(userSocket,email,itemName,num);
		}
	}

	List _getItemsForSale()
	{
		List<Map> saleItems = [];
		saleItems.add(items['Pick'].getMap());
		saleItems.add(items['Shovel'].getMap());
		saleItems.add(items['High Class Hoe'].getMap());
		saleItems.add(items['Fancy Pick'].getMap());
		saleItems.add(items['Bean'].getMap());
		saleItems.add(items['Cherry'].getMap());

		return saleItems;
	}
}