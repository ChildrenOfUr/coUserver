library time;

import 'dart:async';

import 'package:redstone/redstone.dart' as app;

@app.Route('/getHolidays')
Future<List<String>> getHolidays(@app.QueryParam('month') int month,
                                 @app.QueryParam('day') int day) async {
	List<String> holidays = [];

	String monthName = monthNames[month];
	Map<int, List<String>> holidaysForMonth = holidaysByMonth[monthName];
	if(holidaysForMonth[day] != null) {
		holidays.addAll(holidaysForMonth[day]);
	}

	return holidays;
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

class Clock {
	StreamController _newdayController, _timeupdateController;
	Stream onUpdate, onNewDay, onHoliday;
	String _dayofweek, _year, _day, _month, _time;
	int _dayInt, _monthInt;
	List _dPM = [29, 3, 53, 17, 73, 19, 13, 37, 5, 47, 11, 1];

	// Getters, so they can only be written by the Clock
	String get dayofweek => _dayofweek;

	String get year => _year;

	String get day => _day;

	String get month => _month;

	String get time => _time;

	List<int> get daysPerMonth => _dPM;

	// Integer versions
	int get dayInt => _dayInt;

	int get monthInt => _monthInt;

	Clock() {
		_newdayController = new StreamController.broadcast();
		_timeupdateController = new StreamController.broadcast();
		onUpdate = _timeupdateController.stream;
		onNewDay = _newdayController.stream;

		_sendEvents();
		// Time update Timer.
		new Timer.periodic(new Duration(seconds: 1), (_) => _sendEvents());
	}

	// timer has updated, send out required events and update interfaces.
	void _sendEvents() {

		// Year, month, day, week, time
		List data = _getDate();

		_dayofweek = data[3];
		_time = data[4];
		_day = data[2];
		_month = data[1];
		_year = data[0];

		_dayInt = data[5];
		_monthInt = data[6];

		// Clock update stream
		_timeupdateController.add([time, day, dayofweek, month, year, dayInt, monthInt]);

		// New Day update stream
		if(time == '6:00am') {
			_newdayController.add('new day!');
		}
	}

	List _Months = const ['Primuary', 'Spork', 'Bruise', 'Candy', 'Fever', 'Junuary', 'Septa', 'Remember', 'Doom', 'Widdershins', 'Eleventy', 'Recurse'];
	List _Days_of_Week = const ['Hairday', 'Moonday', 'Twoday', 'Weddingday', 'Theday', 'Fryday', 'Standday', 'Fabday'];

	List _getDate() {
		//
		// there are 4435200 real seconds in a game year
		// there are 14400 real seconds in a game day
		// there are 600 real seconds in a game hour
		// there are 10 real seconds in a game minute
		//

		//
		// how many real seconds have elapsed since game epoch?
		//
		int ts = (new DateTime.now().millisecondsSinceEpoch * 0.001).floor();
		int sec = ts - 1238562000;

		int year = (sec / 4435200).floor();
		sec -= year * 4435200;

		int day_of_year = (sec / 14400).floor();
		sec -= day_of_year * 14400;

		int hour = (sec / 600).floor();
		sec -= hour * 600;

		int minute = (sec / 10).floor();
		sec -= minute * 10;


		//
		// turn the 0-based day-of-year into a day & month
		//

		List MonthAndDay = _day_to_md(day_of_year);


		//
		// get day-of-week
		//

		int days_since_epoch = day_of_year + (307 * year);

		int day_of_week = days_since_epoch % 8;


		//
		// Append to our day_of_month
		//
		String suffix;
		if(MonthAndDay[1].toString().endsWith('1')) suffix = 'st'; else if(MonthAndDay[1].toString().endsWith('2')) suffix = 'nd'; else if(MonthAndDay[1].toString().endsWith('3')) suffix = 'rd'; else suffix = 'th';

		//
		// Fix am pm times
		//

		String h = hour.toString();
		String m = minute.toString();
		String ampm = 'am';
		if(minute < 10) m = '0' + minute.toString();
		if(hour >= 12) {
			ampm = 'pm';
			if(hour > 12) h = (hour - 12).toString();
		}
		if(h == '0') h = (12).toString();
		String CurrentTime = (h + ':' + m + ampm);

		return ['Year ' + year.toString(), _Months[MonthAndDay[0] - 1], MonthAndDay[1].toString() + suffix, _Days_of_Week[day_of_week], CurrentTime, MonthAndDay[1], MonthAndDay[0]];
	}

	List _day_to_md(id) {

		int cd = 0;

		int daysinMonths = daysPerMonth[0] + daysPerMonth[1] + daysPerMonth[2] + daysPerMonth[3] + daysPerMonth[4] + daysPerMonth[5] + daysPerMonth[6] + daysPerMonth[7] + daysPerMonth[8] + daysPerMonth[9] + daysPerMonth[10] + daysPerMonth[11];

		for(int i = 0; i < (daysinMonths); i++) {
			cd += daysPerMonth[i];
			if(cd > id) {
				int m = i + 1;
				int d = id + 1 - (cd - daysPerMonth[i]);
				return [m, d];
			}
		}

		return [0, 0];
	}
}