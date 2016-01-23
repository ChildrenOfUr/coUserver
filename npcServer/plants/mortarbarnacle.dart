part of coUserver;

class MortarBarnacle extends Plant {
	MortarBarnacle(String id, int x, int y) : super(id, x, y) {
		actionTime = 2000;
		type = "Mortar Barnacle";

		actions.add({
			"action":"scrape",
			"actionWord":"scraping",
			"timeRequired":actionTime,
			"enabled":true,
			"requires":[
				{
					"num":1,
					"of":["scraper", "super_scraper"],
					"error": "You don't want to use your hands, you'll break a nail!"
				},
				{
					"num":9,
					"of":['energy'],
					"error": "You need at least 9 energy to pull this off."
				}
			]
		});

		states = {
			"1-2-3-4-5" : new Spritesheet("1-2-3-4-5", "http://childrenofur.com/assets/entityImages/barnacle_left.png", 300, 70, 60, 70, 5, false),
		};
		currentState = states['1-2-3-4-5'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = 5;
	}

	Future<bool> scrape({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email,energy:-9,imgMin:10,imgRange:5);
		if(!success) {
			return false;
		}

		StatBuffer.incrementStat("barnaclesScraped", 1);
		state--;
		if(state < 1) {
			respawn = new DateTime.now().add(new Duration(minutes:2));
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(14) == 14) {
			numToGive = 2;
		}

		StatCollection.find(email).then((StatCollection stats) {
			stats.barnacles_scraped += numToGive;
			stats.write();
			if (stats.barnacles_scraped >= 41) {
				Achievement.find("amateur_decrustifier").awardTo(email);
			} else if (stats.barnacles_scraped >= 127) {
				Achievement.find("decrustifying_enthusiast").awardTo(email);
			} else if (stats.barnacles_scraped >= 283) {
				Achievement.find("semi_pro_decrustifier").awardTo(email);
			} else if (stats.barnacles_scraped >= 503) {
				Achievement.find("big_league_decrustifier").awardTo(email);
			} else if (stats.barnacles_scraped >= 1009) {
				Achievement.find("bigger_league_decrustifier").awardTo(email);
			}
		});

		await InventoryV2.addItemToUser(email, items['barnacle'].getMap(), numToGive, id);

		return true;
	}
}