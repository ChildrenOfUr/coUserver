part of street_entities;

abstract class StreetEntityMigrations {
	static Future<int> migrateEntities() async {
		Directory streetEntities = new Directory('./streetEntities');
		List<FileSystemEntity> files = streetEntities.listSync();

		int count = 0;

		await Future.forEach(files, (FileSystemEntity file) async {
			if (file is File) {
				String tsid = file.uri.pathSegments.last;
				String json = await file.readAsString();
				try {
					Log.verbose('Migrating $tsid...');
					Map<String, dynamic> map = JSON.decode(json);
					await Future.forEach(map['entities'], (Map<String, dynamic> entity) async {
						await StreetEntities.setEntity(new StreetEntity.create(
							id: createId(entity['x'], entity['y'], entity['type'], tsidL(tsid)),
							type: entity['type'],
							tsid: tsid,
							x: entity['x'],
							y: entity['y']
						), loadNow: false);
						count++;
					});
				} catch (e) {
					Log.warning('Error migrating $tsid', e);
				}
			}
		});

		return count;
	}

	static Future<int> reIdEntities() async {
		PostgreSql dbConn = await dbManager.getConnection();

		int rows = 0;
		try {
			List<StreetEntity> entities = await dbConn.query(
				'SELECT * FROM street_entities', StreetEntity);

			await Future.forEach(entities, (StreetEntity entity) async {
				String newId = createId(entity.x, entity.y, entity.type, entity.tsid);
				Log.verbose('Changing ${entity.id} to ${newId}');

				try {
					String updateQuery = 'UPDATE street_entities'
						' SET id = @new WHERE id = @old';
					int result = await dbConn.execute(updateQuery,
						{'old': entity.id, 'new': newId});
					rows += result;
				} catch (e) {
					Log.warning('Skipping ${entity.id} due to database error', e);
				}
			});
		} catch (e, st) {
			Log.error('Error changing entity IDs', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
			return rows;
		}
	}
}
