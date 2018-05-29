part of weather;

/// Handles real-life weather data
class WeatherService {
	/// Image URL base
	static final String OWM_IMG = 'https://openweathermap.org/img/w/';

	/// OpenWeatherMap URL
	static final String OWM_API = 'http://api.openweathermap.org/data/2.5/';

	/// OpenWeatherMap endpoint parameters
	static final String OWM_PARAMS = '?appid=$openWeatherMap&id=';

	/// Refresh data from OpenWeatherMap every hour
	static final Timer cacheTimer = new Timer.periodic(
		new Duration(hours: 1), (_) => download());

	/// Weather data cache
	/// Key is OWM city ID
	static Map<int, WeatherLocation> cache = {};

	/// How long to wait in case of error for OWM service to recover
	static int deferredMins = 0;

	/// Time of last download (used to decrement deferredMins)
	static DateTime lastCheck;

	/// Return the weather data for a TSID, or null if the TSID does not have weather
	static Future<WeatherLocation> getConditions(String tsid, {bool usingHubId: false}) async {
		int cityId = getCityId(tsid, usingHubId: usingHubId);
		if (cityId != null) {
			return (cache[cityId] ?? (await download(cityId)));
		} else {
			return null;
		}
	}

	/// Return the weather data for a TSID as a Map
	static Future<Map<String, dynamic>> getConditionsMap(String tsid, {bool usingHubId: false}) async {
		WeatherLocation weather = await getConditions(tsid, usingHubId: usingHubId);
		if (weather != null) {
			return encode(weather);
		} else {
			return {'error': 'no_weather', (usingHubId ? 'hub_id' : 'tsid'): tsid};
		}
	}

	/// Get the city id for a TSID
	static int getCityId(String tsid, {bool usingHubId: false}) {
		try {
			Map<String, dynamic> street;

			if (!usingHubId) {
				street = MapData.getStreetByTsid(tsid);

				// Check street
				int streetCityId = street['owm_city_id'];
				if (streetCityId != null) {
					return streetCityId;
				}
			}

			// Check hub
			String hubId = usingHubId ? tsid : street['hub_id'].toString();
			Map<String, dynamic> hub = MapData.hubs[hubId];
			int hubCityId = hub['owm_city_id'];
			if (hubCityId != null) {
				return hubCityId;
			}

			// None set
			throw 'up';
		} catch (_) {
			return null;
		}
	}

	/// Update cached weather data from OpenWeatherMap
	/// Pass cityId to download for one city (and return the data),
	/// or not to refresh the entire cache (and return true)
	static Future download([int cityId]) async {
		/// Waiting for recovery?
		if (deferredMins > 0) {
			if (lastCheck == null) {
				lastCheck = new DateTime.now();
			}

			/// Decrement each minute
			if (lastCheck.minute < new DateTime.now().minute) {
				deferredMins--;
			}
			return null;
		} else {
			lastCheck = new DateTime.now();
		}

		/// Decode and return the result of calling either the 'weather' or 'forecast/daily' endpoint
		Future<Map> _owmDownload(String endpoint, int cityId) async {
			// Download from OpenWeatherMap
			String url = OWM_API + endpoint + OWM_PARAMS + cityId.toString();
			String json = (await http.get(url)).body;
			Map<String, dynamic> owm = jsonDecode(json);

			// Verify result
			var responseCode = owm['cod']; // 'cod' is not a typo (unless it's OWM's)
			if (int.parse(responseCode.toString()) != 200) {
				throw new HttpException('OWM API call returned $responseCode for $url');
			}

			return owm;
		}

		if (cityId == null) {
			// Download all cities
			await Future.forEach(cache.keys, (int cityId) async {
				await download(cityId);
			});
		} else {
			try {
				// Get current conditions
				WeatherData current = new WeatherData(await _owmDownload('weather', cityId));

				// Get forecast conditions
				List<WeatherData> forecast = [];
				List<Map> days = ((await _owmDownload('forecast/daily', cityId))['list']);
				days.sublist(1, 5).forEach((Map day) {
					forecast.add(new WeatherData(day));
				});

				// Assemble location data
				WeatherLocation weather = new WeatherLocation(current, forecast);

				// Add to cache
				cache[cityId] = weather;

				return weather;
			} catch (e) {
				Log.error('Error downloading weather for <cityId=$cityId>', e);
				deferredMins++;
				return null;
			}
		}
	}
}
