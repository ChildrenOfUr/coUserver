library street_entities;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';

part 'balancer.dart';
part 'street_entity.dart';

class StreetEntities {
	static final String TABLE = 'street_entities';

	static Future<List<StreetEntity>> getEntities(String tsid) async {
		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = 'SELECT * '
				'FROM $TABLE '
				'WHERE tsid = @tsid';

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {'tsid': tsid});

			return rows;
		} catch (e) {
			log('Could not get entities for $tsid: $e');
			return new List();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<StreetEntity> getEntity(String entityId) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = 'SELECT * '
				'FROM $TABLE '
				'WHERE id = @entityId';

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {'entityId': entityId});

			return rows.single;
		} catch(e) {
			log('Could not get entity $entityId: $e');
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> setEntity(StreetEntity entity, {bool loadNow: true}) async {
		Future<bool> _setInDb(StreetEntity entity) async {
			PostgreSql dbConn = await dbManager.getConnection();

			try {
				String query = 'INSERT INTO $TABLE (id, type, tsid, x, y, metadata_json) '
					'VALUES (@id, @type, @tsid, @x, @y, @metadata_json) '
					'ON CONFLICT (id) DO UPDATE '
					'SET tsid = @tsid, x = @x, y = @y, metadata_json = @metadata_json';

				int result = await dbConn.execute(
					query, encode(entity));

				return (result == 1);
			} catch (e) {
				log('Could not edit entity $entity: $e');
				return false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}

		bool _setInMemory(StreetEntity entity) {
			Map<String, dynamic> street = getStreetByTsid(entity.tsid);
			if (street != null) {
				try {
					// Create NPC
					String id = 'n' + createId(entity.x, entity.x, entity.type, entity.tsid);
					ClassMirror mirror = findClassMirror(entity.type);
					NPC npc = mirror.newInstance(new Symbol(''),
						[entity.id, entity.x, entity.y, street['label']]).reflectee;

					// Load onto street
					StreetUpdateHandler.streets[street["label"]].npcs.addAll({id: npc});
				} catch (e) {
					log('Error loading new entity $entity: $e');
				}
				return true;
			} else {
				return false;
			}
		}

		if (!(await _setInDb(entity))) {
			return false;
		} else if (loadNow) {
			return _setInMemory(entity);
		} else {
			return true;
		}
	}

	static Future<int> migrateEntities() async {
		Directory streetEntities = new Directory('./streetEntities');
		List<FileSystemEntity> files = streetEntities.listSync();

		int count = 0;

		await Future.forEach(files, (FileSystemEntity file) async {
			if (file is File) {
				String tsid = file.uri.pathSegments.last;
				String json = await file.readAsString();
				try {
					log('Migrating $tsid...');
					Map<String, dynamic> map = JSON.decode(json);
					await Future.forEach(map['entities'], (Map<String, dynamic> entity) async {
						await StreetEntities.setEntity(new StreetEntity.create(
							id: 'migrate$count',
							type: entity['type'],
							tsid: tsid,
							x: entity['x'],
							y: entity['y']
						), loadNow: false);
						count++;
					});
				} catch (e) {
					log('    Error migrating $tsid: $e');
				}
			}
		});

		return count;
	}
}
