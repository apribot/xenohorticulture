
world.pos = 1
world.maps = {}
world.currentMap = {}
world.currentObj = {}
world.area = 'ship'

world.x = 0
world.y = 0
world.mapHeight = 0
world.mapWidth = 0

world.setMap = function(ar) 
	world.maps[world.pos] = {}
    world.maps[world.pos] = ar
end

world.getMap = function(id) 
    -- default to current pos
    for key,value in pairs(mapBatch) do
       mapBatch[key]:clear()
    end
    
    if world.area == 'cave' then
	    id = id or world.pos
    	world.currentMap = {}
    	world.currentMap = world.maps[id]
    elseif world.area == 'ship' then
    	world.currentMap = {}
    	world.currentObj = {}
    	world.currentMap = world.translateMap(shiploc.x,shiploc.y)
    	world.currentObj = world.translateObj(shiploc.x,shiploc.y)
    end
end

world.translateMap = function(x,y)
	local ret = {{}}
	local xptr = 0
	local yptr = 0
	local temp = {}
	local lc = 0

	if world.area == 'ship' and ship[x][y].map then
		-- this whole thing is awful
		for i in string.gfind(ship[x][y].map, "\n") do
		  	lc = lc + 1
		end

		world.mapHeight = lc + 1 -- end don't have no linebreak
		world.mapWidth = string.len(string.match(ship[x][y].map, '^[^\n]+'))

		-- this is messy as f, good lord
		for xptr=0,world.mapWidth,1 do
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

world.translateObj = function(x,y)
	local ret = {{}}
	local xptr = 0
	local yptr = 0
	local temp = {}

	if world.area == 'ship' and ship[x][y].obj then
		-- this is messy as f, good lord
		for xptr=0,world.mapWidth,1 do
			yptr = 0
			if ret[xptr] == nil then ret[xptr] = {} end
			for line in string.gmatch(ship[x][y].obj, '[^\n]+') do
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
	local mesh = nil
	for key,value in pairs(mapBatch) do
       mapBatch[key]:clear()
    end
    for key,value in pairs(objBatch) do
       objBatch[key]:clear()
    end
    for y = 0, world.mapHeight - 1, 1 do
        for x = 0, world.mapWidth - 1, 1 do 
            local xPos = (x * 48) + world.x
            local yPos = (y * 48) + world.y
            if 
            	xPos < love.graphics.getWidth() 
            	and xPos > -48
            	and yPos < love.graphics.getHeight()
            	and yPos > -48
            	then
            		--print('x:' .. x .. '|y:'..y..'|mapchar:' .. world.currentMap[x][y] .. '|xPos:' .. xPos .. '|yPos:'..yPos)
            		--if tiles[world.currentMap[x][y]].raised == true then
           			--	mapBatch[world.currentMap[x][y]]:add(xPos-8, yPos-8)
           			--else
           				mapBatch[world.currentMap[x][y]]:add(xPos, yPos)
					--end

            		if world.currentObj[x][y] ~= ' ' then 
            			objBatch[world.currentObj[x][y]]:add(xPos, yPos)
            		end
            end
            --mapBatch[0]:add(xPos, yPos)
            --mapBatch[2]:add(xPos, yPos)
        end
    end
    --print('---------------------------------')
    --os.exit()
end