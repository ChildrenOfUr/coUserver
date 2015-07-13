//part of coUserver;
//
//dynamic rollDice({int sides, int dice}) {
//
//	Random rand = new Random();
//	dynamic rollValue;
//
//	if (sides == 6 && dice == 2) {
//		// regular pair of dice
//
//		List<int> nums = new List();
//
//		nums.add(rand.nextInt(5) + 1);
//		nums.add(rand.nextInt(5) + 1);
//
//		rollValue = nums;
//	}
//
//	if (sides == 12 && dice == 1) {
//		// 12-sided die (psst...it's weighted against the "mystery guest")
//
//		String result = '';
//		int picked = rand.nextInt(22);
//
//		switch (picked) {
//			case 0:
//			case 1:
//				result = 'Alph';
//				break;
//
//			case 2:
//			case 3:
//				result = 'Cosma';
//				break;
//
//			case 4:
//			case 5:
//				result = 'Friendly';
//				break;
//
//			case 6:
//			case 7:
//				result = 'Grendaline';
//				break;
//
//			case 8:
//			case 9:
//				result = 'Humbaba';
//				break;
//
//			case 10:
//			case 11:
//				result = 'Lem';
//				break;
//
//			case 12:
//			case 13:
//				result = 'Mab';
//				break;
//
//			case 14:
//			case 15:
//				result = 'Pot';
//				break;
//
//			case 16:
//			case 17:
//				result = 'Spriggan';
//				break;
//
//			case 18:
//			case 19:
//				result = 'Tii';
//				break;
//
//			case 20:
//			case 21:
//				result = 'Zille';
//				break;
//
//			case 22:
//				result = 'Rook';
//				break;
//		}
//
//		rollValue = result;
//	}
//
//	return rollValue;
//}