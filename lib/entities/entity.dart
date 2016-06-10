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
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/endpoints/visited.dart';
import 'package:coUserver/endpoints/weather.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/streets/street.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:inflection/inflection.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:postgresql/postgresql.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';

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
	Future persist();

	///This will be called when the [Entity] is loaded from the db
	void restoreState(Map<String,String> metadata);

	///This method will be called to get a map of all data that should be saved to the db
	Map<String, String> getPersistMetadata();
}

abstract class Entity extends Object with MetabolicsChange implements Persistable {
	List<Map> actions = [];
	int actionTime = 2500, x, y;
	String bubbleText, streetName, type, id;
	DateTime sayTimeout = null;
	Map<String, List<String>> responses = {};
	Map<String, Spritesheet> states;
	Spritesheet currentState;
	DateTime respawn;

	void setActionEnabled(String action, bool enabled) {
		try {
			for(Map actionMap in actions) {
				if(actionMap['action'] == action) {
					actionMap['enabled'] = enabled;
					return;
				}
			}
		} catch (e, st) {
			Log.error('Error enabling/disabling action $action', e, st);
		}
	}

	Map<String, String> getPersistMetadata() => {};

	Future persist() async {
		String tsid = MapData.getStreetByName(streetName)['tsid'];
		if (tsid == null) {
			Log.warning('Cannot persist entity <type=$type> <id=$id> because tsid is null'
							'for <streetName=$streetName>');
			return;
		}

		StreetEntity dbEntity = new StreetEntity.create(id: id, type: type, tsid: tsid, x: x, y: y,
															metadata_json: JSON.encode(getPersistMetadata()));

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'UPDATE street_entities SET x = @x, y = @y, metadata_json = @metadata_json'
				' WHERE id = @id';
			await dbConn.execute(query, dbEntity);
		} catch (e, st) {
			Log.error('Cannot persist entity <type=$type> <id=$id>', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	Map getMap() {
		Map map = {};
		map['bubbleText'] = bubbleText;
		map['gains'] = gains;
		return map;
	}

	void say(String message) {
		if(message == null || message.trim() == '')
			return;

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

	void setState(String state, {int repeat: 1}) {
		if (!states.containsKey(state)) {
			throw "You made a typo. $state does not exist in the states array for ${this.runtimeType}";
		}

		//set their state and then set the respawn time that it needs
		currentState = states[state];

		//if we want the animation to play more than once before respawn,
		//then multiply the length by the repeat
		int length = (currentState.numFrames / 30 * 1000).toInt() * repeat;
		respawn = new DateTime.now().add(new Duration(milliseconds: length));
	}
}
