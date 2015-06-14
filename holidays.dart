part of coUserver;

@app.Route('/getHolidays')
Future<List<String>> getHolidays(@app.QueryParam('month') int month,
                                 @app.QueryParam('day') int day) async
{
	String monthName = monthNames[month];
	Map<int, List<String>> holidaysForMonth = holidaysByMonth[monthName];
	List<String> holidaysForDay = holidaysForMonth[day];

	return holidaysForDay;
}

Map<int, String> monthNames = {0:'Primuary', 1:'Spork', 2:'Bruise', 3:'Candy', 4:'Fever',
	5:'Junuary', 6:'Septa', 7:'Remember', 8:'Doom', 9:'Widdershins',
	10:'Eleventy', 11:'Recurse'};

Map<String, Map<int, List<String>>> holidaysByMonth = {'Primuary': {5:['AlphaCon']},
	'Spork':{2:['Lemadan']},
	'Bruise':{3:['Pot Twoday']},
	'Candy':{2:['Root'], 3:['Root'], 4:['Root'], 11:['Sprinkling']},
	'Fever':{},
	'Junuary':{17:['Croppaday']},
	'Septa':{1:['Belabor Day']},
	'Remember':{25:['Zilloween'], 26:['Zilloween'], 27:['Zilloween'], 28:['Zilloween'], 29:['Zilloween'], 30:['Zilloween'], 31:['Zilloween'], 32:['Zilloween'], 33:['Zilloween'], 34:['Zilloween'], 35:['Zilloween'], 36:['Zilloween'], 37:['Zilloween']},
	'Doom':{},
	'Widdershins':{},
	'Eleventy':{11:['Recurse Eve']},
	'Recurse':{1:['Recurse']}};