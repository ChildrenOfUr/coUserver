part of weather;

/// Weather conditions (1 place, 1 time)
class WeatherData {
	/// Convert Kelvin temps to Fahrenheit temps
	static num kelvinToFahrenheit(num kelvin) => ((kelvin * (9/5)) - 459.67);

	/// City geo location latitude
	@Field() num latitude;

	/// City geo location longitude
	@Field() num longitude;

	/// Weather condition id
	@Field() int weatherId;

	/// Group of weather parameters (Rain, Snow, Extreme etc.)
	@Field() String weatherMain;

	/// Weather condition within the group
	@Field() String weatherDesc;

	/// Weather icon id
	@Field() String weatherIcon;

	/// Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num temp;

	/// Min temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempMin;

	/// Max temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempMax;

	/// Day temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempDay;

	/// Night temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempNight;

	/// Evening temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempEve;

	/// Morning temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
	@Field() num tempMorn;

	/// Humidity, %
	@Field() num humidity;

	/// Atmospheric pressure (on the sea level, if there is no sea_level or grnd_level data), hPa
	@Field() num pressure;

	/// Atmospheric pressure on the sea level, hPa
	@Field() num seaLevelPressure;

	/// Atmospheric pressure on the ground level, hPa
	@Field() num groundLevelPressure;

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
	DateTime calcDate;
	@Field() String get calcDateTxt => calcDate.toString();

	/// Country code (GB, JP etc.)
	@Field() String countryCode;

	/// Sunrise time, unix, UTC
	DateTime sunrise;
	@Field() String get sunriseTxt => sunrise.toString();
	@Field() set sunriseTxt(String _txt) => sunrise = DateTime.parse(_txt);

	/// Sunset time, unix, UTC
	DateTime sunset;
	@Field() String get sunsetTxt => sunset.toString();
	@Field() set sunsetTxt(String _txt) => sunset = DateTime.parse(_txt);

	/// City ID
	@Field() int cityId;

	/// City name
	@Field() String cityName;

	/// Parse data from the OpenWeatherMap API
	WeatherData(Map owm) {
		if (owm['coord'] != null) {
			longitude = owm['coord']['lon'];
			latitude = owm['coord']['lat'];
		}

		weatherId = owm['weather'].single['id'];
		weatherMain = owm['weather'].single['main'];
		weatherDesc = owm['weather'].single['description'];
		weatherIcon = WeatherService.OWM_IMG + owm['weather'].single['icon'] + '.png';

		if (owm['main'] != null) {
			temp = kelvinToFahrenheit(owm['main']['temp']);
			tempMin = kelvinToFahrenheit(owm['main']['temp_min']);
			tempMax = kelvinToFahrenheit(owm['main']['temp_max']);
		} else if (owm['temp'] != null) {
			tempMin = kelvinToFahrenheit(owm['temp']['min']);
			tempMax = kelvinToFahrenheit(owm['temp']['max']);
			temp = ((tempMin + tempMax) / 2);
			tempDay = kelvinToFahrenheit(owm['temp']['day']);
			tempNight = kelvinToFahrenheit(owm['temp']['night']);
			tempEve = kelvinToFahrenheit(owm['temp']['eve']);
			tempMorn = kelvinToFahrenheit(owm['temp']['morn']);
		}

		humidity = owm['humidity'] ?? owm['main']['humidity'];

		pressure = owm['pressure'] ?? owm['main']['pressure'];
		seaLevelPressure = (owm['main'] != null ? owm['main']['sea_level'] : 0);
		groundLevelPressure = (owm['main'] != null ? owm['main']['ground_level'] : 0);

		windSpeed = (owm['wind'] != null ? owm['wind']['speed'] : 0);
		windDeg = (owm['wind'] != null ? owm['wind']['deg'] : 0);

		if (owm['clouds'] != null && owm['clouds'] is num) {
			clouds = owm['clouds'];
		} else if (owm['clouds'] != null && owm['clouds'] is Map) {
			clouds = owm['clouds']['all'];
		} else {
			clouds = 0;
		}

		if (owm['rain'] != null && owm['rain'] is num) {
			rainVol = owm['rain'];
		} else if (owm['rain'] != null && owm['rain'] is Map) {
			rainVol = owm['rain']['3h'];
		} else {
			rainVol = 0;
		}

		if (owm['snow'] != null && owm['snow'] is num) {
			snowVol = owm['snow'];
		} else if (owm['snow'] != null && owm['snow'] is Map) {
			snowVol = owm['snow']['3h'];
		} else {
			snowVol = 0;
		}

		calcDate = new DateTime.fromMillisecondsSinceEpoch(owm['dt'] * 1000, isUtc: true);

		if (owm['sys'] != null) {
			countryCode = owm['sys']['country'];

			if (owm['sys']['sunrise'] != null) {
				sunrise = new DateTime.fromMillisecondsSinceEpoch(
					owm['sys']['sunrise'] * 1000, isUtc: true);
			}

			if (owm['sys']['sunset'] != null) {
				sunset = new DateTime.fromMillisecondsSinceEpoch(
					owm['sys']['sunset'] * 1000, isUtc: true);
			}
		}

		cityId = owm['id'];
		cityName = owm['name'];
	}
}
