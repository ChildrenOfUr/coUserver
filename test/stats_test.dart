import 'dart:async';

import 'package:test/test.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';

import 'package:coUserver/achievements/stats.dart';
import 'package:coUserver/common/util.dart';

import 'test_config.dart';

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));
	app.redstoneSetUp();

	group('Stats', () {
		test('Test get/add', () async {
			final Stat COOKING = Stat.awesome_pot_uses;
			final Stat PETTING = Stat.spice_plants_petted;

			// Get initial values

			int getCooking1 = await StatManager.get(ut_email, COOKING);
			int getPetting1 = await StatManager.get(ut_email, PETTING);

			expect(getCooking1, isNotNull, reason: 'This player has not used an awesome pot yet');
			expect(getPetting1, isNotNull, reason: 'This player has not petted any spice plants yet');

			// Add to values

			int setCooking1 = await StatManager.add(ut_email, COOKING);
			int setPetting1 = await StatManager.add(ut_email, PETTING, increment: 2);

			expect(setCooking1, getCooking1 + 1, reason: '1 awesome pot use was added');
			expect(setPetting1, getPetting1 + 2, reason: '2 spice plants were petted');

			// Get new values

			int getCooking2 = await StatManager.get(ut_email, COOKING);
			int getPetting2 = await StatManager.get(ut_email, PETTING);

			expect(getCooking2, getCooking1 + 1, reason: 'Awesome pot uses changed');
			expect(getPetting2, getPetting1 + 2, reason: 'Spice plants pet was changed');

			// Add to values again

			int setCooking2 = await StatManager.add(ut_email, COOKING, increment: 2);
			int setPetting2 = await StatManager.add(ut_email, PETTING);

			expect(setCooking2, getCooking2 + 2, reason: '2 awesome pot uses were added');
			expect(setPetting2, getPetting2 + 1, reason: '1 spice plant pet was added');

			// Get new values again

			int getCooking3 = await StatManager.get(ut_email, COOKING);
			int getPetting3 = await StatManager.get(ut_email, PETTING);

			expect(getCooking3, getCooking2 + 2, reason: 'Awesome pot uses changed');
			expect(getPetting3, getPetting2 + 1, reason: 'Spice plants pet was changed');
		});
	});
}
