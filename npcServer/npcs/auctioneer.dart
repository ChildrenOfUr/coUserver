part of coUserver;

class Auctioneer extends NPC
{
	Auctioneer(String id, int x, int y) : super(id,x,y)
	{
		actionTime = 0;
		actions.add({"action":"view",
					 "timeRequired":actionTime,
					 "enabled":true,
        			 "actionWord":""});

		type = "Auctioneer";
		speed = 0;

		states = {
		          "idle":new Spritesheet("idle",'http://c2.glitch.bz/items/2012-12-06/npc_rare_item_vendor__x1_idle_png_1354840068.png',935,2002,187,91,109,true,loopDelay:5000)
		         };
		currentState = states['idle'];
	}

	void update()
	{

	}

	void view({WebSocket userSocket, String username})
	{
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		userSocket.add(JSON.encode(map));
	}
}