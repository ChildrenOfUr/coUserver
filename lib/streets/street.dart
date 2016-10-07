library street;

import 'dart:io';
import 'dart:mirrors';
import 'dart:async';
import 'dart:math';

import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/entities/entity.dart';

import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';

part 'instancing.dart';

class Wall {
	String id;
	int x, y, width, height;
	Rectangle bounds;

	Wall(Map wall, Map layer, int groundY) {
		width = wall['w'];

		height = wall['h'];
		x = wall['x'] + layer['w'] ~/ 2 - width ~/ 2;
		y = wall['y'] + layer['h'] + groundY;
		id = wall['id'];

		bounds = new Rectangle(x, y, width, height);
	}

	@override
	toString() => "wall $id: " + bounds.toString();
}

class CollisionPlatform implements Comparable {
	Point start, end;
	String id;
	bool itemPerm = true,
		ceiling = false;
	Rectangle bounds;

	CollisionPlatform(Map platformLine, Map layer, int groundY) {
		id = platformLine['id'];
		ceiling = platformLine['platform_pc_perm'] == 1;

		(platformLine['endpoints'] as List).forEach((Map endpoint) {
			if (endpoint["name"] == "start") {
				start = new Point(endpoint["x"], endpoint["y"] + groundY);
				if (layer['name'] == 'middleground') {
					start = new Point(endpoint["x"] + layer['w'] ~/ 2, endpoint["y"] + layer['h'] + groundY);
				}
			}
			if (endpoint["name"] == "end") {
				end = new Point(endpoint["x"], endpoint["y"] + groundY);
				if (layer['name'] == 'middleground') {
					end = new Point(endpoint["x"] + layer['w'] ~/ 2, endpoint["y"] + layer['h'] + groundY);
				}
			}
		});

		int width = end.x - start.x;
		int height = end.y - start.y;
		bounds = new Rectangle(start.x, start.y, width, height);
	}

	@override
	String toString() {
		return "(${start.x},${start.y})->(${end.x},${end.y}) ceiling=$ceiling";
	}

	@override
	int compareTo(CollisionPlatform other) {
		return other.start.y - start.y;
	}
}

class DBStreet {
	@Field() String id, items;

	List<Item> get groundItems {
		return jsonx.decode(items, type: const jsonx.TypeHelper<List<Item>>().type);
	}

	void set groundItems(List<Item> value) {
		items = jsonx.encode(value);
	}

	@override
	String toString() {
		return "This is a DBStreet with an id of $id which has ${groundItems.length} items on it";
	}
}

class Street {
	static Map<String, Map> _jsonCache = {};
	static Map<String, bool> persistLock = {};
	List<CollisionPlatform> platforms = [];
	List<Wall> walls = [];
	int groundY = 0;
	Rectangle bounds;
	DateTime expires;
	Completer<bool> load;

	Map<String, Quoin> quoins = {};
	Map<String, Plant> plants = {};
	Map<String, NPC> npcs = {};
	Map<String, Door> doors = {};
	Map<String, Map> entityMaps;
	Map<String, Item> groundItems = {};
	Map<String, WebSocket> occupants = {};
	String label, tsid;

	Street(this.label, this.tsid) {
		load = new Completer();

		entityMaps = {"quoin":quoins, "plant":plants, "npc":npcs, "door":doors, "groundItem":groundItems};

		//attempt to load street occupants from database
		if (tsid != null && this is! StreetInstance) {
			loadEntities(tsid);
		}
	}

	Future loadEntities(String tsid) async {
		List<StreetEntity> entities = await StreetEntities.getEntities(tsid);

		if (entities.length == 0) {
			return;
		}

		putEntitiesInMemory(entities);
	}

	bool putEntitiesInMemory(List<StreetEntity> entities) {
		for (StreetEntity entity in entities) {
			String type = entity.type;
			num x = entity.x;
			num y = entity.y;
			num z = entity.z;
			num rotation = entity.rotation;
			bool h_flip = entity.h_flip;
			String id = entity.id;
			Map<String, String> metadata = entity.metadata;

			if (type == "Img" || type == "Mood" || type == "Energy" || type == "Currant"
				|| type == "Mystery" || type == "Favor" || type == "Time" || type == "Quarazy") {
				quoins[id] = new Quoin(id, x, y, type.toLowerCase());
			} else {
				try {
					ClassMirror classMirror = findClassMirror(type.replaceAll(" ", ""));
					if (classMirror.isSubclassOf(findClassMirror("NPC"))) {
						if (classMirror.isSubclassOf(findClassMirror("Vendor")) ||
							classMirror == findClassMirror("DustTrap")) {
							// Vendors and dust traps get a street name/TSID to check for collisions
							npcs[id] = classMirror
								.newInstance(new Symbol(""), [id, label, tsid, x, y, z, rotation, h_flip])
								.reflectee;
						} else {
							npcs[id] = classMirror
								.newInstance(new Symbol(""), [id, x, y, z, rotation, h_flip, label])
								.reflectee;
						}
						npcs[id].restoreState(metadata);
					}
					if (classMirror.isSubclassOf(findClassMirror("Plant"))) {
						plants[id] = classMirror
							.newInstance(new Symbol(""), [id, x, y, z, rotation, h_flip, label])
							.reflectee;
						plants[id].restoreState(metadata);
					}
					if (classMirror.isSubclassOf(findClassMirror("Door"))) {
						doors[id] = classMirror
							.newInstance(new Symbol(""), [id, label, x, y])
							.reflectee;
						doors[id].restoreState(metadata);
					}
				} catch (e) {
					Log.warning('Unable to instantiate a class for $type: $e');
					return false;
				}
			}
		}

		return true;
	}

