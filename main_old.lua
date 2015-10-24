--[[

can't fit in 1wide passages, figure out how to slim down player, i guess

save outdoor(cave) permanance
]]--





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


debug = false

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.1
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { 
	x = math.floor(love.graphics.getHeight()/2) + 24, 
	y = math.floor(love.graphics.getWidth()/2) + 24, 
	speed = 175, 
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

enviroBatch = {}


tiles = {}
tiles['0'] = {img = 'assets/stone1.png', pass = false}
tiles['1'] = {img = 'assets/black.png', pass = false}
tiles['2'] = {img = 'assets/tile1.png', pass = true}
tiles['3'] = {img = 'assets/sand.png', pass = true}

shiploc = {}
shiploc.x = 1
shiploc.y = 1

ship = {{}}

ship[1][1] = {}
ship[1][1].map = 
'1111122211111\n'..
'1111122211111\n'..
'1111122211111\n'..
'1111122211111\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1222222222221\n'..
'1111111111111'


ship[1][2] = {}
ship[1][2].map = 
'1111111111111\n'..
'1111111111111\n'..
'1111112222222\n'..
'1111112222222\n'..
'1122222222111\n'..
'1122222222111\n'..
'1111112222111\n'..
'1112222222111\n'..
'1112222222111\n'..
'1112222222111\n'..
'1112222222111\n'..
'1112222222111\n'..
'1111122211111'

ship[2] = {}
ship[2][2] = {}
ship[2][2].map = 
'1111111111111\n'..
'1122222222211\n'..
'2222222222211\n'..
'2222222222211\n'..
'1122222222211\n'..
'1122222222222\n'..
'1122222222222\n'..
'1122222222211\n'..
'1122222222211\n'..
'1122222222211\n'..
'1122222222211\n'..
'1122222222211\n'..
'1111111111111'

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

	mapWidth = math.floor(love.graphics.getWidth()  / 48) - 1
    mapHeight = math.floor(love.graphics.getHeight() / 48) - 1
    local size = mapWidth * mapHeight + 25

	-- Set up a sprite batch with our single image and the max number of times we
	-- want to be able to draw it. Later we will call spriteBatch:add() to tell
	-- Love where we want to draw our image
	
	for i, v in pairs(tiles) do
		enviroBatch[i] = love.graphics.newSpriteBatch(tiles[i].imgdat, size)
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
		player.x = player.x - (player.speed*dt)
		if player.x < 0 
			or tiles[world.currentMap[math.floor( player.x / 48) ][math.ceil(  (player.y / 48 )  ) ]].pass == false  -- binds us to the map
			or tiles[world.currentMap[math.floor( player.x / 48) ][math.floor(  (player.y / 48 )  ) ] ].pass == false then
				player.x = math.ceil(player.x / player.img.left[1]:getWidth()) * player.img.left[1]:getWidth() + 1
		end
		if player.x < 0 then player.x = 0 end
		player.direction = 'left'
	elseif love.keyboard.isDown('right','d') then
		player.isMoving = true
		player.x = player.x + (player.speed*dt)
		if player.x > (love.graphics.getWidth() - player.img.left[1]:getWidth()) 
			or tiles[world.currentMap[math.floor(player.x /  player.img.left[1]:getWidth()) + 1][math.floor(player.y / player.img.left[1]:getHeight()) ] ].pass == false
			or tiles[world.currentMap[math.floor(player.x /  player.img.left[1]:getWidth()) + 1][math.ceil(player.y / player.img.left[1]:getHeight()) ] ].pass == false then
				player.x = math.floor(player.x / player.img.left[1]:getWidth()) * player.img.left[1]:getWidth() - 1
		end
		if player.x > love.graphics.getWidth() then player.x = love.graphics.getWidth() end
		player.direction = 'right'
	elseif love.keyboard.isDown('up') then
		player.isMoving = true
		player.y = player.y - (player.speed*dt)
		if player.y < 0 
			or tiles[world.currentMap[math.floor(player.x / player.img.left[1]:getWidth())][math.floor(player.y /  player.img.left[1]:getHeight())] ].pass == false 
			or tiles[world.currentMap[math.ceil(player.x / player.img.left[1]:getWidth())][math.floor(player.y /  player.img.left[1]:getHeight())] ].pass == false then
				player.y = math.ceil(player.y / player.img.left[1]:getHeight()) * player.img.left[1]:getHeight() + 1
		end
		if player.y < 0 then player.y = 0 end
		player.direction = 'up'
	elseif love.keyboard.isDown('down') then
		player.isMoving = true
		player.y = player.y + (player.speed*dt)
		if player.y > (love.graphics.getHeight() - player.img.left[1]:getHeight()) 
			or tiles[world.currentMap[math.floor(player.x / player.img.left[1]:getWidth())][math.floor(player.y /  player.img.left[1]:getHeight()) + 1] ].pass == false
			or tiles[world.currentMap[math.ceil(player.x / player.img.left[1]:getWidth())][math.floor(player.y /  player.img.left[1]:getHeight()) + 1] ].pass == false then
				player.y = math.floor(player.y / 48) * 48 - 1
		end 
		if player.y + player.img.left[1]:getHeight() > love.graphics.getHeight() then player.y = love.graphics.getHeight() end
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
	love.graphics.setBackgroundColor(148,140,43)


    for key,value in pairs(enviroBatch) do
       love.graphics.draw(enviroBatch[key])
    end

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