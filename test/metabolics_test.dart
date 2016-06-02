import 'dart:async';

import 'test_config.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/streets/street_update_handler.dart';

import 'package:test/test.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:harvest/harvest.dart' as harvest;

class MockMetabolicsObject extends Object with MetabolicsChange {}

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));

	//need to call this before loading the items
	app.redstoneSetUp();

	//ignore messages about quest requirements being completed when not on the quest
	messageBus.deadMessageHandler = (harvest.Message m) {};

	//load game items
	await StreetUpdateHandler.loadItems();

	group('Metabolics:', () {
		setUp(() async {
			app.redstoneSetUp([#metabolics]);

			Metabolics m = new Metabolics()
				..user_id = ut_id;
			await setMetabolics(m);
		});
		tearDown(() async {
			//delete ut metabolics
			String query = 'DELETE FROM metabolics WHERE user_id = $ut_id';
			PostgreSql dbConn = await dbManager.getConnection();
			await dbConn.execute(query);
			dbManager.closeConnection(dbConn);

			app.redstoneTearDown();
		});

		test('Metabolics object', () async {
			Metabolics m = await getMetabolics(email: ut_email);
			expect(m.energy, equals(m.max_energy ~/ 2));
			expect(m.mood, equals(m.max_mood ~/ 2));
			expect(m.undead_street, isNull);
			String current_street = m.current_street;

			//kill the user
			m.dead = true;
			expect(m.energy, equals(0));
			expect(m.undead_street, equals(current_street));

			//revive player
			m.dead = false;
			expect(m.energy, equals(m.max_energy ~/ 10));
			expect(m.mood, equals(m.max_mood ~/ 10));
			expect(m.current_street, equals(current_street));
		});

		test('trySetFavor', () async {
			MockMetabolicsObject object = new MockMetabolicsObject();

			//add 50 Alph favor
			Metabolics m = await object.trySetFavor(ut_email, 'alph', 50);
			expect(m.alphfavor, equals(50));

			//add more than max favor, expect 0 and expanded max
			int maxBefore = m.alphfavor_max;
			m = await object.trySetFavor(ut_email, 'alph', m.alphfavor_max + 1);
			expect(m.alphfavor, equals(0));
			expect(m.alphfavor_max, equals(maxBefore+100));

			//add favor as if for a quest reward
			List<QuestFavor> favors = [
				new QuestFavor()
					..giantName = 'humbaba'
					..favAmt = 50,
				new QuestFavor()
					..giantName = 'lem'
					..favAmt = 100,
				new QuestFavor()
					..giantName = 'zille'
					..favAmt = m.zillefavor_max + 1
			];
			maxBefore = m.zillefavor_max;
			m = await object.trySetFavor(ut_email, null, null, favors: favors);
			expect(m.humbabafavor, equals(50));
			expect(m.lemfavor, equals(100));
			expect(m.zillefavor, equals(0));
			expect(m.zillefavor_max, equals(maxBefore+100));
		});

		test('trySetMetabolics', () async {
			MockMetabolicsObject object = new MockMetabolicsObject();
			expect(await object.trySetMetabolics(ut_email), isTrue);

			Metabolics m = await getMetabolics(email: ut_email);
			expect(m.energy, equals(50));

			//test that we can take some energy
			expect(await object.trySetMetabolics(ut_email, energy: -5), isTrue);
			expect((await getMetabolics(email: ut_email)).energy, equals(45));

			//test that we can't take more energy than we have
			expect(await object.trySetMetabolics(ut_email, energy: -46), isFalse);
			expect((await getMetabolics(email: ut_email)).energy, equals(45));

			//add a bunch of img and expect to gain a few levels
			expect(getLevel(m.lifetime_img), equals(0));
			expect(await object.trySetMetabolics(ut_email, imgMin: 100000, imgRange: 5), isTrue);
			expect(getLevel((await getMetabolics(email: ut_email)).lifetime_img), greaterThan(0));

			//reset the metabolics
			await setMetabolics(new Metabolics()..user_id = ut_id);

			m = await getMetabolics(email: ut_email);
			int beforeMax = m.zillefavor_max;
			List<QuestFavor> favors = [
				new QuestFavor()
					..giantName = 'humbaba'
					..favAmt = 50,
				new QuestFavor()
					..giantName = 'lem'
					..favAmt = 100,
				new QuestFavor()
					..giantName = 'zille'
					..favAmt = m.zillefavor_max + 1
			];
			QuestRewards rewards = new QuestRewards()
				..currants = 100
				..favor = favors
				..mood = 40;
			expect(await object.trySetMetabolics(ut_email, rewards: rewards), isTrue);
			m = await getMetabolics(email: ut_email);
			expect(m.currants, equals(100));
			expect(m.mood, equals(90));
			expect(m.humbabafavor, equals(50));
			expect(m.lemfavor, equals(100));
			expect(m.zillefavor, equals(0));
			expect(m.zillefavor_max, greaterThan(beforeMax));
		});

		test('getLevel', () async {
			//make sure the /getLevel endpoint answer matches the imgLevels map
			await Future.forEach(imgLevels.keys, (int level) async {
				int imgReq = imgLevels[level];

				app.MockRequest req = new app.MockRequest("/getLevel", queryParameters: {'img':imgReq});
				app.MockHttpResponse resp = await app.dispatch(req);

				//verify we get a valid response
				expect(resp.statusCode, equals(200));
				expect(resp.mockContent, equals('$level'));
			});

			//make sure you only get the level if you have the required img, no less
			await Future.forEach(imgLevels.keys, (int level) async {
				int lessImg = imgLevels[level] - 1;

				app.MockRequest req = new app.MockRequest("/getLevel", queryParameters: {'img':lessImg});
				app.MockHttpResponse resp = await app.dispatch(req);

				//verify we get a valid response
				expect(resp.statusCode, equals(200));
				expect(resp.mockContent, equals('${level - 1}'));
			});
		});

		test('getImgForLevel', () async {
			await Future.forEach(imgLevels.keys, (int level) async {
				app.MockRequest req = new app.MockRequest("/getImgForLevel", queryParameters: {'level':level});
				app.MockHttpResponse resp = await app.dispatch(req);

				//verify we get a valid response
				expect(resp.statusCode, equals(200));
				expect(resp.mockContent, equals('${imgLevels[level]}'));
			});
		});
	});
}