	Future loadItems() async {
		PostgreSql dbConn = await dbManager.getConnection();

		String query = "SELECT * FROM streets WHERE id = @tsid";
		try {
			DBStreet dbStreet = (await dbConn.query(query, DBStreet, {'tsid':tsid})).first;
			dbStreet.groundItems.forEach((Item item) {
				item.putItemOnGround(item.x, item.y, label, id: item.item_id);
			});
		} catch (e) {
			//no street in the database
//			print("didn't load a street with tsid $tsid from the db: $e");
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	void loadJson({bool refreshCache: false}) {
		String _tsidG = tsidG(tsid);
		Map streetData = _jsonCache[_tsidG] ?? {};

		if (refreshCache || !_jsonCache.containsKey(_tsidG)) {
			streetData = MapData.getStreetFile(_tsidG);
			_jsonCache[_tsidG] = streetData;
		}

		groundY = -(streetData['dynamic']['ground_y'] as num).abs();
		bounds = new Rectangle(streetData['dynamic']['l'],
								   streetData['dynamic']['t'],
								   streetData['dynamic']['l'].abs() + streetData['dynamic']['r'].abs(),
								   (streetData['dynamic']['t'] - streetData['dynamic']['b']).abs());

		//For each layer on the street . . .
		for (Map layer in new Map.from(streetData['dynamic']['layers']).values) {
			for (Map platformLine in layer['platformLines']) {
				platforms.add(new CollisionPlatform(platformLine, layer, groundY));
			}

			platforms.sort((x, y) => x.compareTo(y));

			for (Map wall in layer['walls']) {
				if (wall['pc_perm'] == 0) {
					continue;
				}
				walls.add(new Wall(wall, layer, groundY));
			}
		}
	}

	Future persistState() async {
		if (tsid == null) {
			tsid = MapData.getStreetByName(label)[tsid];
			Log.warning('Persisting street <label=$label> with null tsid, but figured out <tsid=$tsid>');
			if (tsid == null) {
				Log.warning('Could not find tsid for <label=$label>');
				return;
			}
		}

		persistLock[label] = true;
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			//persist the ground items
			DBStreet dbStreet = new DBStreet()
				..id = tsid
				..groundItems = groundItems.values.toList() ?? [];
			String query = 'INSERT INTO streets(id,items) VALUES(@id,@items) ON CONFLICT (id) DO UPDATE SET items = @items';
			await dbConn.execute(query, dbStreet);

			//persist the entities
			List<StreetEntity> persistEntities = [];
			npcs.forEach((String id, NPC npc) {
				StreetEntity persistEntity = npc.persist();
				if (persistEntity != null) {
					persistEntities.add(persistEntity);
				}
			});
			plants.forEach((String id, Plant plant) {
				StreetEntity persistEntity = plant.persist();
				if (persistEntity != null) {
					persistEntities.add(persistEntity);
				}
			});

			await Future.forEach(persistEntities, (StreetEntity dbEntity) async {
				String query = 'UPDATE street_entities SET x = @x, y = @y, metadata_json = @metadata_json'
					' WHERE id = @id';
				await dbConn.execute(query, dbEntity);
			});

		} catch (e, st) {
			Log.error('Could not persist $tsid ($label). It may not have been loaded completely.', e, st);
		} finally {
			persistLock.remove(label);
			dbManager.closeConnection(dbConn);
		}
	}

	// Find the y of the nearest platform
	num getYFromGround(num currentX, num currentY, num width, num height) {
		num returnY = currentY;

		CollisionPlatform platform = _getBestPlatform(currentX, currentY, width, height);

		if (platform != null) {
			num goingTo = currentY + groundY;
			num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
			num yInt = platform.start.y - slope * platform.start.x;
			num lineY = slope * currentX + yInt;

			if (returnY == currentY || goingTo >= lineY) {
				returnY = lineY - groundY;
			}
		}

		return returnY;
	}

	//ONLY WORKS IF PLATFORMS ARE SORTED WITH
	//THE HIGHEST (SMALLEST Y VALUE) FIRST IN THE LIST
	///returns the platform line that the entity is currently standing
	///[posX] is the current x position of the entity
	///[width] and [height] are the width and height of their current animation
	CollisionPlatform _getBestPlatform(num posX, num cameFrom, num width, num height) {
		CollisionPlatform bestPlatform;
		num x = posX;
		num feetY = cameFrom + groundY;
		num bestDiffY = double.INFINITY;

		for (CollisionPlatform platform in platforms) {
			if (platform.ceiling) {
				continue;
			}

			if (x >= platform.start.x && x <= platform.end.x) {
				num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
				num yInt = platform.start.y - slope * platform.start.x;
				num lineY = slope * x + yInt;
				num diffY = (feetY - lineY).abs();

				if (bestPlatform == null) {
					bestPlatform = platform;
					bestDiffY = diffY;
				} else {
					if ((lineY >= feetY || (feetY > lineY && feetY - (height / 2) < lineY)) && diffY < bestDiffY) {
						bestPlatform = platform;
						bestDiffY = diffY;
					}
				}
			}
		}

		return bestPlatform;
	}
}
