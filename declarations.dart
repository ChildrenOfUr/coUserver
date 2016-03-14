library coUserver;

import "dart:io";
import "dart:async";
import "dart:convert";
import "dart:math";
import "dart:mirrors";

import "package:intl/intl.dart";
import "package:slack/io/slack.dart" as slack;
import 'package:redstone/redstone.dart' as app;
import "package:redstone_mapper/mapper.dart";
import "package:redstone_mapper/plugin.dart";
import "package:redstone_mapper_pg/manager.dart";
import "package:http/http.dart" as http;
import "package:http/src/multipart_request.dart";
import "package:http/src/multipart_file.dart";
import "package:http/src/streamed_response.dart";
import "package:image/image.dart";
import "package:crypto/crypto.dart";
import "package:harvest/harvest.dart" as harvest;
import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:path/path.dart' as path;
import 'package:postgresql/postgresql.dart';

//contains the main() method to start the server
part "gameServer/server.dart";
part "API_KEYS.dart";

//various service endpoints
part "gameServer/auctions/auctions_service.dart";
part "gameServer/endpoints/constants.dart";
part "gameServer/endpoints/metabolics/metabolics_endpoint.dart";
part "gameServer/endpoints/metabolics/metabolics.dart";
part "gameServer/endpoints/weather.dart";
part "gameServer/endpoints/holidays.dart";
part "gameServer/endpoints/letters.dart";
part "gameServer/endpoints/usernamecolors.dart";
part "gameServer/endpoints/visited.dart";

//quests
part 'gameServer/quests/messages.dart';
part "gameServer/quests/quest.dart";
part 'gameServer/quests/quest_service.dart';
part 'gameServer/quests/quest_endpoint.dart';
part 'common/user.dart';

// skills
part "gameServer/skills/skillsmanager.dart";
part "gameServer/skills/skill.dart";
part "gameServer/skills/playerskill.dart";

// achievements
part "gameServer/achievements/achievements.dart";
part "gameServer/achievements/achievement_checkers.dart";
part "gameServer/achievements/statsbased.dart";
part "gameServer/endpoints/stats.dart";

// upgrades
part "gameServer/upgrades/upgrade.dart";
part "gameServer/upgrades/upgrade_manager.dart";

//common to all server parts
part "common/identifier.dart";
part "common/stat_buffer.dart";

//chat server parts
part "chatServer/irc_relay.dart";
part "chatServer/keep_alive.dart";
part "chatServer/chat_handler.dart";

//multiplayer server parts
part "multiplayerServer/player_update_handler.dart";
part "multiplayerServer/login_date_tracker.dart";

//npc server (street simulation) parts
part "npcServer/street_update_handler.dart";
part "npcServer/street.dart";
part "npcServer/npcs/animals/piggy.dart";
part "npcServer/entity.dart";
part "npcServer/npcs/npc.dart";
part 'npcServer/flag.dart';

// vendors
part "npcServer/npcs/vendors/streetspiritgroddle.dart";
part "npcServer/npcs/vendors/streetspiritfirebog.dart";
part "npcServer/npcs/vendors/streetspiritzutto.dart";
part "npcServer/npcs/vendors/toolvendor.dart";
part "npcServer/npcs/vendors/mealvendor.dart";
part "npcServer/npcs/vendors/snoconevendingmachine.dart";
part "npcServer/npcs/vendors/jabba_helga.dart";
part "npcServer/npcs/vendors/jabba_unclefriendly.dart";
part "npcServer/npcs/vendors/vendor.dart";

// animals
part "npcServer/npcs/animals/chicken.dart";
part "npcServer/npcs/animals/helikitty.dart";
part "npcServer/npcs/animals/butterfly.dart";
part "npcServer/npcs/animals/firefly.dart";
part "npcServer/npcs/animals/salmon.dart";
part "npcServer/npcs/animals/batterfly.dart";

// shrines
part "npcServer/npcs/shrines/shrine.dart";
part "npcServer/npcs/shrines/alph.dart";
part "npcServer/npcs/shrines/friendly.dart";
part "npcServer/npcs/shrines/cosma.dart";
part "npcServer/npcs/shrines/grendaline.dart";
part "npcServer/npcs/shrines/humbaba.dart";
part "npcServer/npcs/shrines/lem.dart";
part "npcServer/npcs/shrines/mab.dart";
part "npcServer/npcs/shrines/pot.dart";
part "npcServer/npcs/shrines/spriggan.dart";
part "npcServer/npcs/shrines/tii.dart";
part "npcServer/npcs/shrines/zille.dart";

//items
part "npcServer/items/item.dart";
part "npcServer/items/actions/action.dart";
part "npcServer/items/item_user.dart";
part "npcServer/items/hellgrapes.dart";
part "npcServer/npcs/dust_trap.dart";
part "npcServer/npcs/vistingstone.dart";
part "npcServer/items/actions/recipes/recipe.dart";
part "npcServer/items/actions/recipes/recipebook.dart";
part "npcServer/items/actions/itemgroups/cubimals.dart";
part "npcServer/items/actions/itemgroups/emblems.dart";
part "npcServer/items/actions/itemgroups/milk-butter-cheese.dart";
part 'npcServer/items/actions/itemgroups/piggy_plop.dart';
part "npcServer/items/actions/itemgroups/orb.dart";
part "npcServer/items/actions/itemgroups/consume.dart";

// plants
part "npcServer/plants/plant.dart";
part "npcServer/plants/trees/tree.dart";
part "npcServer/plants/trees/fruittree.dart";
part "npcServer/plants/trees/beantree.dart";
part "npcServer/plants/trees/gasplant.dart";
part "npcServer/plants/trees/spiceplant.dart";
part "npcServer/plants/trees/papertree.dart";
part "npcServer/plants/trees/eggplant.dart";
part "npcServer/plants/trees/bubbletree.dart";
part "npcServer/plants/trees/woodtree.dart";

// resources
part "npcServer/plants/dirtpile.dart";
part "npcServer/plants/peatbog.dart";
part "npcServer/plants/mortarbarnacle.dart";
part "npcServer/plants/jellisacgrowth.dart";
part "npcServer/plants/icenubbin.dart";

// rocks
part "npcServer/plants/rocks/rock.dart";
part "npcServer/plants/rocks/berylrock.dart";
part "npcServer/plants/rocks/sparklyrock.dart";
part "npcServer/plants/rocks/dulliterock.dart";
part "npcServer/plants/rocks/metalrock.dart";

// doors
part "npcServer/doors/door.dart";
part "npcServer/doors/bureaucratic_hall_door.dart";
part "npcServer/doors/machine_room_door.dart";
part "npcServer/doors/shoppe_door.dart";
part "npcServer/doors/hollow_door.dart";

// misc
part "npcServer/npcs/mailbox.dart";
part "npcServer/npcs/auctioneer.dart";
part "npcServer/spritesheet.dart";
part "npcServer/quoin.dart";

// map data
part "common/mapdata/mapdata.dart";
part "common/mapdata/hubdata.dart";
part "common/mapdata/streetdata.dart";

//various http parts (as opposed to the previous websocket parts)
part "common/util.dart";
part "gameServer/auctions/auction.dart";
//part "gameServer/inventory.dart";
part "gameServer/inventory_new.dart";

// bug reporting
part "common/report.dart";

// dev/guide labels
part "common/elevation.dart";