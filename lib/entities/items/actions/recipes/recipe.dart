library recipes;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/globals.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/endpoints/time.dart';

import 'package:path/path.dart' as path;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;

part 'recipebook.dart';

class Recipe {
	static Future<int> load() async {
		String filePath = path.join(
			serverDir.path, 'lib', 'entities', 'items', 'actions', 'recipes', 'json');
		await Future.forEach(await new Directory(filePath).list().toList(), (File tool) async {
			JSON.decode(await tool.readAsString()).forEach((Map recipeMap) {
				RecipeBook.recipes.add(decode(recipeMap, Recipe));
			});
		});

		Log.verbose('[Recipe] Loaded ${RecipeBook.recipes.length} recipes');
		return RecipeBook.recipes.length;
	}

	@Field() String id;
	@Field() String tool;
	@Field() Map<String, int> input;
	@Field() String output;
	@Field() int output_amt;
	@Field() int time;
	@Field() int energy = 0;
	@Field() int img = 0;
	@Field() Map<String, int> skills;
	@Field() List<String> holidays;

	// Items are initialized in street_update_handler.dart after all of the items are loaded
	Recipe();

	@override
	String toString() {
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
