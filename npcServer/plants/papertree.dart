part of coUserver;

class PaperTree extends Tree
{
	PaperTree(String id, int x, int y) : super(id,x,y)
	{
		type = "Paper Tree";

		responses = {
        	"harvest": [
        		"Take these sheets away.<br>Do with them as you want to.<br>I cannot use them.",
        		"You want some paper? <br>Take it then, it's yours to use.<br>Just don't waste it. Thanks.",
        		"Giving you paper. <br>I hope that's what you wanted. <br>It's all you're getting.",
        		"Only a few pieces <br>of paper, I will give you. <br>You expected more?",
        		"Here you are: paper!<br>You harvest a paper tree… <br>What do you expect?",
        		"Covered in white stuff. <br>I look like I've been TPed <br>But no, it's my fruit.",
        		"Your perfect harvest. <br>Each branch shaken, and at last…<br>A few clean leaves fall.",
        		"My leaves bow to you<br>My branches offer bounty<br>And now a leaf falls.",
        		"You stretch to harvest <br>Pinching, pulling until paf! <br>A single leaf falls.",
        		"Listen, here's a secret:<br>These aren't just leaves, they're paper!<br>For writing and stuff.",
        		"Here, kid, is paper<br>Used for reading, writing, planes, or<br>Decorating walls.",
        	],
        	"pet": [
        		"Hugging trees tightly<br>a trickle of energy<br>yes, I like that. thanks",
        		"Your action suggests<br>you haven't been at this long<br>but you're still not bad.",
        		"I am Paper Tree<br>I think I might be useful<br>But for what? No clue.",
        		"Paper trees are good<br>at making crinkling noises<br>when you hug their trunks.",
        		"I am paper tree<br>I like it when you hug me hard<br>but so soon you leave.",
        		"This petting pleases.<br>Are you a tree whisperer?<br>(If that is a thing…)",
        		"This kind attention<br>Helps paper tree to grow big<br>We hope you feel proud.",
        		"Such polished petting! <br>That you took the time for this <br>Makes Paper Tree smile.",
        		"I like your petting <br>You know how to please a tree. <br>Not in a weird way.",
        		"Didn't see you there<br>With your soft and kindly hands. <br>You can stop now, though.",
        	],
        	"water": [
        		"That one watering<br>Can… have such stunning effect?<br>Hail, tiny raincloud.",
        		"Even a trickle<br>From the right kind of can<br>Brings life to paper.",
        		"Careful where you aim.<br>I don't want to turn into<br>Papier-mâché.",
        		"Ahh, this welcome rain. <br>It falls upon my branches. <br>And makes me go \"Squeee!\"",
        		"It's very nice, thanks <br>That you have taken the time. <br>To sprinkle on me.",
        		"You made my roots wet. <br>It's not that I'm complaining <br>I'm just a bit damp.",
        		"All this way you came. <br>To seek me out and sprinkle. <br>I think that you're nice.",
        		"Watering paper?<br>Nice, thanks, but watch out there or<br>You'll make me soggy.",
        		"The gentle patter<br>Of sprinkled Glitchy water<br>Brings joy to my roots.",
        		"It's enjoyable,<br>But watch I don't turn into<br>Papier Mache.",
        	]
        };

		states =
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/paper_tree_needs_pet_false_needs_water_false_paper_count_21_x22_1_png_1354832565.png",928,1296,232,216,22,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}

	void harvest({WebSocket userSocket, String email})
	{
		super.harvest(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,email,new Paper().getMap(),1,id);
	}
}