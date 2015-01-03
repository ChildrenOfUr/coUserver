part of coUserver;

class Chicken extends NPC
{
	Chicken(String id, int x, int y) : super(id,x,y)
	{
		actions.add({"action":"squeeze",
					 "enabled":true,
					 "timeRequired":actionTime,
					 "actionWord":"squeezing"});

		type = "Chicken";
     	speed = 75; //pixels per second

     	states =
			{
				"fall" : new Spritesheet("fall","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_fall_png_1354830392.png",740,550,148,110,25,true),
				"flying_back" : new Spritesheet("flying_back","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_flying_back_png_1354830391.png",888,330,148,110,17,true),
				"flying_no_feathers" : new Spritesheet("flying_no_feathers","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_flying_no_feathers_png_1354830388.png",888,770,148,110,42,true),
				"flying" : new Spritesheet("flying","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_flying_png_1354830387.png",888,770,148,110,42,true),
				"idle1" : new Spritesheet("idle1","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_idle1_png_1354830404.png",888,1320,148,110,67,false),
				"idle2" : new Spritesheet("idle2","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_idle2_png_1354830405.png",888,880,148,110,47,false),
				"idle3" : new Spritesheet("idle3","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_idle3_png_1354830407.png",888,1650,148,110,86,false),
				"incubate" : new Spritesheet("incubate","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_incubate_png_1354830403.png",888,3520,148,110,190,false),
				"land_on_ladder" : new Spritesheet("land_on_ladder","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_land_on_ladder_png_1354830390.png",888,550,148,110,26,false),
				"land" : new Spritesheet("land","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_land_png_1354830389.png",740,550,148,110,25,false),
				"pause" : new Spritesheet("pause","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_pause_png_1354830395.png",888,2420,148,110,131,false),
				"pecking_once" : new Spritesheet("pecking_once","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_pecking_once_png_1354830398.png",888,660,148,110,32,false),
				"pecking_twice" : new Spritesheet("pecking_twice","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_pecking_twice_png_1354830400.png",888,770,148,110,27,false),
				"rooked2" : new Spritesheet("rooked2","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_rooked2_png_1354830409.png",888,550,148,110,27,false),
				"sit" : new Spritesheet("sit","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_sit_png_1354830401.png",740,440,148,110,20,false),
				"verb" : new Spritesheet("verb","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_verb_png_1354830397.png",888,1100,148,110,55,false),
				"walk" : new Spritesheet("walk","http://c2.glitch.bz/items/2012-12-06/npc_chicken__x1_walk_png_1354830385.png",888,440,148,110,24,true)
			};
	}

	void squeeze({WebSocket userSocket, String username})
	{
		StatBuffer.incrementStat("chickensSqueezed", 1);
		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new Grain().getMap(),1,id);
	}

	void update()
	{
		//we need to update x to hopefully stay in sync with clients
		if(currentState != null &&
			(currentState.stateName == "walk" || currentState.stateName == "flying"))
		{
			if(facingRight)
				x += speed;
			else
				x -= speed;

			if(x < 0)
				x = 0;
			if(x > 4000) //TODO temporary
				x = 4000;

			//hard to check right bounds without actually loading the street
			//which we aren't doing right now.  we're just making everything up in the constructor
			//but at some point, TODO we should get real street info
			//if(x > street.width-width)
				//x = street.width-width;
		}

		//if respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0)
		{
			//1 in 4 chance to change direction
			if(rand.nextInt(4) == 1)
	          	facingRight = !facingRight;

			int num = rand.nextInt(20);
			switch(num)
			{
				case 1:
					currentState = states['idle1'];
					break;
				case 2:
					currentState = states['idle2'];
					break;
				case 3:
					currentState = states['idle3'];
					break;
				case 4:
					currentState = states['pause'];
					break;
				case 5:
					currentState = states['pecking_once'];
					break;
				case 6:
					currentState = states['pecking_twice'];
					break;
				case 7:
					currentState = states['flying'];
					break;
				default:
					currentState = states['walk'];
			}

			//choose a new animation after this one finishes
			//we can calculate how long it should last by dividing the number
			//of frames by 30
			int length = (currentState.numFrames/30*1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}