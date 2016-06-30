part of weather;

/// Current and forecast conditions for a location.
class WeatherLocation {
	/// Current conditions
	@Field() WeatherData current;

	/// Forecast conditions
	@Field() List<WeatherData> forecast;

	/// Decode to object
	WeatherLocation({this.current, List<WeatherData> forecast: const []}) {
		assert(current != null);

		if (forecast.length == 0 || forecast.length == 5) {
			// Empty or 5-day forecast
			this.forecast = forecast;
		} else {
			// Forecast contains multiple times per day

			// Maps day number to data for times on that day
			Map<int, List<WeatherData>> timesOnDays = {};

			// Forecast for only 5 days
			List<WeatherData> days = [];

			// Split forecast times by day
			forecast.forEach((WeatherData time) {
				if (timesOnDays[time.calcDate.day] == null) {
					timesOnDays[time.calcDate.day] = [];
				}

				timesOnDays[time.calcDate.day].add(time);
			});

			// Take only the first 5 days
			for (int d = 0; d < 5; d++) {
				// Times with data on this day
				List<WeatherData> times = timesOnDays.values.toList()[d];

				// Use the middle data point as the forecast for the day
				days.add(times[times.length ~/ 2]);
			}

			this.forecast = days;
		}
	}

	/// City geo location
	Point<num> get geoCoords => current.geoCoords;

	/// City ID
	int get cityId => current.cityId;

	/// City name
	String get cityName => current.cityName;

	/// Sunrise time, unix, UTC
	DateTime get sunrise => current.sunrise;

	/// Sunset time, unix, UTC
	DateTime get sunset => current.sunset;
}
