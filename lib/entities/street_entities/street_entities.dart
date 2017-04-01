library street_entities;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';

part 'balancer.dart';
part 'migrations.dart';
part 'street_entity.dart';

class StreetEntities {
	static final String TABLE = 'street_entities';

	static Future<List<StreetEntity>> getEntities(String tsid) async {
		try {
			if (tsid == null) {
				throw new ArgumentError('tsid must not be null');
			}
		} catch (e, st) {
			Log.error("Error getting entities for tsid '$tsid'", e, st);
			return new List();
		}

		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = 'SELECT * '
				'FROM $TABLE '
				'WHERE tsid = @tsid';

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {'tsid': tsid});

			return rows;
		} catch (e, st) {
			Log.error('Could not get entities for $tsid', e, st);
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
		} catch (e, st) {
			Log.error('Could not get street entity $entityId', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> setEntity(StreetEntity entity, {bool loadNow: true, bool loadDb: true}) async {
		Future<bool> _setInDb(StreetEntity entity) async {
			PostgreSql dbConn = await dbManager.getConnection();

			try {
				String query = 'INSERT INTO $TABLE (id, type, tsid, x, y, z, h_flip, rotation, metadata_json) '
					'VALUES (@id, @type, @tsid, @x, @y, @z, @h_flip, @rotation, @metadata_json) '
					'ON CONFLICT (id) DO UPDATE '
					'SET tsid = @tsid, x = @x, y = @y, z = @z, h_flip = @h_flip, rotation = @rotation, metadata_json = @metadata_json';

				int result = await dbConn.execute(
					query, entity);

				return (result == 1);
			} catch (e, st) {
				Log.error('Could not edit entity $entity', e, st);
				return false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}

		bool _setInMemory(StreetEntity entity) {
			Map<String, dynamic> street = MapData.getStreetByTsid(entity.tsid);
			if (street != null) {
				//if the street isn't currently loaded, then just return
				if (StreetUpdateHandler.streets[street["label"]] == null) {
					Log.warning('Tried to set entity <id=${entity.id}> on unloaded street <tsid=${entity.tsid}>');
					return true;
				}

				return StreetUpdateHandler.streets[street['label']].putEntitiesInMemory([entity]);
			}

			return false;
		}

		if (loadDb && !(await _setInDb(entity))) {
			return false;
		}

		if (loadNow && !(await _setInMemory(entity))) {
			return false;
		}

		return true;
	}

	static Future<bool> deleteEntity(String entityId) async {
		Future<bool> _deleteFromDb() async {
			PostgreSql dbConn = await dbManager.getConnection();
			try {
				String query = 'DELETE FROM $TABLE WHERE id = @id';
				int result = await dbConn.execute(query, {'id': entityId});
				return (result == 1);
			} catch (e, st) {
				Log.error('Could not delete entity ${entityId} from database', e, st);
				return false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}

		Future<bool> _deleteFromMemory() async {
			try {
				StreetUpdateHandler.queueNpcRemove(entityId);
				return true;
			} catch (e, st) {
				Log.error('Could not delete entity ${entityId} from memory', e, st);
				return false;
			}
		}

		if (!(await _deleteFromDb())) {
			return false;
		} else {
			return _deleteFromMemory();
		}
	}
}
