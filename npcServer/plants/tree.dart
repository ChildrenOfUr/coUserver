part of coUserver;

abstract class Tree extends Plant
{
	int maturity;
	
	Tree(String id, int x, int y) : super(id,x,y)
	{
		actions = {"harvest":"harvesting","water":"watering","pet":"petting"};
	}
	
	harvest({WebSocket userSocket})
	{
		if(state == 0)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;
		
		if(state < 0)
			state = 0;
	}
	
	water({WebSocket userSocket})
	{
		if(state == maxState)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
		
		if(state > maxState)
			state = maxState;
	}
	
	pet({WebSocket userSocket}) {}
}