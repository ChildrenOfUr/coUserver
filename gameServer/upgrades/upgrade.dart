part of coUserver;

class Upgrade {
	@Field()
	String id;

	@Field()
	String name;

	@Field()
	String description;

	@Field()
	String category;

	@Field()
	int cost;

	@Field()
	String image;

	@override
	String toString() => "<Upgrade Card> $name";
}