part of coUserver;

class itemActions {
	Random rand = new Random();

	dynamic rollDice({int sides, int dice}) {
		dynamic rollValue;

		if (sides == 6 && dice == 2) {
			// regular pair of dice

			List<int> nums = new List();

			nums.add(rand.nextInt(5) + 1);
			nums.add(rand.nextInt(5) + 1);

			rollValue = nums;
		}

		if (sides == 12 && dice == 1) {
			// 12-sided die (psst...it's weighted against the "mystery guest")

			String result = '';
			int picked = rand.nextInt(22);

			switch (picked) {
				case 0:
				case 1:
					result = 'Alph';
					break;

				case 2:
				case 3:
					result = 'Cosma';
					break;

				case 4:
				case 5:
					result = 'Friendly';
					break;

				case 6:
				case 7:
					result = 'Grendaline';
					break;

				case 8:
				case 9:
					result = 'Humbaba';
					break;

				case 10:
				case 11:
					result = 'Lem';
					break;

				case 12:
				case 13:
					result = 'Mab';
					break;

				case 14:
				case 15:
					result = 'Pot';
					break;

				case 16:
				case 17:
					result = 'Spriggan';
					break;

				case 18:
				case 19:
					result = 'Tii';
					break;

				case 20:
				case 21:
					result = 'Zille';
					break;

				case 22:
					result = 'Rook';
					break;
			}

			rollValue = result;
		}

		return rollValue;
	}

	String openCubiBox({int series}) {
		String cubimal = '';
		num seek = rand.nextInt(10000) / 100;
		Map <num, String> cubis = new Map();

		if (series == 1) {
			cubis = {
				17.000: 'chick',
				34.000: 'piggy',
				50.000: 'butterfly',
				58.000: 'crab',
				66.000: 'batterfly',
				74.000: 'frog',
				82.000: 'firefly',
				84.000: 'bureaucrat',
				86.000: 'cactus',
				88.000: 'snoconevendor',
				90.000: 'squid',
				92.000: 'juju',
				93.250: 'smuggler',
				94.500: 'deimaginator',
				95.750: 'greeterbot',
				97.000: 'dustbunny',
				97.500: 'gwendolyn',
				98.000: 'unclefriendly',
				98.500: 'helga',
				99.000: 'magicrock',
				99.500: 'yeti',
				99.750: 'rube',
				100.00: 'rook'
			};
		} else if (series == 2) {
			cubis = {
				14.500: 'fox',
				29.000: 'sloth',
				37.000: 'emobear',
				45.000: 'foxranger',
				54.000: 'groddlestreetspirit',
				61.000: 'uraliastreetspirit',
				69.000: 'firebogstreetspirit',
				77.000: 'gnome',
				81.000: 'butler',
				85.000: 'craftybot',
				89.000: 'phantom',
				93.000: 'ilmenskiejones',
				94.000: 'trisor',
				95.000: 'toolvendor',
				96.000: 'mealvendor',
				97.000: 'gardeningtoolsvendor',
				98.000: 'maintenancebot',
				99.000: 'senorfunpickle',
				99.500: 'hellbartender',
				100.50: 'scionofpurple'
			};
		}

		for (num cubiChance in cubis.keys) {
			if (seek <= cubiChance) {
				cubimal = cubis[cubiChance];
				break;
			}
		}

		return cubimal;
	}
}