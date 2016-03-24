import "dart:async";

import "package:test/test.dart";
import "package:redstone/redstone.dart" as app;
import "package:redstone_mapper/plugin.dart";

import "package:coUserver/common/util.dart";
import "package:coUserver/endpoints/stats.dart";
import "test_config.dart";

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));
	app.redstoneSetUp();

	group("Status", () {
		test("Verify caching", () async {
			StatCollection collection1 = await StatCollection.find(ut_email);
			StatCollection collection2 = await StatCollection.find(ut_email);

			expect(
				collection1.hashCode, equals(collection2.hashCode),
				reason: "The second object must be the same as the first object "
					"because it should be returned from the cache, not recreated."
				);
		});
	});
}