part of coUserver;

num race() {
	// number 1 to 50
	int base = rand.nextInt(49) + 1;
	// number 0.0 (incl) to 1.0 (excl)
	double multiplier = rand.nextDouble();
	// multiply them for more variety
	num result = base * multiplier;
	// 80% chance to cut numbers at least 17 in half
	if (result >= 17 && rand.nextInt(4) <= 3) result /= 2;
	// cut to two decimal places (and a string)
	String twoPlaces = result.toStringAsFixed(2);
	// back to number format
	num output = num.parse(twoPlaces);

	if (map['itemType'] == 'npc_cubimal_factorydefect_chick') output = -(output / 2);
	return output;
}