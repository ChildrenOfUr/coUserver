library recipes;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/inventory_new.dart';
import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/achievements/achievements.dart';

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;

part 'recipebook.dart';

class Recipe {
	@Field() String id;
	@Field() String tool;
	@Field() Map<String, int> input;
	@Field() String output;
	@Field() int output_amt;
	@Field() int time;
	@Field() int energy = 0;
	@Field() int img = 0;

	// Items are initialized in street_update_handler.dart after all of the items are loaded
	Recipe();

	toString() {
		return "Recipe to make ${output_amt} x $output with $tool using ${input.toString()} taking $time seconds";
	}

	static Future useItem(Map map, WebSocket userSocket, String email) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		userSocket.add(JSON.encode({
			"useItem": itemInSlot.itemType,
			"useItemName": itemInSlot.name
		}));
	}
}