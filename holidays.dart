part of coUserver;

@app.Route('/getHolidays')
Future<List<String>> getHolidays(@app.QueryParam('month') int month,
                                 @app.QueryParam('day') int day) async
{
	List<String> holidays = ["foo","bar"];

	return holidays;
}