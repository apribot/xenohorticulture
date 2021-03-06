--[[

can't fit in 1wide passages, figure out how to slim down player, i guess

create interaction key trapping and logic/framework
and dialog function
include interaction along with the uh img maybe

create inventory system

add multi direction key moving player.direction.left = true, etc for diagonal moving and wall sliding
maybe put all collision into a more efficient function instead of that horrible if/else block

save position on quit
]]--


function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end


function table.show(arr)
	local row = ''
  	for k, v in pairs(arr) do
  		for k2, v2 in pairs(v) do
  			for k3, v3 in pairs(v2) do
  				row = row .. v3
  			end
  			row = row .. '\n'
  		end
  		row = row .. '--------------------\n'
	end
	print(row)
	table.showcurrent(world.currentMap)
end


function table.showcurrent(arr)
	local row = '== CURRENT \n'
	if arr == nil then
		row = 'NOTHING HERE\n'
	else
  		for k2, v2 in pairs(arr) do
  			for k3, v3 in pairs(v2) do
  				row = row .. v3
  			end
  			row = row .. '\n'
  		end
  	end

	print(row)
end


debug = true


-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.1
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { 
	x = math.floor(love.graphics.getHeight()/2) - 24, 
	y = math.floor(love.graphics.getWidth()/2) - 24, 
	speed = 400, 
	img = {
		up = {}, 
		down = {}, 
		left = {}, 
		right = {}
	}, 
	direction = 'down',
	isMoving = false
}

isAlive = true
score  = 0

-- Image Storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

msg = ''

world = {{}}

mapBatch = {}
objBatch = {}

tiles = {}
tiles['0'] = {img = 'assets/stone1.png', pass = false, raised = false}
tiles['1'] = {img = 'assets/black.png', pass = false, raised = false}
tiles['2'] = {img = 'assets/tile1.png', pass = true, raised = false}
tiles['3'] = {img = 'assets/sand.png', pass = true, raised = false}
tiles['4'] = {img = 'assets/shipwall1.png', pass = false, raised = true}
tiles['5'] = {img = 'assets/pot.png', pass = false, raised = false}
tiles['6'] = {img = 'assets/shipdoorwall.png', pass=false, raised = true}
tiles['7'] = {img = 'assets/shipdoortrack.png', pass=true, raised = false}
tiles['8'] = {img = 'assets/tile2.png', pass = true, raised = false}


obj = {}
obj['1'] = {img = 'assets/sprout1.png', pass = true}
obj['2'] = {img = 'assets/sprout2.png', pass = true}
obj['3'] = {img = 'assets/spookyton.png', pass = true}
obj['4'] = {img = 'assets/peep.png', pass = false}
obj['5'] = {img = 'assets/pyramidcat.png', pass = true}
obj['6'] = {img = 'assets/rockly.png', pass = true}
obj['.'] = {img = 'assets/blank.png', pass = true}

shiploc = {}
shiploc.x = 1
shiploc.y = 1

ship = {{}}

ship[1][1] = {}
ship[1][1].map = 
'1111111111111144444444444441111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111142222222222241111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111142888888888241111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1114444444441142888888888241111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1114222222241142288822222241111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1114288888241144488844444441111111400000000000000333333333333333333333333333333333333333333333333333333330\n'..
'1114288888244444488844444444444444633333300000333333333333333333333333333333333333333333333333333333333330\n'..
'1114288888888888888888888888888888733333333333333333333333333333333333333333333333333333333333333333333330\n'..
'1114288888888888888888888888888888733333333333333333333333333333333333333333333333333333333333333333333330\n'..
'1114488444444444488844444444444444633333333333333333333333333333333333333333333333333333333333333333333330\n'..
'1111488411114444488844444111111111400000333333300000000000000000000000000000000000000000000000000000000000\n'..
'1111488411114222288822224111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1444488444444288888888824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1422288222244288585858824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1428888888244288888888824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1428888888888888585858824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1428888888888888888888824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1428888888244288585858824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1422222222244288888888824111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1444444444444444444444444111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111111111111111111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111111111111111111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111111111111111111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111111111111111111111111400000000000000000000000000000000000000000000000000000000000000000000000\n'..
'1111111111111111111111111111111111400000000000000000000000000000000000000000000000000000000000000000000000'


ship[1][1].obj = 
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                             3.                           \n'..
'                                     111                                     ...                          \n'..
'                                      11      1              1111            ...                          \n'..
'                                     6    14 111           1111 11           ...                          \n'..
'                                        5                   1                                             \n'..
'                                            2                                                             \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                1 2 1                                                                                     \n'..
'                                                                                                          \n'..
'                2 2 1                                                                                     \n'..
'                                                                                                          \n'..
'                1 1 1                                                                                     \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          \n'..
'                                                                                                          '


