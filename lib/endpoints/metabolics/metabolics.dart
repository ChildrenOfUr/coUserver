library metabolics;

import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'dart:io';

import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/achievements/stats.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/common/constants.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street_update_handler.dart';

import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone/redstone.dart' as app;

part 'metabolics_endpoint.dart';

class MetabolicsChange {
	Map<String, int> gains = {'energy':0, 'mood':0, 'img':0, 'currants':0};

	/**
	 * Try to set the metabolics belonging to [email]
	 * If [rewards] is set, it will take precedence over the other metabolics passed in
	 */
	Future<bool> trySetMetabolics(String email,
		{QuestRewards rewards, int energy: 0, int mood: 0, int imgMin: 0, int imgRange: 0, int currants: 0}) async {
		resetGains();

		energy = rewards?.energy ?? energy;
		mood = rewards?.mood ?? mood;
		imgMin = rewards?.img ?? imgMin;
		currants = rewards?.currants ?? currants;

		if (rewards != null) {
			await trySetFavor(email, null, null, favors: rewards.favor);
		}

		Metabolics m = await getMetabolics(email: email);

		//if we're taking away energy, make sure we have enough
		if (energy < 0 && m.energy < energy.abs()) {
			return false;
		} else {
			// Set energy
			m.energy += energy;
			m.energy = m.energy.clamp(0, m.max_energy);

			// Set mood
			m.mood += mood;
			m.mood = m.mood.clamp(0, m.max_mood);

			// Set currants
			m.currants += currants;

			// Set iMG
			int baseImg = imgMin;
			if (imgRange > 0) {
				baseImg = rand.nextInt(imgRange) + imgMin;
			}
			int resultImg = (baseImg * m.mood / m.max_mood) ~/ 1;
			m.img += resultImg;
			m.lifetime_img += resultImg;

			// Send results to client
			gains['energy'] = energy;
			gains['mood'] = mood;
			gains['img'] = resultImg;
			gains['currants'] = currants;

			// Save to database
			if (!(await setMetabolics(m))) {
				return false;
			}


		}

		return true;
	}

	Future<Metabolics> trySetFavor(String email, String giantName, int favAmt, {List<QuestFavor> favors}) async {
		Metabolics metabolics = await getMetabolics(email: email);

		if (favors != null) {
			await Future.forEach(favors, (QuestFavor favor) async {
				metabolics = await _setFavor(email, metabolics, favor.giantName, favor.favAmt);
			});
		} else {
			metabolics = await _setFavor(email, metabolics, giantName, favAmt);
		}

		await setMetabolics(metabolics);
		return metabolics;
	}

	void resetGains() {
		gains = {'energy':0, 'mood':0, 'img':0, 'currants':0};
	}

	Future<Metabolics> _setFavor(String email, Metabolics metabolics, String giantName, int favAmt) async {
		InstanceMirror instanceMirror = reflect(metabolics);
		int giantFavor = instanceMirror
			.getField(new Symbol(giantName.toLowerCase() + 'favor'))
			.reflectee;
		int maxAmt = instanceMirror
			.getField(new Symbol(giantName.toLowerCase() + 'favor_max'))
			.reflectee;

		if (giantFavor + favAmt >= maxAmt) {
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'favor'), 0);
			maxAmt += 100;
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'favor_max'), maxAmt);
			await InventoryV2.addItemToUser(email, items['emblem_of_' + giantName.toLowerCase()].getMap(), 1);

			Achievement.find("first_emblem_of_${giantName.toLowerCase()}").awardTo(email);

			//end emblem quest
			messageBus.publish(new RequirementProgress('emblemGet', email));
			StatManager.add(email, Stat.emblems_collected);
		} else {
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'favor'), giantFavor + favAmt);
		}

		StatManager.add(email, Stat.favor_earned, increment: favAmt);
		return metabolics;
	}

	Future<int> getMood({String username, String email, int userId}) async {
		if (username == null && email == null && userId == null) {
			throw new ArgumentError('You must pass either username, email or userId');
		}

		return (await getMetabolics(username: username, email: email, userId: userId)).mood;
	}

	Future<int> getEnergy({String username, String email, int userId}) async {
		if (username == null && email == null && userId == null) {
			throw new ArgumentError('You must pass either username, email or userId');
		}

		return (await getMetabolics(username: username, email: email, userId: userId)).energy;
	}
}

class Metabolics {
	@Field()
	int id,
		mood = 50,
		max_mood = 100,
		energy = 50,
		max_energy = 100;
	@Field()
	int currants = 0,
		img = 0,
		lifetime_img = 0,
		level = 1;
	@Field()
	String current_street = 'LA58KK7B9O522PC',
		undead_street = null;

	num get energyPercent => (100 * (energy / max_energy));

	num get moodPercent => (100 * (mood / max_mood));

