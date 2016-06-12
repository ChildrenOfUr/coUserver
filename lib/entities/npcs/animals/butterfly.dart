part of entity;

class Butterfly extends NPC {
	bool massaged = false;
	bool interacting = false;
	int numMilks = 0;
	int currentBob = 0, minBob = -50, maxBob = 50;
	bool bobbingUp = true;
	Stopwatch massageExpires = new Stopwatch();

	Butterfly(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Butterfly";
		actions.addAll([
			new Action.withName('massage')
				..timeRequired = actionTime
				..actionWord = 'massaging'
				..energyRequirements = new EnergyRequirements(energyAmount: 7),
			new Action.withName('milk')
				..timeRequired = actionTime
				..actionWord = 'milking'
				..energyRequirements = new EnergyRequirements(energyAmount: 5)
					   ]);
		speed = 75; //pixels per second
		states = {
			"fly-angle1": new Spritesheet(
				"fly-angle1",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_fly-angle1_png_1354829526.png",
				840,
				195,
				70,
				65,
				34,
				true),
			"fly-angle2": new Spritesheet(
				"fly-angle2",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_fly-angle2_png_1354829527.png",
				700,
				130,
				70,
				65,
				20,
				true),
			"fly-rooked": new Spritesheet(
				"fly-rooked",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_fly-rooked_png_1354829525.png",
				980,
				65,
				70,
				65,
				14,
				true),
			"fly-side": new Spritesheet(
				"fly-side",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_fly-side_png_1354829525.png",
				980,
				390,
				70,
				65,
				84,
				true),
			"fly-top": new Spritesheet(
				"fly-top",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_fly-top_png_1354829528.png",
				910,
				455,
				70,
				65,
				87,
				true),
			"rest-angle1": new Spritesheet(
				"rest-angle1",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_rest-angle1_png_1354829530.png",
				420,
				65,
				70,
				65,
				6,
				true),
			"rest-angle2": new Spritesheet(
				"rest-angle2",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_rest-angle2_png_1354829531.png",
				700,
				65,
				70,
				65,
				10,
				true),
			"rest-top": new Spritesheet(
				"rest-top",
				"http://childrenofur.com/assets/entityImages/npc_butterfly__x1_rest-top_png_1354829532.png",
				980,
				195,
				70,
				65,
				42,
				true)
		};
		setState("fly-side");
		responses = {
			"massage": [
				"Mmmf. Not bad.",
				"Massage ok. ‘Spose.",
				"Like, whatever",
				"K, thanx.",
				"Askimble ubble gite nud razzafrazza rhubarb",
				"Ruttle snottfig squeebug fallgite schmee rugger",
				"Nookle flubber wezzent tie lupose rhubarb flap",
				"Meh fat strop portoff frite pice",
				"Flitup pickr rhubarb tokayai poze",
				"Yeah. So can I go hang with my butterfriends now?",
				"Unmf",
				"Ok, so, great massage. Can I, like, go?",
				"Yeah, so, thanks. I guess.",
				"Yeah, so-so, whatevs, k bai.",
				"rutter flubbtoo spose quite nice rhubarb twonk",
				"buffrum gish flih not bad frakock kweezle",
				"nickpu flotter meh not unpleasant frumk",
				"croopy picklr so thass okay iffoo mumble nunk",
				"rhubarb tosstpottee I like it soafcan dowitmoar",
				"So um I dunno? Like, I guess I liked that? Kinda?",
				"Yeah, so that was like, not bad? I suppose? Thanks?",
				"So, like, that was quite good?",
				"I mean, whatever and everything? But that was ok and stuff?",
				"Well, totally not unpleasant? So yeah? whatever?",
				"Like, whatever?…",
				"Yeah, so, um. Ok? Thanks?",
				"Yeah? So nice massage? Whatever?",
				"So, I mean, the massage? It was, like, ok? Thanks?",
				"Right, so I liked your massage? So, like, thanks?",
				"Thnx, Bigthing.",
				"OMG ur like, gr8",
				"AWSUM msrg.",
				"i <3 u + ur msrgs",
				"K thnx ttyl :)",
				"Msrg! I <3 msrgs! \\o\/",
				"\\o\/",
				"LOL! Ur, like, all msrgy!",
				"i <333 u!!!!1!",
				"Thnx!",
				"K THNX 4 MSRG BAI!",
				"Ur nice 4 msrgin me. xoxo",
				"OMG UR AWSM! \\o\/",
				"<333 msrgs",
				"Yay thnx bigthing. ttyl…",
				"So I'm like, happy? So, um, you should be happy too?",
				"Yeah, so, massages make everyone happy, right?",
				"Like, I can totes be nice too, yeah?",
				"So yeah? You're nice? Be, um, happy, yeah?",
				"Ok, so, ping!?! Are you, like, happier too now?",
				"Ugh. Good moods are so uncool? You have mine.",
				"Like, whatever? But, so, you're awesome?",
				"So, yeah. You should be, like, happy?",
				"You're, like, awesome. Cheer up, yeah?",
				"Whatever? Yeah? Ok so, like, thanks!",
				"OMG ur gr8! Mood++!",
				"TY! i <3 ur msrg! ur awsm!",
				"U wnt ++mood? U gets!",
				"Yay, thnx! I <3 msrgs!",
				"LOL! I likes you LOADS!",
				":) +++++++++",
				"i <3 ur msrgs <------------------> mch!",
				"i <3333333333 u!",
				"Mood+++!!!!!!!1!",
				"\\o\/ Yaaaaaaaay!!!! R u happy?"
			],
			"massageFail": [
				"Ow! Why not just rub me with gravel?!",
				"OMFG! 2 DRY! UR rubbish.",
				"Ooo, ow, no, bad, stoppit.",
				"Jeez, if you can’t do it properly…",
				"Git ur dry hands off! Yow!",
				"ruzzle fruzza bugroff mumble",
				"noliyk frakkig soddov rhubarble",
				"watta grunkle peff",
				"razzafrazzin digdassurdy",
				"Yeahright."
			],
			"milk": [
				"Whoa milky!",
				"Here: milx",
				"Milx 4 U",
				"Got milx?",
				"Milky milky",
				"Here. S’good for growing teeth and stuff. And tails.",
				"Fruzzup air oogoh merp",
				"Kruffin ilx ans uff",
				"Toffuzzin rappat ulk",
				"Rufflin bilky mong. Urk.",
				"Pufflunk norky tonk rnmrnmrnm",
				"I got some containers too!",
				"OMG you again! Take milk. K?",
				"There. Milx. Happy? Bai.",
				"UR OK. U can has milx.",
				"K, so I has milx. You wants?",
				"Here! Made you beer! I kiddin’. Is milx.",
				"Pikgug fup here y'are urk fopple",
				"Snuggurp have these enflurkle",
				"Runkle some milk then flub rmnrnmrnmrm",
				"Glubfoo milk you wanted rhuburble bunk",
				"Snurfle milk, yeah? Ok, ruffgrm mnurmnur.",
				"So you wanted milk, yeah? Like, whatever?",
				"Yeah, like, you can have this milk? Like, totally?",
				"Whatever, yeah? So I made you milk?",
				"Right, so, like, milk? There? Have it?",
				"So like you can have milk again sometime? Or whatever?",
				"Right, so here's your milk?",
				"Alright so yeah, whatever? Here's your milk?",
				"So like, somehow you milked me, and I made this?",
				"Hey, you want this? I guess? 'Cos you milked me?",
				"Whatever and that, but take this milk, yeah?",
				"OMG I TOTES DID U MILX!",
				"i got milx 4 u!!!!!1!!",
				"Milx r awsum! U r awsum!",
				"i <3 u! milx! ttyl!!!1!",
				"gt milx? Ys! ROFL!!!!1!!",
				"You needs milx! You totes HAZ milx!!!",
				"1t milx? Gotz milx! YAY!",
				"I maded milx.",
				"Look @ my milx! U can haz!!!!!!!!!!",
				"U <3 milx? I <3 u!!!",
				"YAY I MADEZ YOU MILX!!!1!",
				"Here iz milx! l8r!!!!",
				"U likez ur milx? YAY! Bai!!!",
				"All theez milxez r 4 u! <3333",
				"Milx! Enjoi! xoxo"
			],
			"milkExtra": [
				"Don't let it go to your head, yeah? I just have extra.",
				"Yeah, extra milk, whatevs. Doesn’t mean we’re friends.",
				"So I made you extra milk? Like? Whatever?",
				"Yeah, so, like, you want some extra or what?",
				"Like, you want extra? I made extra.",
				"You can totes have this extra milk? I don't want it.",
				"You want extra milks? Like, whatevs.",
				"I'm totally super-milky right now. Don't wanna talk about it.",
				"K, so whatevs, but I made you extra today?",
				"You can have extra, I guess, 'cos you're ok.",
				"Yeah, so I'm, like, super-milky? TMI? Want extra?",
				"I have, like, too much milk. You can have more.",
				"Xtra-milx 4 u 2day!",
				"OMG! 8-O Supr-milx!!!!!",
				"Yayz! Multi-milx!",
				"o_O!!!!!!1! So many milx!",
				"O rly? Moar milx? OKAYZ!",
				"i <<<3 u THS much milx!",
				"++++++++++milx. Srsly.",
				"u <3 milx? i <3 u.",
				"OMG! +++++Milx!",
				"Lotsamilx. k? kewl. ttyl!!!!1!!"
			]
		};
	}

