library coUserver;

import "dart:io";
import "dart:async";
import "dart:convert";
import "dart:math" hide log;

import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/common/stat_buffer.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/keep_alive.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/chat_handler.dart';
import 'package:coUserver/player_update_handler.dart';
import 'package:coUserver/endpoints/time.dart';
import 'package:coUserver/auctions/auctions_service.dart';

import "package:intl/intl.dart";
import "package:slack/io/slack.dart" as slack;
import 'package:redstone/redstone.dart' as app;
import "package:redstone_mapper/plugin.dart";
import "package:http/http.dart" as http;
import "package:harvest/harvest.dart" as harvest;

//contains the main() method to start the server
part "gameServer/server.dart";

//various service endpoints
part "lib/endpoints/weather.dart";
part "lib/endpoints/usernamecolors.dart";

// bug reporting
part "package:coUserver/common/report.dart";

// dev/guide labels
part "package:coUserver/common/elevation.dart";