	set dead(bool value) {
		if (value) {
			// Die
			undead_street = tsidL(current_street);
			energy = 0;
			mood = 0;

			// Don't revive to the Wintry Place, energy will deplete too soon
			if (undead_street == tsidL(MapData.getStreetByName('Wintry Place')['tsid'])) {
				undead_street = tsidL(MapData.getStreetByName('Northwest Passage')['tsid']);
			}
		} else {
			// Revive
			undead_street = null;
			energy = max_energy ~/ 10;
			mood = max_mood ~/ 10;
		}
	}

	@Field()
	num current_street_x = 1.0,
		current_street_y = 0.0,
		quoin_multiplier = 1;

	@Field()
	int user_id = -1,
		alphfavor = 0,
		alphfavor_max = 1000,
		cosmafavor = 0,
		cosmafavor_max = 1000,
		friendlyfavor = 0,
		friendlyfavor_max = 1000,
		grendalinefavor = 0,
		grendalinefavor_max = 1000,
		humbabafavor = 0,
		humbabafavor_max = 1000,
		lemfavor = 0,
		lemfavor_max = 1000,
		mabfavor = 0,
		mabfavor_max = 1000,
		potfavor = 0,
		potfavor_max = 1000,
		sprigganfavor = 0,
		sprigganfavor_max = 1000,
		tiifavor = 0,
		tiifavor_max = 1000,
		zillefavor = 0,
		zillefavor_max = 1000,
		quoins_collected = 0;

	@Field()
	String location_history = '[]';

	@Field()
	String skills_json = "{}";

	@Field()
	String buffs_json = "{}";
}

// LEVELS

//Map<int, int> scaleLevels([num sf = 1.37]) {
//	Map<int, num> scale = {
//		1: 0
//	};
//	int base = 100;
//	for (int i = 1; i <= 60; i++) {
//		scale.addAll(({i: base}));
//		base = (base * sf).round();
//	}
//	return scale;
//}

Map<int, int> imgLevels = {
	1: 100,
	2: 137,
	3: 188,
	4: 258,
	5: 353,
	6: 484,
	7: 663,
	8: 908,
	9: 1244,
	10: 1704,
	11: 2334,
	12: 3198,
	13: 4381,
	14: 6002,
	15: 8223,
	16: 11266,
	17: 15434,
	18: 21145,
	19: 28969,
	20: 39688,
	21: 54373,
	22: 74491,
	23: 102053,
	24: 139813,
	25: 191544,
	26: 262415,
	27: 359509,
	28: 492527,
	29: 674762,
	30: 924424,
	31: 1266461,
	32: 1735052,
	33: 2377021,
	34: 3256519,
	35: 4461431,
	36: 6112160,
	37: 8373659,
	38: 11471913,
	39: 15716521,
	40: 21531634,
	41: 29498339,
	42: 40412724,
	43: 55365432,
	44: 75850642,
	45: 103915380,
	46: 142364071,
	47: 195038777,
	48: 267203124,
	49: 366068280,
	50: 501513544,
	51: 687073555,
	52: 941290770,
	53: 1289568355,
	54: 1766708646,
	55: 2420390845,
	56: 3315935458,
	57: 4542831577,
	58: 6223679260,
	59: 8526440586,
	60: 11681223603
};

Map<int, int> energyLevels  = {
	0: 100,
	1: 100,
	2: 110,
	3: 120,
	4: 130,
	5: 140,
	6: 150,
	7: 170,
	8: 190,
	9: 210,
	10: 230,
	11: 250,
	12: 270,
	13: 300,
	14: 330,
	15: 360,
	16: 390,
	17: 420,
	18: 450,
	19: 480,
	20: 520,
	21: 560,
	22: 600,
	23: 640,
	24: 700,
	25: 750,
	26: 800,
	27: 850,
	28: 900,
	29: 950,
	30: 1100,
	31: 1150,
	32: 1200,
	33: 1260,
	34: 1310,
	35: 1370,
	36: 1430,
	37: 1490,
	38: 1550,
	39: 1610,
	40: 1670,
	41: 1740,
	42: 1830,
	43: 1900,
	44: 1970,
	45: 2050,
	46: 2130,
	47: 2210,
	48: 2290,
	49: 2370,
	50: 2460,
	51: 2550,
	52: 2640,
	53: 2730,
	54: 2830,
	55: 2930,
	56: 3030,
	57: 3140,
	58: 3240,
	59: 3340,
	60: 3450
};

@app.Route("/getLevel")
int getLevel(@app.QueryParam("img") int img) {
	int result;

	if (img >= imgLevels[60]) {
		result = 60;
	} else {
		for (int data_lvl in imgLevels.keys) {
			int data_lvl_img = imgLevels[data_lvl];

			if (img < data_lvl_img) {
				result = data_lvl - 1;
				break;
			}
		}
	}

	return result;
}

@app.Route("/getImgForLevel")
int getImgForLevel(@app.QueryParam("level") int lvl) {
	if (lvl > 0 && lvl <= 60) {
		return imgLevels[lvl];
	} else {
		return -1;
	}
}
