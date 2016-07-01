part of weather;

/// Current and forecast conditions for a location.
class WeatherLocation {
	/// Current conditions
	@Field() WeatherData current;

	/// Forecast conditions
	@Field() List<WeatherData> forecast;

	/// Decode to object
	WeatherLocation(this.current, this.forecast);

	/// City geo location latitude
	num get latitude => current.latitude;

	/// City geo location longitude
	num get longitude => current.longitude;

	/// City ID
	int get cityId => current.cityId;

	/// City name
	String get cityName => current.cityName;

	/// Sunrise time, unix, UTC
	DateTime get sunrise => current.sunrise;

	/// Sunset time, unix, UTC
	DateTime get sunset => current.sunset;
}
