part of entity;

class Auctioneer extends NPC {
	Auctioneer(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		actionTime = 0;
		actions.add(
			new Action.withName('Talk To')
		);

		type = "Auctioneer";
		speed = 0;

		states = {
			"idle":new Spritesheet("idle", 'https://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_idle_png_1354840068.png', 935, 2002, 187, 91, 109, true, loopDelay:5000),
			"talk":new Spritesheet("talk", 'https://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_talk_png_1354840071.png', 935, 1365, 187, 91, 72, false),
			"walk":new Spritesheet("walk", 'https://childrenofur.com/assets/entityImages/npc_rare_item_vendor__x1_walk_png_1354840072.png', 748, 364, 187, 91, 16, true)
		};
		setState('idle');
	}

	void update({bool simulateTick: false}) {

	}

	void talkTo({WebSocket userSocket, String email}) {
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		userSocket.add(JSON.encode(map));
	}
}