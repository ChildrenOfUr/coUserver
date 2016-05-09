part of entity;

class PaperTree extends Tree {
	PaperTree(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Paper Tree";
		rewardItemType = "paper";

		responses = {
			"harvest": [
				"Take these sheets away. / Do with them as you want to. / I cannot use them.",
				"You want some paper?  / Take it then, it's yours to use. / Just don't waste it. Thanks.",
				"Giving you paper.  / I hope that's what you wanted.  / It's all you're getting.",
				"Only a few pieces  / of paper, I will give you.  / You expected more?",
				"Here you are: paper! / You harvest a paper tree…  / What do you expect?",
				"Covered in white stuff.  / I look like I've been TPed  / But no, it's my fruit.",
				"Your perfect harvest.  / Each branch shaken, and at last… / A few clean leaves fall.",
				"My leaves bow to you / My branches offer bounty / And now a leaf falls.",
				"You stretch to harvest  / Pinching, pulling until paf!  / A single leaf falls.",
				"Listen, here's a secret: / These aren't just leaves, they're paper! / For writing and stuff.",
				"Here, kid, is paper / Used for reading, writing, planes, or / Decorating walls.",
			],
			"pet": [
				"Hugging trees tightly / a trickle of energy / yes, I like that. thanks",
				"Your action suggests / you haven't been at this long / but you're still not bad.",
				"I am Paper Tree / I think I might be useful / But for what? No clue.",
				"Paper trees are good / at making crinkling noises / when you hug their trunks.",
				"I am paper tree / I like it when you hug me hard / but so soon you leave.",
				"This petting pleases. / Are you a tree whisperer? / (If that is a thing…)",
				"This kind attention / Helps paper tree to grow big / We hope you feel proud.",
				"Such polished petting!  / That you took the time for this  / Makes Paper Tree smile.",
				"I like your petting  / You know how to please a tree.  / Not in a weird way.",
				"Didn't see you there / With your soft and kindly hands.  / You can stop now, though.",
			],
			"water": [
				"That one watering / Can… have such stunning effect? / Hail, tiny raincloud.",
				"Even a trickle / From the right kind of can / Brings life to paper.",
				"Careful where you aim. / I don't want to turn into / Papier-mâché.",
				"Ahh, this welcome rain.  / It falls upon my branches.  / And makes me go \"Squeee!\"",
				"It's very nice, thanks  / That you have taken the time.  / To sprinkle on me.",
				"You made my roots wet.  / It's not that I'm complaining  / I'm just a bit damp.",
				"All this way you came.  / To seek me out and sprinkle.  / I think that you're nice.",
				"Watering paper? / Nice, thanks, but watch out there or / You'll make me soggy.",
				"The gentle patter / Of sprinkled Glitchy water / Brings joy to my roots.",
				"It's enjoyable, / But watch I don't turn into / Papier Mache.",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/paper_tree_needs_pet_false_needs_water_false_paper_count_21_x22_1_png_1354832565.png", 928, 1296, 232, 216, 22, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.paper_harvested).then((int harvested) {
				if (harvested >= 1009) {
					Achievement.find("parchment_purloiner").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("pad_pincher").awardTo(email);
				} else if (harvested >= 283) {
					Achievement.find("sheet_snatcher").awardTo(email);
				} else if (harvested >= 73) {
					Achievement.find("paper_plucker").awardTo(email);
				}
			});
		}

		return success;
	}
}