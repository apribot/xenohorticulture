
world.pos = 1
world.maps = {}
world.currentMap = {}
world.area = 'ship'

world.setMap = function(ar) 
	world.maps[world.pos] = {}
    world.maps[world.pos] = ar
end

world.getMap = function(id) 
    -- default to current pos
    for key,value in pairs(enviroBatch) do
       enviroBatch[key]:clear()
    end
    
    if world.area == 'cave' then
	    id = id or world.pos
    	world.currentMap = {}
    	world.currentMap = world.maps[id]
    elseif world.area == 'ship' then
    	world.currentMap = {}
    	world.currentMap = world.translateMap(shiploc.x,shiploc.y)
    end
end

world.translateMap = function(x,y)
	local ret = {{}}
	local xptr = 0
	local yptr = 0
	local temp = {}

	--[[if world.area == 'ship' and ship[x][y].map then
		for line in string.gmatch(ship[x][y].map, '[^\n]+') do
			ret[yptr] = {}
			xptr = 0
    		for i=1,string.len(line),1 do
       			ret[yptr][xptr] = string.sub(line, i, i)
    			xptr = xptr + 1
    		end
    		yptr = yptr + 1
		end
	end
]]

	if world.area == 'ship' and ship[x][y].map then
		for xptr=0,12,1 do
			yptr = 0
			if ret[xptr] == nil then ret[xptr] = {} end
			for line in string.gmatch(ship[x][y].map, '[^\n]+') do
       			ret[xptr][yptr] = string.sub(line, xptr+1, xptr+1)
	    		yptr = yptr + 1
			end
		end
	end

	return ret
end

world.doNewMap = function()
	world.currentMap = {}
	cave.MakeCaverns()
	world.maps[world.pos] = {}
	world.maps[world.pos] = world.currentMap
	if debug then
		print(table.show(world.maps))
	end
end


world.printmap = function() 
    for y = 0, mapHeight,  1 do
        for x = 0,  mapWidth, 1 do 
            local xPos = x * 48
            local yPos = y * 48
            
            enviroBatch[world.currentMap[x][y]]:add(xPos, yPos)
            
            --enviroBatch[0]:add(xPos, yPos)
            --enviroBatch[2]:add(xPos, yPos)
        end
    end
    --os.exit()
end