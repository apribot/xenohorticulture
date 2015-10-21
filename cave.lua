cave = {}
cave.wallheight = 10

cave.MakeCaverns = function() 
    for key,value in pairs(enviroBatch) do
       enviroBatch[key]:clear()
    end

	cave.RandomFillmap()
    for itteration = 0,  maxitteration,  1 do
        for row = 0,  mapHeight,  1 do
            for column = 0,  mapWidth,  1 do
                world.currentMap[column][row] = cave.PlaceWallLogic(column, row) 
            end
        end
    end

    if world.maps[world.pos - 1] then
    	for row = 0, mapHeight, 1 do
    		world.currentMap[0][row] = world.maps[world.pos - 1][mapWidth][row]
    	end
    end
end

cave.RandomFillmap = function() 
    math.randomseed( os.time() )
    local mapMiddle = 0 
    local column = 0
    local row = 0
    for column = 0,  mapWidth,  1 do
        -- add new dimension
        world.currentMap[column] = {}
        mapMiddle = (mapHeight / 2) 
        for row = 0,  mapHeight,  1 do 
            if column == 0 and row >= mapMiddle + 5 and row <= mapMiddle - 5 then
                world.currentMap[column][row] = '0' 
            elseif row == 0 then
                world.currentMap[column][row] = '0' 
            elseif column == mapWidth - 1 and row >= mapMiddle + 5 and row <= mapMiddle - 5 then
                world.currentMap[column][row] = '0' 
            elseif row == mapHeight then
                world.currentMap[column][row] = '0' 
            -- Else, fill with a wall a random percent of the time 
            else 
                if row <= mapMiddle + 2 and row >= mapMiddle - 2 then
                    world.currentMap[column][row] = '3' 
                else 
                    world.currentMap[column][row] = cave.RandomPercent(PercentAreWalls) 
                end
            end
        end
    end 
end

cave.RandomPercent = function(percent) 
    if percent >= math.random(1,100) then
        return '0' 
    end
    return '3' 
end

cave.PlaceWallLogic = function(x, y) 
    local numWalls = cave.GetAdjacentWalls(x, y, 1, 1) 
    if world.currentMap[x][y] == 0 then
        if numWalls >= 4 then
            return '0' 
        end
        if numWalls < 2 then
            return '3' 
        end
    else
        if numWalls >= 5 then
            return '0' 
        end
    end
    return '3' 
end

cave.GetAdjacentWalls = function(x, y, scopeX, scopeY) 
    local startX = x - scopeX 
    local startY = y - scopeY 
    local endX = x + scopeX 
    local endY = y + scopeY 
    local iY = 0
    local iX = 0

    local wallCounter = 0 

    for iY = startY,  endY,  1 do
        for iX = startX, endX, 1 do
        -- WHAT THE FUCK
            if iX ~= x or iY ~= y then
                if cave.IsWall(iX, iY) then
                    wallCounter = wallCounter + 1
                end
            end
        end
    end
    
    return wallCounter 
end

cave.IsWall = function(x, y)
    -- Consider out-of-bound a wall
    if cave.IsOutOfBounds(x, y) then
        return true 
    elseif world.currentMap[x][y] == '0' then
        return true 
    elseif world.currentMap[x][y] == '3' then
        return false 
    else
        return false
    end 
end

cave.IsOutOfBounds = function(x, y) 
    if x < 0 or y < 0 then
        return true 
    elseif x > mapWidth or y > mapHeight then
        return true 
    end
    return false 
end



cave.getStartPos = function() 
    local pos = {}
    for x = 2,  mapWidth,  1 do
        if world.currentMap[x][math.floor(mapHeight / 2)] == 2 then
            pos['x'] = x 
            pos['y'] = math.floor(mapHeight / 2) 
            return pos 
        end
    end
end

cave.getStartPosR = function() 
    local pos = {}
    for x = mapWidth - 2, 2, 1 do
        if world.currentMap[x][math.floor(mapHeight / 2)] == 2 then
            pos['x'] = x 
            pos['y'] = math.floor(mapHeight / 2) 
            return pos 
        end
    end
end

cave.getRandPos = function() 
    local pos = {}
    local i = 0 
    for x = 0, mapWidth, 1 do
        for y = 0, mapHeight, 1 do
            if world.currentMap[x][y] == 2 then
                pos[i] = {}
                pos[i]['x'] = x 
                pos[i]['y'] = y 
                i = 1 + 1
            end
        end 
    end
    local ret = pos[math.random(0, pos.length)]
    return ret 
end
