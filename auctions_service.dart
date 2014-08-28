part of coUserver;

@app.Group('/ah')
class AuctionService
{
	@app.Route('/list', methods: const[app.POST])
    @Encode()
    Future<List<Auction>> getAuctions(@app.Body(app.JSON) Map parameters)
    {
		String queryString = "select * from auctions";
		if(parameters.length > 0)
		{
			//TODO support 'or'?
			queryString += ' where';
			parameters.forEach((String key, Map relation) =>
				queryString += ' $key ${relation['operator']} \'${relation['value']}\' and');

			//cut off the trailing 'and'
			queryString = queryString.substring(0,queryString.length-4);
		}
		return postgreSql.query(queryString, Auction);
    }

    @app.Route('/create', methods: const[app.POST])
    Future addAuction(@Decode() Auction auction) =>
    		postgreSql.execute("insert into auctions (item_name,item_count,total_cost,username,start_time,end_time) "
    						   "values (@item_name, @item_count, @total_cost, @username, @start_time, @end_time)",auction);
}