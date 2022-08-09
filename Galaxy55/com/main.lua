function onStart(path)
	print("Server application '"..path.."' started")
end

function onStop(path)
	print("Server application '"..path.."' stopped")
end

planets = {};

function onConnection(client,response,...)
	function client:ready(pid)
		local ids = {};
		local planet = planets[pid];
		if planet == nil then
			planet = {};
			planets[pid] = planet;
		end;
		for _,c in pairs(planet) do
			table.insert(ids,c.id);
			c.writer:writeAMFMessage("onNewUser",client.id);
		end
		planet[client.id] = client;
		client.planet = planet;
		return ids;
	end
end

function onDisconnection(client)
	local p = client.planet;
	if p ~= nil then p[client.id] = nil end;
end