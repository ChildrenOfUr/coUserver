part of coUserver;

@app.Route('/getItems')
@Encode()
Future<List<Item>> getItems(@app.QueryParam('category') String category,
	@app.QueryParam('name') String name,
	@app.QueryParam('type') String type,
	@app.QueryParam('isRegex') bool isRegex) async {
	List<Item> itemList = [];
	if (isRegex == null) {
		isRegex = false;
	}

	if (category != null) {
		if (isRegex) {
			RegExp reg = new RegExp(category.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.category.toLowerCase())));
		} else {
			itemList.addAll(items.values.where((Item i) => i.category.toLowerCase() == category.toLowerCase()));
		}
	}

	if (name != null) {
		if (isRegex) {
			RegExp reg = new RegExp(name.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.name.toLowerCase())));
		} else {
			itemList.addAll(items.values.where((Item i) => i.name.toLowerCase() == name.toLowerCase()));
		}
	}

	if (type != null) {
		if (isRegex) {
			RegExp reg = new RegExp(type.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.itemType.toLowerCase())));
		} else {
			itemList.addAll(items.values.where((Item i) => i.itemType.toLowerCase() == type.toLowerCase()));
		}
	}

	if (name == null && category == null && type == null) {
		return new List.from(items.values);
	}

	return itemList;
}