world.getArea = function(x,y)
	-- might be a better way to do this, but meh
	if world.area == 'ship' and x == 3 and y == 2 then 
		world.area = 'cave'
		world.doNewMap()
	elseif world.area == 'cave' and world.pos == 0 then
		world.pos = 1
		world.area = 'ship'
		shiploc.x = 2
		shiploc.y = 2

	end
end


-- Collision detection taken function from http:--love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end






PercentAreWalls = 50
itteration = 0
maxitteration = 7
require "world"




require "cave"





--======================================================================
--== Love shit
--======================================================================

-- Loading
function love.load(arg)

	player.img.up[1] = love.graphics.newImage('assets/space_b1.png')
	player.img.up[2] = love.graphics.newImage('assets/space_b2.png')
	player.img.down[1] = love.graphics.newImage('assets/space_f1.png')
	player.img.down[2] = love.graphics.newImage('assets/space_f2.png')
	player.img.left[1] = love.graphics.newImage('assets/space_l1.png')
	player.img.left[2] = love.graphics.newImage('assets/space_l2.png')
	player.img.right[1] = love.graphics.newImage('assets/space_r1.png')
	player.img.right[2] = love.graphics.newImage('assets/space_r2.png')
	player.direction = 'down'

	enemyImg = love.graphics.newImage('assets/meteor.png')
	bulletImg = love.graphics.newImage('assets/spookyton.png')

	-- load tile image data
	for i, v in pairs(tiles) do
		tiles[i].imgdat = love.graphics.newImage(tiles[i].img)
	end

	for i, v in pairs(obj) do
		obj[i].imgdat = love.graphics.newImage(obj[i].img)
	end

	-- this isn't good
	-- but, uh... it's late.
    local size = 1000

	-- Set up a sprite batch with our single image and the max number of times we
	-- want to be able to draw it. Later we will call spriteBatch:add() to tell
	-- Love where we want to draw our image
	
	for i, v in pairs(tiles) do
		mapBatch[i] = love.graphics.newSpriteBatch(tiles[i].imgdat, size)
	end

	for i, v in pairs(obj) do
		objBatch[i] = love.graphics.newSpriteBatch(obj[i].imgdat, 100)
	end

	if world.area == 'cave' then
		world.doNewMap()
		world.printmap()
	elseif world.area == 'ship' then
		world.getMap()
		world.printmap()
	end

end


