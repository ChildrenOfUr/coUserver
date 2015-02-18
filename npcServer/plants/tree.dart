part of coUserver;

abstract class Tree extends Plant
{
	int maturity;

	Tree(String id, int x, int y) : super(id,x,y)
	{
		actions..add({"action":"harvest",
					  "timeRequired":actionTime,
					  "enabled":true,
					 "actionWord":"harvesting"})
			   ..add({"action":"water",
					  "timeRequired":actionTime,
					  "enabled":true,
					  "actionWord":"watering"})
			   ..add({"action":"pet",
					  "timeRequired":actionTime,
					  "enabled":true,
					  "actionWord":"petting"});
	}

	void update()
	{
		super.update();

		if(state > 0)
			setActionEnabled("harvest",true);
		else
			setActionEnabled("harvest",false);
	}

	harvest({WebSocket userSocket, String email})
	{
		if(state == 0)
			return;

		//say a witty thing
		say(responses['harvest'].elementAt(rand.nextInt(responses['harvest'].length)));

		StatBuffer.incrementStat("treesHarvested", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;

		if(state < 0)
			state = 0;
	}

	water({WebSocket userSocket, String email})
	{
		if(state == maxState)
			return;

		//say a witty thing
		say(responses['water'].elementAt(rand.nextInt(responses['water'].length)));

		StatBuffer.incrementStat("treesWatered", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;

		if(state > maxState)
			state = maxState;
	}

	pet({WebSocket userSocket, String email})
	{
		//say a witty thing
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		StatBuffer.incrementStat("treesPetted", 1);
	}
}