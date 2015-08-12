part of coUserver;

class Auctioneer extends NPC {
	Auctioneer(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;
		actions.add({"action":"Talk To",
			            "timeRequired":actionTime,
			            "enabled":true,
			            "actionWord":""});

		type = "Auctioneer";
		speed = 0;

		states = {
			"idle":new Spritesheet("idle", 'http://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_idle_png_1354840068.png', 935, 2002, 187, 91, 109, true, loopDelay:5000),
			"talk":new Spritesheet("talk", 'http://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_talk_png_1354840071.png', 935, 1365, 187, 91, 72, false),
			"walk":new Spritesheet("walk", 'http://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_walk_png_1354840072.png', 748, 364, 187, 91, 16, true)
		};
		currentState = states['idle'];
	}

	void update() {

	}

	void talkTo({WebSocket userSocket, String email}) {
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		userSocket.add(JSON.encode(map));
	}
}