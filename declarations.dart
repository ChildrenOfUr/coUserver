library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import "package:http/http.dart" as http;
import "package:http_server/http_server.dart";
import "package:intl/intl.dart";

part 'server.dart';

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
part 'npcServer/spritesheet.dart';
part 'npcServer/plants/plant.dart';
part 'npcServer/plants/tree.dart';
part 'npcServer/plants/fruittree.dart';
part 'npcServer/plants/beantree.dart';
part 'npcServer/plants/rock.dart';
part 'npcServer/plants/berylrock.dart';
part 'npcServer/plants/sparklyrock.dart';
part 'npcServer/plants/dulliterock.dart';
part 'npcServer/plants/metalrock.dart';

//various http parts (as opposed to the previous websocket parts)
part 'web/stress_test.dart';

part 'multiplayerServer/gps.dart';

part 'util.dart';