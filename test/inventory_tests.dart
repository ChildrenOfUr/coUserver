import 'package:coUserver/inventory_new.dart';

import "package:test/test.dart";
import 'package:redstone/redstone.dart';

void main() {
	setupConsoleLog();

	group('Inventory:', () {
		setUp(() => redstoneSetUp([]));
		tearDown(redstoneTearDown);

//		test('Get Inventory', () async {
//			MockRequest req = new MockRequest("/getInventory/robert.mcdermot@gmail.com");
//			MockHttpResponse resp = await dispatch(req);
//			expect(resp.statusCode, equals(404));
//		});
	});
}