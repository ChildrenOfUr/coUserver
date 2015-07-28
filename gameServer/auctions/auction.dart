part of coUserver;

class Auction
{
	@Field()
	String item_name;

	@Field()
	int item_count;

	@Field()
	int total_cost;

	@Field()
	String username;

	@Field()
	DateTime start_time;

	@Field()
	DateTime end_time;
}