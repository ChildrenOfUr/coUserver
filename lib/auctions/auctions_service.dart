library auctions;

import 'dart:async';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/api_helper.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:shelf/shelf.dart' as shelf;

part 'auction.dart';

@app.Group('/ah')
class AuctionService {
	@app.DefaultRoute()
	@Encode()
	Future<shelf.Response> ahStatus() async {
		String query = "SELECT count(*) AS total_auctions, sum(total_cost) AS"
		               " total_value FROM auctions";
		AHStatus status = (await dbConn.query(query, AHStatus)).first;
		return API.createResponse(result: status);
	}

	@app.Route('/auctions', methods: const[app.GET])
	@Encode()
	Future<shelf.Response> getAuctions(@app.QueryParam('item_name') String item_name,
		                               @app.QueryParam('item_count') int item_count,
		                               @app.QueryParam('total_cost') int total_cost,
		                               @app.QueryParam('username') String username) async {
		String queryString = "SELECT * FROM auctions";
		List<String> filters = [];
		Map<String, dynamic> values = {};
		if (item_name != null) {
			filters.add('item_name=@item_name');
			values['item_name'] = item_name;
		}
		if (item_count != null) {
			filters.add('item_count=@item_count');
			values['item_count'] = item_count;
		}
		if (total_cost != null) {
			filters.add('total_cost=@total_cost');
			values['total_cost'] = total_cost;
		}
		if (username != null) {
			filters.add('username=@username');
			values['username'] = username;
		}
		if (filters.length > 0) {
			queryString += ' WHERE';
			for (String filter in filters) {
				queryString += ' $filter AND';
			}
			//chop off the final AND
			queryString = queryString.substring(0, queryString.length - 3);
		}

		List<Auction> auctions = await dbConn.query(queryString, Auction, values);
		return API.createResponse(result: auctions);
	}

	@app.Route('/auctions/:id', methods: const[app.GET])
	Future<shelf.Response> getAuction(String id) async {
		String queryString = 'SELECT * FROM auctions WHERE id = @id';
		List<Auction> auctions = await dbConn.query(queryString, Auction,
			                                        {'id': id});
		if (auctions.length > 0) {
			return API.createResponse(result: auctions.first);
		} else {
			return API.createResponse(error: 'No auction with id: $id was found',
			                          statusCode: API.NOT_FOUND);
		}
	}

	@app.Route('/auctions', methods: const[app.POST])
	@Encode()
	Future<shelf.Response> addAuction(@Decode() Auction auction) async {
		String query = "INSERT INTO auctions (item_name, item_count,"
			"  total_cost, username, start_time, end_time) VALUES (@item_name,"
			" @item_count, @total_cost, @username, @start_time, @end_time)"
		    " RETURNING id";
		int id = (await dbConn.innerConn.query(query, encode(auction)).single).toMap()['id'];
		auction.id = id;

		return API.createResponse(result: auction, statusCode: API.CREATED);
	}
}