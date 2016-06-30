part of weather;

/// Weather conditions (1 place, 1 time)
class WeatherData {
	/// City geo location
	@Field() Point<num> geoCoords;

	/// Weather condition id
	@Field() int weatherId;

	/// Group of weather parameters (Rain, Snow, Extreme etc.)
	@Field() String weatherMain;

	/// Weather condition within the group
	@Field() String weatherDesc;

	/// Weather icon id
	@Field() String weatherIcon;

	/// Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num mainTemp;

	/// Atmospheric pressure (on the sea level, if there is no sea_level or grnd_level data), hPa
	@Field() num mainPressure;

	/// Humidity, %
	@Field() num mainHumidity;

	/// Minimum temperature at the moment. This is deviation from current temp that is possible for @Field() large cities and megalopolises geographically expanded (use these parameter optionally). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	num mainTempMin;

	/// Maximum temperature at the moment. This is deviation from current temp that is possible for @Field() large cities and megalopolises geographically expanded (use these parameter optionally). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	num mainTempMax;

	/// Atmospheric pressure on the sea level, hPa
	@Field() num mainSeaLevelPressure;

	/// Atmospheric pressure on the ground level, hPa
	@Field() num mainGroundLevelPressure;

	/// Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour.
	@Field() num windSpeed;

	/// Wind direction, degrees (meteorological)
	@Field() num windDeg;

	/// Cloudiness, %
	@Field() num clouds;

	/// Rain volume for the last 3 hours
	@Field() num rainVol;

	/// Snow volume for the last 3 hours
	@Field() num snowVol;

	/// Time of data calculation, unix, UTC
	@Field() DateTime calcDate;

	/// Country code (GB, JP etc.)
	@Field() String countryCode;

	/// Sunrise time, unix, UTC
	@Field() DateTime sunrise;

	/// Sunset time, unix, UTC
	@Field() DateTime sunset;

	/// City ID
	@Field() int cityId;

	/// City name
	@Field() String cityName;

	/// Parse data from the OpenWeatherMap API
	WeatherData(Map owm) {
		if (owm['coord'] != null) {
			geoCoords = new Point(owm['coord']['lon'], owm['coord']['lat']);
		}

		weatherId = owm['weather'].single['id'];
		weatherMain = owm['weather'].single['main'];
		weatherDesc = owm['weather'].single['description'];
		weatherIcon = WeatherService.OWM_IMG + owm['weather'].single['icon'] + '.png';

		mainTemp = owm['main']['temp'];
		mainPressure = owm['main']['pressure'];
		mainHumidity = owm['main']['humidity'];
		mainTempMin = owm['main']['temp_min'];
		mainTempMax = owm['main']['temp_max'];
		mainSeaLevelPressure = owm['main']['sea_level'];
		mainGroundLevelPressure = owm['main']['ground_level'];

		windSpeed = owm['wind']['speed'];
		windDeg = owm['wind']['deg'];

		clouds = owm['clouds']['all'];

		rainVol = (owm['rain'] != null ? owm['rain']['3h'] : 0);

		snowVol = (owm['snow'] != null ? owm['snow']['3h'] : 0);

		calcDate = new DateTime.fromMillisecondsSinceEpoch(
			owm['dt'] * 1000, isUtc: true);

		countryCode = owm['sys']['country'];

		if (owm['sys']['sunrise'] != null) {
			sunrise = new DateTime.fromMillisecondsSinceEpoch(
				owm['sys']['sunrise'] * 1000, isUtc: true);
		}

		if (owm['sys']['sunset'] != null) {
			sunset = new DateTime.fromMillisecondsSinceEpoch(
				owm['sys']['sunset'] * 1000, isUtc: true);
		}

		cityId = owm['id'];
		cityName = owm['name'];
	}
}
