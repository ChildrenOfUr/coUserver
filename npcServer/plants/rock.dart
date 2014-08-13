part of coUserver;

abstract class Rock extends Plant
{
	Rock(String id, int x, int y) : super(id,x,y)
	{
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
			state--;
			setActionEnabled("mine",true);
			respawn = new DateTime.now().add(new Duration(seconds:30));
		}
		
		if(state < maxState)
			state = maxState;
	}
	
	void mine({WebSocket userSocket})
	{
		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
	}
}