part of coUserver;

class StreetSpiritGroddle extends Vendor {
	int openCount = 0;
	Clock clock = new Clock();

	StreetSpiritGroddle(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
		speed = -75;
		itemsPredefined = false;

		Map <String, Map<String, Spritesheet>> AllStates = {
			"alph": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_close_png_1354835031.png", 792, 591, 132, 197, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_idle_hold_png_1354835020.png", 924, 2561, 132, 197, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_idle_move_png_1354835036.png", 924, 3349, 132, 197, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_open_png_1354835030.png", 924, 591, 132, 197, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_open_png_1354835030.png", 924, 591, 132, 197, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_talk_png_1354835025.png", 924, 2167, 132, 197, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LeafSprout_x1_turn_png_1354835028.png", 924, 1182, 132, 197, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_close_png_1354835067.png", 792, 591, 132, 197, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_idle_hold_png_1354835055.png", 924, 2561, 132, 197, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_idle_move_png_1354835072.png", 924, 3349, 132, 197, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_open_png_1354835065.png", 924, 591, 132, 197, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_open_png_1354835065.png", 924, 591, 132, 197, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_talk_png_1354835060.png", 924, 2167, 132, 197, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LeafSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LeafSprout_x1_turn_png_1354835063.png", 924, 1182, 132, 197, 37, false)
				}
			},
			"cosma": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_close_png_1354834586.png", 882, 300, 98, 150, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_idle_hold_png_1354834580.png", 980, 1350, 98, 150, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_idle_move_png_1354834588.png", 980, 1800, 98, 150, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png", 980, 300, 98, 150, 19, false),
					"still": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png", 980, 300, 98, 150, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_talk_png_1354834582.png", 980, 1200, 98, 150, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_turn_png_1354834584.png", 980, 600, 98, 150, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_close_png_1354834609.png", 882, 300, 98, 150, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_idle_hold_png_1354834601.png", 980, 1350, 98, 150, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_idle_move_png_1354834611.png", 980, 1800, 98, 150, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_open_png_1354834608.png", 980, 300, 98, 150, 19, false),
					"still": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_open_png_1354834608.png", 980, 300, 98, 150, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_talk_png_1354834604.png", 980, 1200, 98, 150, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_turn_png_1354834606.png", 980, 600, 98, 150, 37, false)
				}
			},
			"friendly": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_close_png_1354834923.png", 672, 549, 112, 183, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_idle_hold_png_1354834913.png", 896, 2013, 112, 183, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_idle_move_png_1354834926.png", 896, 2745, 112, 183, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_open_png_1354834922.png", 784, 549, 112, 183, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_open_png_1354834922.png", 784, 549, 112, 183, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_talk_png_1354834918.png", 896, 1830, 112, 183, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1LotusTop_x1_turn_png_1354834920.png", 896, 915, 112, 183, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_close_png_1354834963.png", 672, 549, 112, 183, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_idle_hold_png_1354834943.png", 896, 2013, 112, 183, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_idle_move_png_1354834967.png", 896, 2745, 112, 183, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_open_png_1354834953.png", 784, 549, 112, 183, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_open_png_1354834953.png", 784, 549, 112, 183, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_talk_png_1354834948.png", 896, 1830, 112, 183, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1LotusBottom_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1LotusTop_x1_turn_png_1354834951.png", 896, 915, 112, 183, 37, false)
				}
			},
			"grendaline": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_close_png_1354834655.png", 918, 328, 102, 164, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_idle_hold_png_1354834647.png", 918, 1640, 102, 164, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_idle_move_png_1354834657.png", 918, 2296, 102, 164, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_open_png_1354834654.png", 714, 492, 102, 164, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_open_png_1354834654.png", 714, 492, 102, 164, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_talk_png_1354834651.png", 918, 1476, 102, 164, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_none_x1_turn_png_1354834652.png", 816, 820, 102, 164, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_close_png_1354834678.png", 918, 328, 102, 164, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_idle_hold_png_1354834671.png", 918, 1640, 102, 164, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_idle_move_png_1354834681.png", 918, 2296, 102, 164, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_open_png_1354834677.png", 714, 492, 102, 164, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_open_png_1354834677.png", 714, 492, 102, 164, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_talk_png_1354834674.png", 918, 1476, 102, 164, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_none_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_none_x1_turn_png_1354834676.png", 816, 820, 102, 164, 37, false)
				}
			},
			"humbaba": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_close_png_1354834738.png", 999, 344, 111, 172, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_idle_hold_png_1354834727.png", 999, 1720, 111, 172, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_idle_move_png_1354834740.png", 999, 2408, 111, 172, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_open_png_1354834736.png", 777, 516, 111, 172, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_open_png_1354834736.png", 777, 516, 111, 172, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_talk_png_1354834731.png", 999, 1548, 111, 172, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1Grass_x1_turn_png_1354834735.png", 888, 860, 111, 172, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_close_png_1354834766.png", 999, 344, 111, 172, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_idle_hold_png_1354834756.png", 999, 1720, 111, 172, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_idle_move_png_1354834769.png", 999, 2408, 111, 172, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_open_png_1354834765.png", 777, 516, 111, 172, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_open_png_1354834765.png", 777, 516, 111, 172, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_talk_png_1354834761.png", 999, 1548, 111, 172, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1grassSkirt_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1Grass_x1_turn_png_1354834763.png", 888, 860, 111, 172, 37, false)
				}
			},
			"lem": {
				"day": {

				},
				"night": {

				}
			},
			"mab": {
				"day": {

				},
				"night": {

				}
			},
			"pot": {
				"day": {

				},
				"night": {

				}
			},
			"spriggan": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_close_png_1354835264.png", 930, 582, 155, 194, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_hold_png_1354835252.png", 930, 960, 191, 192, 21, false),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_move_png_1354835269.png", 930, 3880, 155, 194, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835263.png", 775, 776, 155, 194, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835263.png", 775, 776, 155, 194, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_talk_png_1354835257.png", 930, 2522, 155, 194, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_turn_png_1354835260.png", 930, 1358, 155, 194, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_close_png_1354835298.png", 930, 582, 155, 194, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_hold_png_1354835285.png", 930, 2910, 155, 194, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_move_png_1354835302.png", 930, 3880, 155, 194, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835296.png", 775, 776, 155, 194, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835296.png", 775, 776, 155, 194, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_talk_png_1354835291.png", 930, 2522, 155, 194, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_turn_png_1354835294.png", 930, 1358, 155, 194, 37, false)
				}
			},
			"tii": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_close_png_1354834823.png", 990, 374, 110, 187, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_idle_hold_png_1354834814.png", 990, 1870, 110, 187, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_idle_move_png_1354834826.png", 990, 2618, 110, 187, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_open_png_1354834822.png", 770, 561, 110, 187, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_open_png_1354834822.png", 770, 561, 110, 187, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_talk_png_1354834818.png", 990, 1683, 110, 187, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1FlowerTop_x1_turn_png_1354834820.png", 880, 935, 110, 187, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_close_png_1354834853.png", 990, 374, 110, 187, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_idle_hold_png_1354834842.png", 990, 1870, 110, 187, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_idle_move_png_1354834856.png", 990, 2618, 110, 187, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_open_png_1354834852.png", 770, 561, 110, 187, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_open_png_1354834852.png", 770, 561, 110, 187, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_talk_png_1354834847.png", 990, 1683, 110, 187, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1FlowerBush_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1FlowerTop_x1_turn_png_1354834850.png", 880, 935, 110, 187, 37, false)
				}
			},
			"zille": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_close_png_1354835359.png", 672, 534, 112, 178, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_idle_hold_png_1354835349.png", 896, 1958, 112, 178, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_idle_move_png_1354835362.png", 896, 2670, 112, 178, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_open_png_1354835357.png", 784, 534, 112, 178, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_open_png_1354835357.png", 784, 534, 112, 178, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_talk_png_1354835353.png", 896, 1780, 112, 178, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_turn_png_1354835356.png", 896, 890, 112, 178, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_close_png_1354835388.png", 672, 534, 112, 178, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_idle_hold_png_1354835378.png", 896, 1958, 112, 178, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_idle_move_png_1354835392.png", 896, 2670, 112, 178, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_open_png_1354835387.png", 784, 534, 112, 178, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_open_png_1354835387.png", 784, 534, 112, 178, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_talk_png_1354835382.png", 896, 1780, 112, 178, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1flower_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSeedling_x1_turn_png_1354835385.png", 896, 890, 112, 178, 37, false)
				}
			},
		};

		// which shrine is on the street

		String giantName;

		List<Map> entities = getStreetEntities(tsid)['entities'];
		List<String> giants = [
			"alph",
			"cosma",
			"friendly",
			"grendaline",
			"humbaba",
			"lem",
			"mab",
			"pot",
			"spriggan",
			"tii",
			"zille"
		];
		entities.forEach((Map entity) {
			String type = entity['type'].toLowerCase();
				if (giants.contains(type)) {
				giantName = type;
			}
		});
		if (giantName == null) {
			giantName = giants[rand.nextInt(giants.length - 1)];
		}

		// night or day

		String time;

		bool am = clock.time.contains('am');
		List<String> hourmin = clock.time.substring(0, clock.time.length - 2).split(':');
		int hour = int.parse(hourmin[0]);
		if(!am) {
			if(hour >= 5 && hour < 7) {
				// daylight to sunset
				time = 'day';
			} else if(hour >= 7 && hour < 12) {
				// sunset to night
				time = 'night';
			} else {
				time = 'day';
			}
		} else if (am) {
			if(hour < 5 || hour == 12) {
				time = 'night';
			} else if(hour >= 5 && hour < 7) {
				// night to sunrise
				time = 'night';
			} else if(hour >= 7 && hour < 9) {
				// sunrise to daylight
				time = 'day';
			} else {
				time = 'day';
			}
		}

		// assign
		states = AllStates[giantName][time];

		currentState = states['idle_hold'];
	}

	void update() {
		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			//if we just turned, we should say we're facing the other way
			//then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'turn') {
				facingRight = !facingRight;
				currentState = states['idle_move'];
				int length = (currentState.numFrames / 30 * 1000).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
				return;
			} else {
				//sometimes use still so that the blinking isn't predictable
				int roll = rand.nextInt(3);
				if(roll == 1) {
					currentState = states['still'];
				} else {
					currentState = states['idle_hold'];
					respawn = null;
				}
				return;
			}
		}
		if(respawn == null) {
			//sometimes move around
			int roll = rand.nextInt(20);
			if(roll == 3) {
				currentState = states['turn'];
				int length = (currentState.numFrames / 30 * 1000).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
			}
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		currentState = states['open'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		currentState = states['open'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.sell(userSocket:userSocket, email:email);
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			currentState = states['close'];
			int length = (currentState.numFrames / 30 * 1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}