part of entity;

/**
 * This file contains classes that will create a certain type of vendor
 * that sells each collection of items (such as alchemical, toy, etc.).
 *
 * It is currently only used for the entity info endpoint (encyclopedia).
 * The street names given are defined to have this type of vendor in vendors.json.
 */
class FakeVendor extends Vendor {
	FakeVendor(String streetName) : super(null, streetName, null, 0, 0, 0, 0, false) {
		itemsPredefined = true;
	}
}

class AlchemicalVendor extends FakeVendor {
	AlchemicalVendor() : super("Abesh Litcha");
}

class AnimalVendor extends FakeVendor {
	AnimalVendor() : super("Aippasi Massy");
}

class GardeningVendor extends FakeVendor {
	GardeningVendor() : super("Aava Plies");
}

class GroceriesVendor extends FakeVendor {
	GroceriesVendor() : super("Afra Maf");
}

class HardwareVendor extends FakeVendor {
	HardwareVendor() : super("Abhiman Himan");
}

class KitchenVendor extends FakeVendor {
	KitchenVendor() : super("Adeno Sierra");
}

class MiningVendor extends FakeVendor {
	MiningVendor() : super("Alecha Kolo");
}

class ProduceVendor extends FakeVendor {
	ProduceVendor() : super("Aavani Avenue");
}

class ToyVendor extends FakeVendor {
	ToyVendor() : super("Ahtria Ahcalla");
}