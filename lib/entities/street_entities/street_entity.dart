part of street_entities;

class StreetEntity {
	StreetEntity();

	StreetEntity.create({
		this.id,
		this.type,
		this.tsid,
		this.x: 0,
		this.y: 0,
		this.metadata_json,
		String username
	}) {
		assert(id != null);
		assert(type != null);
		assert(tsid != null);
		if (username != null && metadata['creator'] == null) {
			metadata = new Map.from(metadata)
				..['creator'] = username;
		}
	}

	/// Unique ID across all streets
	@Field() String id;

	@Field() String type;

	/// Must start with L
	@Field() String tsid;

	@Field() int x, y;

	@Field() String metadata_json;

	Map<String, String> get metadata => JSON.decode(metadata_json ?? '{}');

	set metadata(Map<String, String> map) => metadata_json = JSON.encode(map);

	@override String toString() => "<StreetEntity $id ($type) on $tsid at ($x, $y) with metadata $metadata>";
}
