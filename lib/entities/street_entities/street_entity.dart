part of street_entities;

class StreetEntity {
	StreetEntity();

	StreetEntity.create({
		this.id,
		this.type,
		this.tsid,
		this.x: 0,
		this.y: 0,
		this.z: 0,
		this.h_flip: false,
		this.rotation: 0,
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

	@Field() num x, y, z, rotation;

	@Field()
	bool h_flip;

	@Field() String metadata_json;

	Map<String, String> get metadata => jsonDecode(metadata_json ?? '{}');

	set metadata(Map<String, String> map) => metadata_json = jsonEncode(map);

	@override String toString() => "<StreetEntity $id ($type) on $tsid at ($x, $y, $z), flip: $h_flip, rotation: $rotation with metadata $metadata_json>";
}
