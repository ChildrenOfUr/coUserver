part of coUserver;

class Vendor extends NPC
{
	Vendor(String id, int x, int y) : super(id,x,y)
	{
		actions = {"buy":""};
		type = "Vendor";
		speed = 0;
		
		//has 19 animation frames but I put one because this is it's open animation and it looks weird to loop
		states = {"base":new Spritesheet("base",'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png',980,300,98,150,1,false)};
		currentState = states['base'];
	}
	
	void update()
	{
		
	}
	
	void buy({WebSocket userSocket})
	{
		Map map = {};
		map['vendorName'] = type;
		map['itemsForSale'] = _getItemsForSale();
		userSocket.add(JSON.encode(map));
	}
	
	List _getItemsForSale()
	{
		List<Map> items = [];
		items.add(new HighClassHoe().getMap());
		items.add(new Bean().getMap());
		items.add(new Cherry().getMap());
		
		return items;
	}
}