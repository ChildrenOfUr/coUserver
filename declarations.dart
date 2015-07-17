library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import "package:intl/intl.dart";
import "package:slack/io/slack.dart" as slack;
import "package:postgresql/postgresql.dart";
import "package:redstone/server.dart" as app;
import 'package:logging/logging.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;
import 'package:http/src/multipart_request.dart';
import 'package:http/src/multipart_file.dart';
import 'package:http/src/streamed_response.dart';
import 'package:image/image.dart';
import 'package:crypto/crypto.dart';

//contains the main() method to start the server
part 'server.dart';
part 'API_KEYS.dart';

//various service endpoints
part 'auctions_service.dart';
part 'metabolics.dart';
part 'weather.dart';
part 'holidays.dart';

//common to all server parts
part 'common/identifier.dart';
part 'common/stat_buffer.dart';

//chat server parts
part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'chatServer/chat_handler.dart';

//multiplayer server parts
part 'multiplayerServer/player_update_handler.dart';

//npc server (street simulation) parts
part 'npcServer/street_update_handler.dart';
part 'npcServer/street.dart';
part 'npcServer/npcs/animals/piggy.dart';
part 'npcServer/entity.dart';
part 'npcServer/npcs/npc.dart';

// vendors
part 'npcServer/npcs/vendors/streetspiritgroddle.dart';
part 'npcServer/npcs/vendors/streetspiritfirebog.dart';
part 'npcServer/npcs/vendors/streetspiritzutto.dart';
part 'npcServer/npcs/vendors/toolvendor.dart';
part 'npcServer/npcs/vendors/mealvendor.dart';
part 'npcServer/npcs/vendors/jabba_helga.dart';
part 'npcServer/npcs/vendors/jabba_unclefriendly.dart';
part 'npcServer/npcs/vendors/vendor.dart';

// animals
part 'npcServer/npcs/animals/chicken.dart';
part 'npcServer/npcs/animals/helikitty.dart';
part 'npcServer/npcs/animals/butterfly.dart';
part 'npcServer/npcs/animals/firefly.dart';
part 'npcServer/npcs/animals/salmon.dart';

// shrines
part 'npcServer/npcs/shrines/shrine.dart';
part 'npcServer/npcs/shrines/alph.dart';
part 'npcServer/npcs/shrines/friendly.dart';
part 'npcServer/npcs/shrines/cosma.dart';
part 'npcServer/npcs/shrines/grendaline.dart';
part 'npcServer/npcs/shrines/humbaba.dart';
part 'npcServer/npcs/shrines/lem.dart';
part 'npcServer/npcs/shrines/mab.dart';
part 'npcServer/npcs/shrines/pot.dart';
part 'npcServer/npcs/shrines/spriggan.dart';
part 'npcServer/npcs/shrines/tii.dart';
part 'npcServer/npcs/shrines/zille.dart';

//items
part 'npcServer/items/item.dart';

// plants
part 'npcServer/plants/plant.dart';
part 'npcServer/plants/trees/tree.dart';
part 'npcServer/plants/trees/fruittree.dart';
part 'npcServer/plants/trees/beantree.dart';
part 'npcServer/plants/trees/gasplant.dart';
part 'npcServer/plants/trees/spiceplant.dart';
part 'npcServer/plants/trees/papertree.dart';
part 'npcServer/plants/trees/eggplant.dart';
part 'npcServer/plants/trees/bubbletree.dart';
part 'npcServer/plants/trees/woodtree.dart';

// resources
part 'npcServer/plants/dirtpile.dart';
part 'npcServer/plants/peatbog.dart';
part 'npcServer/plants/mortarbarnacle.dart';
part 'npcServer/plants/jellisacgrowth.dart';
part 'npcServer/plants/icenubbin.dart';

// rocks
part 'npcServer/plants/rocks/rock.dart';
part 'npcServer/plants/rocks/berylrock.dart';
part 'npcServer/plants/rocks/sparklyrock.dart';
part 'npcServer/plants/rocks/dulliterock.dart';
part 'npcServer/plants/rocks/metalrock.dart';

// doors
part 'npcServer/doors/door.dart';
part 'npcServer/doors/bureaucratic_hall_door.dart';
part 'npcServer/doors/machine_room_door.dart';
part 'npcServer/doors/shoppe_door.dart';

// misc
part 'npcServer/npcs/mailbox.dart';
part 'npcServer/npcs/auctioneer.dart';
part 'npcServer/spritesheet.dart';
part 'npcServer/quoin.dart';

//various http parts (as opposed to the previous websocket parts)
part 'util.dart';
part 'auction.dart';
part 'inventory.dart';