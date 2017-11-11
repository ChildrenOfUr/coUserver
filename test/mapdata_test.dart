import "package:test/test.dart";

import "package:coUserver/common/mapdata/mapdata.dart";

void main() {
	group("Mapdata", () {
		test("Loading", () {
			try {
				MapData.load();
			} catch (e) {
				fail("Error loading map data: $e");
			}
		});

		group("Hidden streets", () {
			test("Street not in game", () {
				final String STREET = "12 Chad Gallows";
				expect(MapData.streetIsHidden(STREET), true, reason: "$STREET is not built");
			});
			
			test("Street not found", () {
				final String STREET = "Coborkol";
				expect(MapData.streetIsHidden(STREET), true, reason: "$STREET doesn't exist");
			});
			
			test("Hidden street", () {
				final String STREET = "Cloud Rings";
				expect(MapData.streetIsHidden(STREET), true, reason: "$STREET is hidden");
			});

			test("Hidden hub", () {
				final String STREET = "The Timeport 3001";
				expect(MapData.streetIsHidden(STREET), true, reason: "$STREET is in a hidden hub");
			});

			test("Normal street", () {
				final String STREET = "Cebarkul";
				expect(MapData.streetIsHidden(STREET), false);
			});
		});
	});
}
