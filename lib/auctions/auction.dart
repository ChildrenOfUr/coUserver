part of auctions;

class AHStatus {
	@Field()
	int total_auctions;

	@Field()
	int total_value;
}

class Auction {
	@Field()
	int id;

	@Field()
	String item_name;

	@Field()
	int item_count;

	@Field()
	int total_cost;

	@Field()
	String username;

	@Field()
	DateTime start_time = new DateTime.now();

	@Field()
	DateTime end_time = new DateTime.now().add(new Duration(days: 2));
}