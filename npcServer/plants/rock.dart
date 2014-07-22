part of coUserver;

abstract class Rock extends Plant
{
	Rock(String id, int x, int y) : super(id,x,y)
	{
		actions = {"mine":"mining"};
	}
	
	void mine({WebSocket userSocket})
	{
		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number
		if(state == maxState)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
		
		if(state > maxState)
			state = maxState;
	}
}