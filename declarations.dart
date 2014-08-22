library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import "package:intl/intl.dart";
import "package:slack/slack_io.dart" as slack;
import "package:postgresql/postgresql.dart";
import "package:redstone/server.dart" as app;
import 'package:logging/logging.dart';

part 'server.dart';
part 'API_KEYS.dart';

//common to all server parts
part 'common/identifier.dart';

//chat server parts
part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'chatServer/chat_handler.dart';

//multiplayer server parts
part 'multiplayerServer/player_update_handler.dart';

//npc server (street simulation) parts
part 'npcServer/street_update_handler.dart';
part 'npcServer/street.dart';
part 'npcServer/npcs/piggy.dart';
part 'npcServer/npcs/npc.dart';
part 'npcServer/npcs/vendor.dart';
part 'npcServer/npcs/chicken.dart';

//items
part 'npcServer/npcs/items/item.dart';
part 'npcServer/npcs/items/highclasshoe.dart';
part 'npcServer/npcs/items/bean.dart';
part 'npcServer/npcs/items/cherry.dart';
part 'npcServer/npcs/items/grain.dart';
part 'npcServer/npcs/items/meat.dart';
part 'npcServer/npcs/items/chunkofberyl.dart';
part 'npcServer/npcs/items/chunkofsparkly.dart';
part 'npcServer/npcs/items/chunkofmetalrock.dart';
part 'npcServer/npcs/items/chunkofdullite.dart';
part 'npcServer/npcs/items/modestlysizedruby.dart';
part 'npcServer/npcs/items/generalvapour.dart';
part 'npcServer/npcs/items/allspice.dart';
part 'npcServer/npcs/items/paper.dart';
part 'npcServer/npcs/items/egg.dart';
part 'npcServer/npcs/items/plainbubble.dart';
part 'npcServer/npcs/items/plank.dart';

part 'npcServer/spritesheet.dart';
part 'npcServer/plants/plant.dart';
part 'npcServer/plants/tree.dart';
part 'npcServer/plants/fruittree.dart';
part 'npcServer/plants/beantree.dart';
part 'npcServer/plants/gasplant.dart';
part 'npcServer/plants/spiceplant.dart';
part 'npcServer/plants/papertree.dart';
part 'npcServer/plants/eggplant.dart';
part 'npcServer/plants/bubbletree.dart';
part 'npcServer/plants/woodtree.dart';

part 'npcServer/plants/rock.dart';
part 'npcServer/plants/berylrock.dart';
part 'npcServer/plants/sparklyrock.dart';
part 'npcServer/plants/dulliterock.dart';
part 'npcServer/plants/metalrock.dart';
part 'npcServer/quoin.dart';

//various http parts (as opposed to the previous websocket parts)
part 'util.dart';