part of street_entities;

class StreetEntity {
	StreetEntity();

	StreetEntity.create({this.id, this.type, this.tsid, this.x: 0, this.y: 0}) {
		assert(id != null);
		assert(type != null);
		assert(tsid != null);
	}

	/// Unique ID across all streets
	@Field() String id;

	@Field() String type;

	/// Must start with L
	@Field() String tsid;

	@Field() int x, y;

	@override String toString() => "<StreetEntity $id ($type) on $tsid at ($x, $y)>";
}
