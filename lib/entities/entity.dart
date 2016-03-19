library entity;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:mirrors';

import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/stat_buffer.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/endpoints/stats.dart';
import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/inventory_new.dart';
import 'package:coUserver/common/harvest_messages.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/endpoints/visited.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/endpoints/weather.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:postgresql/postgresql.dart';
import 'package:jsonx/jsonx.dart' as jsonx;


part 'spritesheet.dart';
part 'quoin.dart';
part 'plants/plant.dart';
part 'plants/dirtpile.dart';
part 'plants/hellgrapes.dart';
part 'plants/icenubbin.dart';
part 'plants/jellisacgrowth.dart';
part 'plants/mortarbarnacle.dart';
part 'plants/peatbog.dart';
part 'plants/trees/tree.dart';
part 'plants/trees/beantree.dart';
part 'plants/trees/bubbletree.dart';
part 'plants/trees/eggplant.dart';
part 'plants/trees/fruittree.dart';
part 'plants/trees/gasplant.dart';
part 'plants/trees/papertree.dart';
part 'plants/trees/spiceplant.dart';
part 'plants/trees/woodtree.dart';
part 'plants/rocks/rock.dart';
part 'plants/rocks/berylrock.dart';
part 'plants/rocks/dulliterock.dart';
part 'plants/rocks/metalrock.dart';
part 'plants/rocks/sparklyrock.dart';
part 'doors/door.dart';
part 'doors/bureaucratic_hall_door.dart';
part 'doors/hollow_door.dart';
part 'doors/ld_teal-white-triangle.dart';
part 'doors/locked_door.dart';
part 'doors/machine_room_door.dart';
part 'doors/shoppe_door.dart';
part 'npcs/npc.dart';
part 'npcs/auctioneer.dart';
part 'npcs/dust_trap.dart';
part 'npcs/mailbox.dart';
part 'npcs/vistingstone.dart';
part 'npcs/animals/batterfly.dart';
part 'npcs/animals/butterfly.dart';
part 'npcs/animals/chicken.dart';
part 'npcs/animals/firefly.dart';
part 'npcs/animals/helikitty.dart';
part 'npcs/animals/piggy.dart';
part 'npcs/animals/salmon.dart';
part 'npcs/shrines/shrine.dart';
part 'npcs/shrines/alph.dart';
part 'npcs/shrines/cosma.dart';
part 'npcs/shrines/friendly.dart';
part 'npcs/shrines/grendaline.dart';
part 'npcs/shrines/humbaba.dart';
part 'npcs/shrines/lem.dart';
part 'npcs/shrines/mab.dart';
part 'npcs/shrines/pot.dart';
part 'npcs/shrines/spriggan.dart';
part 'npcs/shrines/tii.dart';
part 'npcs/shrines/zille.dart';
part 'npcs/vendors/vendor.dart';
part 'npcs/vendors/jabba_helga.dart';
part 'npcs/vendors/jabba_unclefriendly.dart';
part 'npcs/vendors/mealvendor.dart';
part 'npcs/vendors/snoconevendingmachine.dart';
part 'npcs/vendors/streetspiritfirebog.dart';
part 'npcs/vendors/streetspiritgroddle.dart';
part 'npcs/vendors/streetspiritzutto.dart';
part 'npcs/vendors/toolvendor.dart';

abstract class Entity extends Object with MetabolicsChange {
	List<Map> actions = [];
	int actionTime = 2500;
	String bubbleText;
	DateTime sayTimeout = null;
	Map<String, List<String>> responses = {};

	void setActionEnabled(String action, bool enabled) {
		try {
			for(Map actionMap in actions) {
				if(actionMap['action'] == action) {
					actionMap['enabled'] = enabled;
					return;
				}
			}
		}
		catch(e) {
			log("error enabling/disabling action $action: $e");
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
}