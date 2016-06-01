library coUserver;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:harvest/harvest.dart' as harvest;
import 'package:http/http.dart' as http;
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/console.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/keep_alive.dart';
import 'package:coUserver/common/slack.dart';
import 'package:coUserver/common/stat_buffer.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/chat_handler.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/endpoints/status.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/endpoints/weather.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/player_update_handler.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/street_update_handler.dart';

// Various service endpoints
part 'package:coUserver/endpoints/elevation.dart';
part 'package:coUserver/endpoints/getentities.dart';
part 'package:coUserver/endpoints/getitems.dart';
part 'package:coUserver/endpoints/report.dart';
part 'package:coUserver/endpoints/slack.dart';
part 'package:coUserver/endpoints/usernamecolors.dart';
part 'package:coUserver/endpoints/users.dart';

// Contains the main() method to start the server
part 'package:coUserver/server.dart';

// Handle incoming websocket messages
final Map<String, dynamic> HANDLERS = {
	'chat': ChatHandler,
	'metabolics': MetabolicsEndpoint,
	'playerUpdate': PlayerUpdateHandler,
	'quest': QuestEndpoint,
	'streetUpdate': StreetUpdateHandler,
	'weather': WeatherEndpoint
};

// Port for app (redstone routing)
final int REDSTONE_PORT = 8181;

// Port for websocket listeners/handlers
final int WEBSOCKET_PORT = 8282;
