part of coUserver;

class Piggy extends NPC
{
	Piggy(String id, int x, int y) : super(id,x,y)
	{
		actions..add({"action":"nibble",
					  "timeRequired":actionTime,
					  "enabled":true,
					 "actionWord":"nibbling"})
			   ..add({"action":"pet",
					  "timeRequired":actionTime,
					  "enabled":true,
					  "actionWord":"petting"});
		type = "Piggy";
		speed = 75; //pixels per second

     	states =
			{
				"chew" : new Spritesheet("chew","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_chew_png_1354829433.png",968,310,88,62,53,true),
				"look_screen" : new Spritesheet("look_screen","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_look_screen_png_1354829434.png",880,310,88,62,48,false),
				"nibble" : new Spritesheet("nibble","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_nibble_png_1354829441.png",880,372,88,62,60,false),
				"rooked1" : new Spritesheet("rooked1","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_rooked1_png_1354829442.png",880,62,88,62,10,true),
				"rooked2" : new Spritesheet("rooked2","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_rooked2_png_1354829443.png",704,186,88,62,24,false),
				"too_much_nibble" : new Spritesheet("too_much_nibble","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_too_much_nibble_png_1354829441.png",968,372,88,62,65,false),
				"walk" : new Spritesheet("walk","http://c2.glitch.bz/items/2012-12-06/npc_piggy__x1_walk_png_1354829432.png",704,186,88,62,24,true)
			};
     	currentState = states['walk'];
	}

	nibble({WebSocket userSocket, String username})
	{
		StatBuffer.incrementStat("piggiesNibbled", 1);
		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new Meat().getMap(),1,id);

		currentState = states['nibble'];
		respawn = new DateTime.now().add(new Duration(seconds:2));
	}

	pet({WebSocket userSocket, String username})
	{
		StatBuffer.incrementStat("piggiesPetted", 1);
	}

	/**
	 * Will simulate piggy movement and send updates to clients if needed
	 */
	update()
	{
		if(currentState.stateName == "walk") //we need to update x to hopefully stay in sync with clients
		{
			if(facingRight)
				x += speed; //75 pixels/sec is the speed set on the client atm
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

			int num = rand.nextInt(10);
    		if(num == 6 || num == 7)
    			currentState = states['look_screen'];
    		else
    			currentState = states['walk'];

			//choose a new animation after this one finishes
			//we can calculate how long it should last by dividing the number
			//of frames by 30
			int length = (currentState.numFrames/30*1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}