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

	harvest({WebSocket userSocket, String username})
	{
		if(state == 0)
			return;

		StatBuffer.incrementStat("treesHarvested", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;

		if(state < 0)
			state = 0;
	}

	water({WebSocket userSocket, String username})
	{
		if(state == maxState)
			return;

		StatBuffer.incrementStat("treesWatered", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;

		if(state > maxState)
			state = maxState;
	}

	pet({WebSocket userSocket, String username})
	{
		StatBuffer.incrementStat("treesPetted", 1);
	}
}