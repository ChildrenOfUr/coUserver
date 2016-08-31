library entity;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:mirrors';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/achievements/stats.dart';
import 'package:coUserver/common/harvest_messages.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/endpoints/visited.dart';
import 'package:coUserver/endpoints/weather/weather.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street.dart';
import 'package:coUserver/streets/street_update_handler.dart';

import 'package:inflection/inflection.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:message_bus/message_bus.dart';
import 'package:path/path.dart' as path;
import 'package:postgresql/postgresql.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone/redstone.dart' as app;

part 'doors/bureaucratic_hall_door.dart';
part 'doors/door.dart';
part 'doors/hollow_door.dart';
part 'doors/ld_teal-white-triangle.dart';
part 'doors/locked_door.dart';
part 'doors/machine_room_door.dart';
part 'doors/shoppe_door.dart';
part 'entity_endpoint.dart';
part 'npcs/animals/batterfly.dart';
part 'npcs/animals/butterfly.dart';
part 'npcs/animals/chicken.dart';
part 'npcs/animals/firefly.dart';
part 'npcs/animals/fox.dart';
part 'npcs/animals/helikitty.dart';
part 'npcs/animals/piggy.dart';
part 'npcs/animals/salmon.dart';
part 'npcs/auctioneer.dart';
part 'npcs/crab.dart';
part 'npcs/dust_trap.dart';
part 'npcs/hell_bartender.dart';
part 'npcs/items/cubimal.dart';
part 'npcs/items/entity_item.dart';
part 'npcs/items/still.dart';
part 'npcs/mailbox.dart';
part 'npcs/npc.dart';
part 'npcs/shrines/alph.dart';
part 'npcs/shrines/cosma.dart';
part 'npcs/shrines/friendly.dart';
part 'npcs/shrines/grendaline.dart';
part 'npcs/shrines/humbaba.dart';
part 'npcs/shrines/lem.dart';
part 'npcs/shrines/mab.dart';
part 'npcs/shrines/pot.dart';
part 'npcs/shrines/shrine.dart';
part 'npcs/shrines/spriggan.dart';
part 'npcs/shrines/tii.dart';
part 'npcs/shrines/zille.dart';
part 'npcs/vendors/fakevendors.dart';
part 'npcs/vendors/jabba_helga.dart';
part 'npcs/vendors/jabba_unclefriendly.dart';
part 'npcs/vendors/mealvendor.dart';
part 'npcs/vendors/scarecrow.dart';
part 'npcs/vendors/snoconevendingmachine.dart';
part 'npcs/vendors/street_spirit.dart';
part 'npcs/vendors/streetspiritfirebog.dart';
part 'npcs/vendors/streetspiritgroddle.dart';
part 'npcs/vendors/streetspiritzutto.dart';
part 'npcs/vendors/toolvendor.dart';
part 'npcs/vendors/vendor.dart';
part 'npcs/vistingstone.dart';
part 'package:coUserver/entities/npcs/garden.dart';
part 'plants/dirtpile.dart';
part 'plants/icenubbin.dart';
part 'plants/jellisacgrowth.dart';
part 'plants/mortarbarnacle.dart';
part 'plants/peatbog.dart';
part 'plants/plant.dart';
part 'plants/respawning_items/awesome_stew.dart';
part 'plants/respawning_items/earthshaker.dart';
part 'plants/respawning_items/hellgrapes.dart';
part 'plants/respawning_items/helltomatoes.dart';
part 'plants/respawning_items/respawning_item.dart';
part 'plants/rocks/berylrock.dart';
part 'plants/rocks/dulliterock.dart';
part 'plants/rocks/metalrock.dart';
part 'plants/rocks/rock.dart';
part 'plants/rocks/sparklyrock.dart';
part 'plants/trees/beantree.dart';
part 'plants/trees/bubbletree.dart';
part 'plants/trees/eggplant.dart';
part 'plants/trees/fruittree.dart';
part 'plants/trees/gasplant.dart';
part 'plants/trees/papertree.dart';
part 'plants/trees/spiceplant.dart';
part 'plants/trees/tree.dart';
part 'plants/trees/woodtree.dart';
part 'quoin.dart';
part 'spritesheet.dart';

/// Create an entity ID
String createId(num x, num y, String type, String tsid) {
	int hash = (type + x.toString() + y.toString() + tsidL(tsid)).hashCode;
	return type.substring(0, 1) + hash.toString();
}

abstract class Persistable {
	///This will be called when the [Street] that the [Entity] is on
	///is persisted to the database
	StreetEntity persist();

	///This will be called when the [Entity] is loaded from the db
	void restoreState(Map<String,String> metadata);

	///This method will be called to get a map of all data that should be saved to the db
	Map<String, String> getPersistMetadata();
}

abstract class Actionable {
	///This will be called when sending the npc's state to the client
	///In order to display accurate energy costs etc., we need to take the
	///players skills into account
	Future<List<Action>> customizeActions(String email);
}