-- Updating
function love.update(dt)
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape', 'q') then
		love.event.push('quit')
	end
	
	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		--newEnemy = { x = randomNumber, y = -10, img = enemyImg }
		--table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 850 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img.left[1]:getWidth(), player.img.left[1]:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			--isAlive = false
		end
	end
	player.isMoving = false
	if love.keyboard.isDown('left','a') then
		player.isMoving = true
		world.x = world.x + (player.speed*dt)
		if
			tiles[world.currentMap[math.floor( ((world.x - 5)*-1) / 48)+6 ][math.ceil(  ((world.y+5)*-1) / 48   )+6 ]].pass == false  -- binds us to the map
			or tiles[world.currentMap[math.floor( ((world.x - 5)*-1) / 48)+6 ][math.floor(  ((world.y-5)*-1) / 48   )+6 ]].pass == false 
			or ( 
				world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.ceil(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.ceil(  (world.y*-1) / 48   )+6 ]].pass == false
			)  -- binds us to the map
			or (
				world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false 
			)
			then
				world.x = (math.floor((world.x+5) / 48) * 48) + 5
		end
		player.direction = 'left'
	end
	if love.keyboard.isDown('right','d') then
		player.isMoving = true
		world.x = world.x - (player.speed*dt)
		if 
			tiles[world.currentMap[math.floor( ((world.x + 5)*-1) / 48)+7 ][math.ceil(  ((world.y + 5)*-1) / 48   )+6 ]].pass == false  -- binds us to the map
			or tiles[world.currentMap[math.floor( ((world.x + 5)*-1) / 48)+7 ][math.floor(  ((world.y - 5)*-1) / 48   )+6 ]].pass == false 
			or (
				world.currentObj[math.floor( (world.x*-1) / 48)+7 ][math.ceil(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+7 ][math.ceil(  (world.y*-1) / 48   )+6 ]].pass == false  -- binds us to the map
			)
			or (
				world.currentObj[math.floor( (world.x*-1) / 48)+7 ][math.floor(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+7 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false 
			)
			then
				world.x = (math.ceil((world.x - 5) / 48) * 48) -5
		end
		player.direction = 'right'
	end
	if love.keyboard.isDown('up') then
		player.isMoving = true
		world.y = world.y + (player.speed*dt)
		if
			tiles[world.currentMap[math.floor( ((world.x - 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false  -- binds us to the map
			or tiles[world.currentMap[math.ceil( ((world.x + 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false 
			or (
				world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false  -- binds us to the map
			)
			or (
				world.currentObj[math.ceil( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ] ~= ' '
				and obj[world.currentObj[math.ceil( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+6 ]].pass == false 
			)
			then
				world.y = (math.floor( (world.y + 5) / 48) * 48) 
		end
		player.direction = 'up'
	end
	if love.keyboard.isDown('down') then
		player.isMoving = true
		world.y = world.y - (player.speed*dt)
		if 
			tiles[world.currentMap[math.floor( ((world.x - 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ]].pass == false  -- binds us to the map
			or tiles[world.currentMap[math.ceil( ((world.x + 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ]].pass == false 
			or (
				world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ] ~= ' '
				and obj[world.currentObj[math.floor( (world.x*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ]].pass == false  -- binds us to the map
			)
			or (
				world.currentObj[math.ceil( ((world.x + 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ] ~= ' '
				and obj[world.currentObj[math.ceil( ((world.x + 5)*-1) / 48)+6 ][math.floor(  (world.y*-1) / 48   )+7 ]].pass == false 
			)
			then
				world.y = (math.ceil((world.y-5) / 48) * 48)
		end
		player.direction = 'down'
	end

	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		-- Create some bullets
		newBullet = { x = player.x + (player.img.left[1]:getWidth()/2) - 32, y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 510

		-- reset our game state
		score = 0
		isAlive = true
	end

	
	if world.area == 'cave' then
		-- trying to go right
		if player.x >= love.graphics:getWidth() - (48 + 1) then
		    -- check if there's already a map in this direction
		    if world.maps[world.pos+1] == nil then
		    	world.pos = world.pos + 1
		    	world.doNewMap()
		        player.x =  5
		    else 
		        -- there is a map already saved to the right
		        world.pos = world.pos + 1
				world.getMap()
		        player.x =  5
		    end
		elseif player.x <  5 then
            world.pos = world.pos - 1
			world.getArea(world.pos, nil)
			world.getMap()
            player.x = love.graphics:getWidth() - (player.img.left[1]:getWidth() + 5)	        
	    end
	elseif world.area == 'ship' then
		if player.x >= love.graphics:getWidth() - (48 + 1) then
			-- going right
			shiploc.x = shiploc.x + 1
			world.getArea(shiploc.x, shiploc.y)
			world.getMap()
			player.x = 5

		elseif player.x <  5 then
			--going right
			shiploc.x = shiploc.x - 1
			world.getArea(shiploc.x, shiploc.y)
			world.getMap()
			player.x = love.graphics:getWidth() - (player.img.left[1]:getWidth() + 5)

		elseif player.y < 5 then
			-- going up
			shiploc.y = shiploc.y + 1
			world.getArea(shiploc.x, shiploc.y)
			world.getMap()
			player.y = love.graphics:getHeight() - (player.img.left[1]:getHeight() + 5)
		elseif player.y >= love.graphics:getHeight() - (48 + 1) then
			-- going down
			shiploc.y = shiploc.y - 1
			world.getArea(shiploc.x, shiploc.y)
			world.getMap()
			player.y = 5
		end
	end
    world.printmap()
end

-- Drawing
function love.draw(dt)
	love.graphics.setBackgroundColor(0,0,0)


    for key,value in pairs(mapBatch) do
       love.graphics.draw(mapBatch[key])
    end



    for key,value in pairs(objBatch) do
       love.graphics.draw(objBatch[key])
    end
--????


	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

--	love.graphics.setColor(248, 240, 143)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(tostring(msg), 200, 10)

	if isAlive then
		if player.isMoving then
			if player.direction == 'left' then
				love.graphics.draw(player.img.left[((math.floor(os.clock()*50)) % 2) +1], player.x, player.y)
			elseif player.direction == 'right' then
				love.graphics.draw(player.img.right[((math.floor(os.clock()*50)) % 2) +1], player.x, player.y)
			elseif player.direction == 'up' then
				love.graphics.draw(player.img.up[((math.floor(os.clock()*50)) % 2) +1], player.x, player.y)
			elseif player.direction == 'down' then
				love.graphics.draw(player.img.down[((math.floor(os.clock()*50)) % 2) +1], player.x, player.y)
			end
		else
			if player.direction == 'left' then
				love.graphics.draw(player.img.left[1], player.x, player.y)
			elseif player.direction == 'right' then
				love.graphics.draw(player.img.right[1], player.x, player.y)
			elseif player.direction == 'up' then
				love.graphics.draw(player.img.up[1], player.x, player.y)
			elseif player.direction == 'down' then
				love.graphics.draw(player.img.down[1], player.x, player.y)
			end
		end

	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	if debug then
		fps = tostring(love.timer.getFPS())
		love.graphics.print("Current FPS: "..fps, 9, 10)
	end
end