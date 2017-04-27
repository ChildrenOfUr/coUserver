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
			m.energy = m.energy.clamp(0, m.maxEnergy);

			// Set mood
			m.mood += mood;
			m.mood = m.mood.clamp(0, m.maxMood);

			// Set currants
			m.currants += currants;

			// Set iMG
			int baseImg = imgMin;
			if (imgRange > 0) {
				baseImg = rand.nextInt(imgRange) + imgMin;
			}
			int resultImg = (baseImg * m.mood / m.maxMood) ~/ 1;
			m.img += resultImg;
			m.lifetimeImg += resultImg;

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
			.getField(new Symbol(giantName.toLowerCase() + 'Favor'))
			.reflectee;
		int maxAmt = instanceMirror
			.getField(new Symbol(giantName.toLowerCase() + 'FavorMax'))
			.reflectee;

		if (giantFavor + favAmt >= maxAmt) {
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'Favor'), 0);
			maxAmt += 100;
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'FavorMax'), maxAmt);
			await InventoryV2.addItemToUser(email, items['emblem_of_' + giantName.toLowerCase()].getMap(), 1);

			Achievement.find("first_emblem_of_${giantName.toLowerCase()}").awardTo(email);

			//end emblem quest
			messageBus.publish(new RequirementProgress('emblemGet', email));
			StatManager.add(email, Stat.emblems_collected);
		} else {
			instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'Favor'), giantFavor + favAmt);
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
	@Field() int id;
	@Field(model: 'user_id') int userId = -1;
	@Field() int mood = 50;
	@Field(model: 'max_mood') int maxMood = 100;
	@Field() int energy = 50;
	@Field(model: 'max_energy') int maxEnergy = 100;
	@Field() int currants = 0;
	@Field() int img = 0;
	@Field(model: 'lifetime_img') int lifetimeImg = 0;
	@Field() int level = 1;
	@Field(model: 'current_street') String currentStreet = 'LA58KK7B9O522PC';
	@Field(model: 'last_street') String lastStreet = null;
	@Field(model: 'undead_street') String undeadStreet = null;
	@Field(model: 'current_street_x') num currentStreetX = 1.0;
	@Field(model: 'current_street_y') num currentStreetY = 0.0;
	@Field(model: 'quoin_multiplier') num quoinMultiplier = 1;
	@Field(model: 'quoins_collected') int quoinsCollected = 0;
	@Field(model: 'location_history') String locationHistory = '[]';
	@Field(model: 'skills_json') String skillsJson = '{}';
	@Field(model: 'buffs_json') String buffsJson = '{}';
	@Field(model: 'alphfavor') int alphFavor = 0;
	@Field(model: 'alphfavor_max') int alphFavorMax = 1000;
	@Field(model: 'cosmafavor') int cosmaFavor = 0;
	@Field(model: 'cosmafavor_max') int cosmaFavorMax = 1000;
	@Field(model: 'friendlyfavor') int friendlyFavor = 0;
	@Field(model: 'friendlyfavor_max') int friendlyFavorMax = 1000;
	@Field(model: 'grendalinefavor') int grendalineFavor = 0;
	@Field(model: 'grendalinefavor_max') int grendalineFavorMax = 1000;
	@Field(model: 'humbabafavor') int humbabaFavor = 0;
	@Field(model: 'humbabafavor_max') int humbabaFavorMax = 1000;
	@Field(model: 'lemfavor') int lemFavor = 0;
	@Field(model: 'lemfavor_max') int lemFavorMax = 1000;
	@Field(model: 'mabfavor') int mabFavor = 0;
	@Field(model: 'mabfavor_max') int mabFavorMax = 1000;
	@Field(model: 'potfavor') int potFavor = 0;
	@Field(model: 'potfavor_max') int potFavorMax = 1000;
	@Field(model: 'sprigganfavor') int sprigganFavor = 0;
	@Field(model: 'sprigganfavor_max') int sprigganFavorMax = 1000;
	@Field(model: 'tiifavor') int tiiFavor = 0;
	@Field(model: 'tiifavor_max') int tiiFavorMax = 1000;
	@Field(model: 'zillefavor') int zilleFavor = 0;
	@Field(model: 'zillefavor_max') int zilleFavorMax = 1000;

	num get energyPercent => (100 * (energy / maxEnergy));

	num get moodPercent => (100 * (mood / maxMood));

	set dead(bool value) {
		if (value) {
			// Die
			undeadStreet = tsidL(currentStreet);
			energy = 0;
			mood = 0;

			// Don't revive to the Wintry Place, energy will deplete too soon
			if (undeadStreet == tsidL(MapData.getStreetByName('Wintry Place')['tsid'])) {
				undeadStreet = tsidL(MapData.getStreetByName('Northwest Passage')['tsid']);
			}
		} else {
			// Revive
			undeadStreet = null;
			energy = maxEnergy ~/ 10;
			mood = maxMood ~/ 10;
		}
	}

	void addImg(int amount) {
		img += amount;
		lifetimeImg += amount;
	}
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
		for (int level in imgLevels.keys) {
			int levelImg = imgLevels[level];

			if (img < levelImg) {
				result = level - 1;
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