	Future<bool> massage({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email, energy: -7, mood: 3, imgMin: 5, imgRange: 3);
		if (!success) {
			return false;
		}
		interacting = true;
		if (!(await InventoryV2.hasItem(email, 'butterfly_lotion', 1))) {
			say(responses['massageFail'].elementAt(rand.nextInt(responses['massageFail'].length)));
		} else {
			StatManager.add(email, Stat.butterflies_massaged);
			say(responses['massage'].elementAt(rand.nextInt(responses['massage'].length)));
			massaged = true;
			numMilks = 0;
		}
		interacting = false;
		massageExpires.start();
		return true;
	}

	Future<bool> milk({WebSocket userSocket, String email}) async {
		if (massaged) {
			bool success = await super.trySetMetabolics(email, energy: -5, mood: 5, imgMin: 5, imgRange: 6);
			if (!success) {
				return false;
			}

			interacting = true;

			int qty;
			if (rand.nextInt(10) == 1) {
				// bonus milk
				qty = 3;
				say(responses['milkExtra'].elementAt(rand.nextInt(responses['milkExtra'].length)));
			} else {
				qty = 1;
				say(responses['milk'].elementAt(rand.nextInt(responses['milk'].length)));
			}
			await InventoryV2.addItemToUser(email, items['butterfly_milk'].getMap(), qty, id);

			StatManager.add(email, Stat.butterflies_milked);
		} else {
			// not massaged (milkFail)
			bool success = await super.trySetMetabolics(email, energy: -5, mood: -2, imgMin: 5, imgRange: 2);
			if (!success) {
				return false;
			}
			say(
				"What? No warmup? No preamble? You just walk up to a butterfly with your clammy hands and try to milk it? You have a lot to learn about charming butterflies.");
		}

		interacting = false;

		return true;
	}

	update() {
		super.update();

		if (currentState.stateName == "fly-side" && !interacting) {
			moveXY(yAction: (){
				// bob up and down a bit
				if (bobbingUp) {
					y--;
					currentBob--;
					if (currentBob < minBob) {
						bobbingUp = false;
					}
				} else {
					y++;
					currentBob++;
					if (currentBob > maxBob) {
						bobbingUp = true;
					}
				}
			},ledgeAction: (){});
		}

		// must massage again after 5 minutes
		if (massageExpires.elapsed.inMinutes > 5) {
			massaged = false;
		}

		//if respawn is in the past, it is time to choose a new animation
		if (respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 4 chance to change direction
			if (rand.nextInt(4) == 1) {
				facingRight = !facingRight;
			}

			setState('fly-side', repeat: rand.nextInt(5));
		}
	}
}
