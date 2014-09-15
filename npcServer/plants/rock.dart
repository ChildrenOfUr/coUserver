part of coUserver;

abstract class Rock extends Plant
{
	Rock(String id, int x, int y) : super(id,x,y)
	{
		maxState = 0;
		actionTime = 5000;

		actions.add({"action":"mine",
					 "actionWord":"mining",
					 "timeRequired":actionTime,
					 "enabled":true,
					 "requires":[
					               {
								     "num":1,
								     "of":["Pick","Fancy Pick"]
								   }
								]
					 });
	}

	void update()
	{
		if(state >= currentState.numFrames)
			setActionEnabled("mine",false);

		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0)
		{
			state = 0;
			setActionEnabled("mine",true);
			respawn = null;
		}

		if(state < maxState)
			state = maxState;
	}

	void mine({WebSocket userSocket, String username})
	{
		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number

		StatBuffer.incrementStat("rocksMined", 1);
		state++;
		if(state >= currentState.numFrames)
			respawn = new DateTime.now().add(new Duration(minutes:2));
	}
}