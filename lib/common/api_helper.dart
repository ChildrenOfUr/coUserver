library api_helper;

import 'dart:async';

import 'package:coUserver/common/util.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone_mapper_pg/manager.dart';

class ApiAccess {
	@Field()
	int id;
	@Field()
	int user_id;
	@Field()
	String api_token;
	@Field()
	int access_count = 0;

	@override
	String toString() => 'api_token: $api_token, access_count: $access_count';
}

class _ResponseBody {
	@Field()
	bool ok;
	@Field()
	String error;
	@Field()
	List<Map> results;
	@Field()
	Map result;
}

@app.ErrorHandler(API.METHOD_NOT_ALLOWED)
handleMethodNotAllowedError() => API.createResponse(error: 'Method Not Allowed');

@app.ErrorHandler(API.NOT_FOUND)
handleNotFoundError() => API.createResponse(error: 'Not Found');

////verify that the user isn't spamming api calls
//@app.Interceptor(r'/.*', chainIdx: 1)
//Future rateLimiter() async {
//	if (await API.canCallApi(app.request.headers['api-token'])) {
//		await app.chain.next();
//	} else {
//		return API.createResponse(error: 'Rate limit exceeded',
//			statusCode: API.TOO_MANY_REQUESTS);
//	}
//}

class API {
	static const int OK = 200;
	static const int CREATED = 201;
	static const int ACCEPTED = 202;
	static const int NOT_FOUND = 404;
	static const int METHOD_NOT_ALLOWED = 405;
	static const int TOO_MANY_REQUESTS = 429;

	static const int API_CALLS_PER_DURATION = 1000;
	static final Duration API_RESET_DURATION = new Duration(minutes: 15);
	static final Duration API_SAVE_DURATION = new Duration(minutes: 1);

	static Map<String, ApiAccess> _accessCache = {};
	static Timer apiResetTimer = new Timer.periodic(API_RESET_DURATION, (Timer timer) => _resetApiAccess());
	static Timer apiSaveTimer = new Timer.periodic(API_SAVE_DURATION, (Timer timer) => _saveApiAccess());

	static Future<bool> canCallApi(String apiToken) async {
		//kick start the reset timer declared above
		apiResetTimer.isActive;
		apiSaveTimer.isActive;

		if (apiToken == null) {
			return false;
		}

		ApiAccess access = _accessCache[apiToken];

		if (access == null) {
			String query = "SELECT * FROM api_access WHERE api_token = @apiToken";
			PostgreSql dbConn = await dbManager.getConnection();
			try {
				List<ApiAccess> accesses = await dbConn.query(
					query, ApiAccess,{'api_token': apiToken});
				if (accesses.length > 0) {
					access = accesses.first;
					_accessCache[apiToken] = access;
				}
			} catch (ex) {
				return false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}

		if (access.access_count < API_CALLS_PER_DURATION) {
			access.access_count++;
			return true;
		} else {
			return false;
		}
	}

	static Future loadApiAccess() async {
		String query = "SELECT * FROM api_access";
		_accessCache = {};
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			List<ApiAccess> accesses = await dbConn.query(query, ApiAccess);
			for (ApiAccess access in accesses) {
				_accessCache[access.api_token] = access;
			}
		} catch (e, st) {
			Log.error('Unable to load API access table. Will initialize with'
				      ' an empty set', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future _saveApiAccess() async {
		String query = "UPDATE api_access SET access_count = @access_count"
		               " WHERE api_token = @api_token";
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			//save all the non-0 entries
			_accessCache.forEach((String apiKey, ApiAccess access) {
				if (access.access_count > 0) {
					dbConn.execute(query, access);
				}
			});
		} catch (e, st) {
			Log.error('Unable to save all the api_access entries', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future _resetApiAccess() async {
		String query = "UPDATE api_access SET access_count = 0";
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			dbConn.execute(query);
		} catch (e, st) {
			Log.error('Unable to reset all the api_access entries', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
			_accessCache.forEach((String api_token, ApiAccess access) {
				access.access_count = 0;
			});
		}
	}

	static Map _getEncoded(var response) {
		String error = null;
		try {
			response = encode(response);
			if (response is! Map) {
				if (response is List) {
					for (var thing in response) {
						if (thing is! Map) {
							error = '${thing.runtimeType} is not an Encodable class. This is a bug.';
							response = null;
							break;
						}
					}
				}
			}
		} catch (ex) {
			error = '${response.runtimeType} is not an Encodable class. This is a bug.';
			response = null;
		}
		return {'response': response, 'error': error};
	}

	///[result] can be a Map, List<Map>, an encodable object or a list
	///of encodable objects.
	static Future<shelf.Response> createResponse({var result: null,
	                                              String error: null,
	                                              int statusCode: 200}) async {
		if (result != null && result is! Map) {
			bool needToEncode = false;
			if (result is List) {
				for (var thing in result) {
					if (thing is! Map) {
						needToEncode = true;
						break;
					}
				}
			} else {
				needToEncode = true;
			}

			if (needToEncode) {
				Map mappedResult = _getEncoded(result);
				result = mappedResult['response'];
				error = mappedResult['error'];
			}
		}

		_ResponseBody body = new _ResponseBody();
		body.ok = error == null;

		if (error != null) {
			body.error = error;
		}
		if (result != null) {
			if (result is List) {
				body.results = result;
			} else {
				body.result = result;
			}
		}

		Map headers = _getChangeHeaders(result);
		Map encodedBody = encode(body);
		shelf.Response response = await app.chain.createResponse(
			statusCode,
			responseValue: encodedBody);
		return response.change(headers: headers);
	}

	///This will attempt to guess the resource location that the object was
	///placed at (for POST/PUT) and add a relevant Location header to the
	///response.
	static Map<String, String> _getChangeHeaders(var object) {
		Map headers = {};
		if ((app.request.method != app.POST && app.request.method != app.PUT) ||
		    object is! Map || !object.containsKey('id')) {
			return headers;
		}

		String method = app.request.url.toString();
		int queryIndex = method.indexOf('?');
		if (queryIndex != -1) {
			method = method.substring(0, queryIndex);
		}
		String location = '${app.request.handlerPath}$method/${object['id']}';
		headers['location'] = location;
		return headers;
	}
}