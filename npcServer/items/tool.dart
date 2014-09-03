part of coUserver;

abstract class Tool extends Item
{
	String toolAnimation;
	int durability = 100;
		
	@override
	Map getMap()
	{
		Map m = super.getMap();
		m['tool_animation'] = toolAnimation;
		m['durability'] = durability;
		return m;
	}
}