abstract class Entity extends Object with MetabolicsChange implements Persistable, Actionable {
	List<Action> actions = [];
	int actionTime = 2500, x, y, z;
	String bubbleText, streetName, type, id;
	DateTime sayTimeout = null;
	Map<String, List<String>> responses = {};
	Map<String, Spritesheet> states;
	Spritesheet currentState;
	DateTime respawn;

	void setActionEnabled(String actionName, bool enabled) {
		try {
			for(Action action in actions) {
				if(action.actionName == actionName) {
					action.enabled = enabled;
					return;
				}
			}
		} catch (e, st) {
			Log.error('Error enabling/disabling action $actionName', e, st);
		}
	}

	Map<String, String> getPersistMetadata() => {};

	StreetEntity persist() {
		Map streetDataMap = MapData.getStreetByName(streetName);
		if (streetDataMap == null) {
			Log.warning('Cannot persist entity <type=$type> <id=$id> because streetDataMap'
						' was null for this entity (type=$type) <streetName=$streetName>');
			return null;
		}

		String tsid = streetDataMap['tsid'];
		if (tsid == null) {
			Log.warning('Cannot persist entity <type=$type> <id=$id> because tsid is null'
							'for <streetName=$streetName>');
			return null;
		}

		return new StreetEntity.create(id: id, type: type, tsid: tsid, x: x, y: y, z: z,
															metadata_json: JSON.encode(getPersistMetadata()));
	}

	Map<String, dynamic> getMap() {
		Map map = {};
		map['bubbleText'] = bubbleText;
		map['gains'] = gains;
		return map;
	}

	Future<List<Action>> customizeActions(String email) async {
		return actions;
	}

	void say([String message]) {
		message = (message ?? '').trim();

		DateTime now = new DateTime.now();
		if(sayTimeout == null || sayTimeout.compareTo(now) < 0) {
			bubbleText = message;
			int timeToLive = message.length * 30 + 3000; //minimum 3s plus 0.3s per character
			if(timeToLive > 10000) //max 10s
				timeToLive = 10000;
			//messages over 10s will only display for 10s

			Duration messageDuration = new Duration(milliseconds:timeToLive);
			sayTimeout = now.add(messageDuration);
			new Timer(messageDuration, () {
				bubbleText = null;
				resetGains();
			});
		}
	}

	void setState(String state, {int repeat: 1, Duration repeatFor, String thenState}) {
		if (!states.containsKey(state)) {
			throw "You made a typo. $state does not exist in the states array for ${this.runtimeType}";
		}

		if (thenState != null && !states.containsKey(thenState)) {
			throw "You made a typo. $thenState does not exist in the states array for ${this.runtimeType}";
		}

		//set their state and then set the respawn time that it needs
		currentState = states[state];

		//if we want the animation to play more than once before respawn,
		//then multiply the length by the repeat
		int length = (currentState.numFrames / 30 * 1000).toInt() * repeat;
		if (repeatFor != null) {
			length = repeatFor.inMilliseconds;
		}

		if (thenState != null) {
			new Timer(new Duration(milliseconds: length), () => setState(thenState));
			length += (states[thenState].numFrames / 30 *1000).toInt();
		}

		respawn = new DateTime.now().add(new Duration(milliseconds: length));
	}

	///Check the various requirements for an action to be allowed to be performed
	///The energy check will be skipped by default since most actions will check this
	///through trySetMetabolics anyway
	Future<bool> hasRequirements(String actionName, String email, {bool includeBroken: false, bool testEnergy: false}) async {
		Action action = actions.singleWhere((Action a) => a.actionName == actionName);
		bool hasRequirements = true;

		//check that the player has the necessary energy
		if (testEnergy) {
			Metabolics m = await getMetabolics(email: email);
			if (m.energy < action.energyRequirements.energyAmount) {
				return false;
			}
		}

		//check the players skill level(s) against the required skill level(s)
		await Future.forEach(action.skillRequirements.requiredSkillLevels.keys, (String skillName) async {
			if (hasRequirements == true) {
				int reqSkillLevel = action.skillRequirements.requiredSkillLevels[skillName];
				int haveLevel = await SkillManager.getLevel(skillName, email);
				if (haveLevel < reqSkillLevel) {
					hasRequirements = false;
				}
			}
		});

		//possibly exit early
		if (!hasRequirements) {
			return false;
		}

		//check that the player has the necessary item(s)
		bool hasAtLeastOne = action.itemRequirements.any.length == 0;
		await Future.forEach(action.itemRequirements.any, (String itemType) async {
			if(!hasAtLeastOne) {
				if (includeBroken) {
					hasAtLeastOne = await InventoryV2.hasItem(email, itemType, 1);
				} else {
					hasAtLeastOne = await InventoryV2.hasUnbrokenItem(email, itemType, 1);
				}
			}
		});

		//possibly exit early
		if (!hasAtLeastOne) {
			return false;
		}

		await Future.forEach(action.itemRequirements.all.keys, (String itemType) async {
			int numNeeded = action.itemRequirements.all[itemType];
			if (includeBroken) {
				hasRequirements = await InventoryV2.hasItem(email, itemType, numNeeded);
			} else {
				hasRequirements = await InventoryV2.hasUnbrokenItem(email, itemType, numNeeded);
			}
		});

		return hasRequirements;
	}
}
