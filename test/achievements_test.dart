import 'dart:async';

import 'package:test/test.dart';

import 'package:coUserver/achievements/achievements.dart';

import 'test_config.dart';

Future main() async {
	group('Achievements', () {
		test('Load data from JSON', () async {
			int loadedCount = await Achievement.load();
			expect(loadedCount, isNonZero);
		});

		group('Find completists by hub id', () {
			test('Aranna', () {
				final String HUB_ID = '101';
				final String ACHV_ID = 'aranna_completist';

				Achievement found = AchievementCheckers.getCompletistIdForhub(HUB_ID);
				expect(found.id, equals(ACHV_ID));
			});

			test('Groddle Forest', () {
				final String HUB_ID = '56';
				final String ACHV_ID = 'groddle_forest_completist';

				Achievement found = AchievementCheckers.getCompletistIdForhub(HUB_ID);
				expect(found.id, equals(ACHV_ID));
			});
		});
	});
}
