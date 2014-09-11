part of coUserver;

class Inventory
{
	@Field()
	String username;

	@Field()
	String inventory_json;

	Future<int> addItem(Map item, int count, PostgreSql dbConn)
	{
		Completer c = new Completer();
		List<Map> slots = JSON.decode(inventory_json);
		bool found = false;
		for(Map slot in slots)
		{
			if(found)
				break;

			if(slot['isContainer'])
			{
				for(Map slotItem in slot['contents'])
				{
					if(slotItem['item']['name'] == item['name'])
					{
						slotItem['count'] += count;
						found = true;
						break;
					}
				}
			}
			else
			{
				if(slot['item']['name'] == item['name'])
				{
					slot['count'] += count;
					found = true;
					break;
				}
			}
		}

		if(!found)
		{
			slots.add({'isContainer':item['isContainer'],
					   'item':item,
					   'count':count});
		}
		inventory_json = JSON.encode(slots);

		String queryString = "update inventories set inventory_json = @inventory_json where username = @username";
		dbConn.execute(queryString,this).then((int numRowsUpdated)
		{
			if(numRowsUpdated > 0)
				c.complete(numRowsUpdated);
			else
			{
				queryString = "insert into inventories(username,inventory_json) values(@username,@inventory_json)";
				dbConn.execute(queryString,this).then((int numInserted) => c.complete(numInserted));
			}
		});

		return c.future;
	}

	Future<int> takeItem(String name, int count, PostgreSql dbConn)
	{
		Completer c = new Completer();
		List<Map> slots = JSON.decode(inventory_json);
		List<int> removeItems = [];
		List<int> possiblyRemove = [];

		for(int i=0; i<slots.length; i++)
		{
			Map slot = slots.elementAt(i);

			if(count <= 0)
				break;

			if(slot['item']['name'] == name)
			{
				if(slot['count'] > count)
				{
					slot['count'] -= count;
					count = 0;
				}
				if(slot['count'] == count)
				{
					removeItems.add(i);
					count = 0;
				}
				if(slot['count'] < count)
				{
					possiblyRemove.add(i);
					count -= slot['count'];
				}
			}
		}

		//always remove these, we know they succeeded
		removeItems.forEach((int index) => slots.removeAt(index));

		//only remove these if the count is now 0
		//otherwise we failed to take enough items
		if(count == 0)
			possiblyRemove.forEach((int index) => slots.removeAt(index));

		inventory_json = JSON.encode(slots);

		String queryString = "update inventories set inventory_json = @inventory_json where username = @username";
		dbConn.execute(queryString,this).then((int numRowsUpdated) => c.complete(numRowsUpdated));

		return c.future;
	}

	List<Map> getItems()
	{
		List<Map> items = [];

		List<Map> slots = JSON.decode(inventory_json);
		slots.forEach((Map slot)
		{
			for(int i=0; i<slot['count']; i++)
				items.add(slot['item']);
		});

		return items;
	}
}

@app.Route('/getInventory/:username')
@Encode()
Future<Inventory> getUserInventory(@app.Attr() PostgreSql dbConn, String username)
{
	Completer c = new Completer();
	String queryString = "select username,inventory_json from inventories where username = @username";
    dbConn.query(queryString,Inventory,{'username':username}).then((List<Inventory> inventories)
    {
    	Inventory inventory = new Inventory()..username=username..inventory_json='[]';
		if(inventories.length > 0)
			inventory = inventories.first;

		c.complete(inventory);
    });

    return c.future;
}

Future<int> addItemToUser(WebSocket userSocket, String username, Map item, int count, String fromObject)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
	{
		getUserInventory(dbConn,username).then((Inventory inventory)
    	{
			//save the item in the user's inventory in the database
  			//then send it to the client
    		inventory.addItem(item, count, dbConn).then((int numRows)
    		{
    			sendItemToUser(userSocket,item,count,fromObject);
    			dbManager.closeConnection(dbConn);
    			c.complete(numRows);
    		});
    	});
	});

	return c.future;
}

Future<int> takeItemFromUser(WebSocket userSocket, String username, String itemName, int count)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
	{
		getUserInventory(dbConn,username).then((Inventory inventory)
    	{
			inventory.takeItem(itemName,count,dbConn).then((int rowsUpdated)
			{
				if(rowsUpdated > 0)
					takeItem(userSocket,itemName,count);
				dbManager.closeConnection(dbConn);
				c.complete(rowsUpdated);
			});
    	});
	});

	return c.future;
}

Future fireInventoryAtUser(WebSocket userSocket, String username)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
    {
		getUserInventory(dbConn,username).then((Inventory inventory)
		{
			inventory.getItems().forEach((Map item)
			{
				sendItemToUser(userSocket,item,1,'');
            });
			dbManager.closeConnection(dbConn);
			c.complete();
		});
    });

	return c.future;
}

sendItemToUser(WebSocket userSocket, Map item, int count, String fromObject)
{
	Map map = {};
	map['giveItem'] = "true";
	map['item'] = item;
	map['num'] = count;
	map['fromObject'] = fromObject;
	userSocket.add(JSON.encode(map));
}

takeItem(WebSocket userSocket, String itemName, int count)
{
	Map map = {};
	map['takeItem'] = "true";
	map['name'] = itemName;
	map['count'] = count;
	userSocket.add(JSON.encode(map));
}