local flux = require "lib.flux"

local GameObject = require "alphonsus.entities.GameObject"
local TileMap = require "alphonsus.entities.TileMap"

local Level = GameObject:extend()

function Level:new(player)
	Level.super.new(self)
	self.name = "Level"

	self.player = player
	self.tileMap = {}
	self.currentRoom = {1,1}

	-- setup tile map
	self.maps = {
		TileMap("assets/maps/r1.lua", G.width * 0, G.height * 0, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 1, G.height * 0, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 2, G.height * 0, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 3, G.height * 0, scene.bumpWorld),

		TileMap("assets/maps/r2.lua", G.width * 0, G.height, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 1, G.height, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 2, G.height, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 3, G.height, scene.bumpWorld),

		TileMap("assets/maps/r1.lua", G.width * 0, G.height + G.height, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 1, G.height + G.height, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 2, G.height + G.height, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 3, G.height + G.height, scene.bumpWorld),
	}

	for i, map in ipairs(self.maps) do
		map.isDrawing = false
		scene:addEntity(map)
	end

	self.tileMap = self.maps[1]
	self.tileMap.isDrawing = true
	scene.camera:startFollowing(scene.player)
	scene.camera.cam:setWorld(self.tileMap.pos.x, self.tileMap.pos.y, self.tileMap.width, self.tileMap.height)
	self.prevTileMap = {}
	-- self:enter(self.maps[1])

	self.cameraPanFlux = nil
end

function Level:enter(newTileMap)
	scene.camera.followTarget = nil

	self.prevTileMap = self.tileMap
	newTileMap.isDrawing = true

	-- prevent overlapping camera pans
	if self.cameraPanFlux then
		self.cameraPanFlux:stop()
		self.cameraPanFlux = nil
		if self.prevTileMap then
			self.prevTileMap.isDrawing = false
		end
	end

	-- pan camera to room
	local x1, y1, w1, h1 = self.prevTileMap.pos.x, self.prevTileMap.pos.y, self.prevTileMap.width, self.prevTileMap.height
	local x2, y2, w2, h2 = newTileMap.pos.x, newTileMap.pos.y, newTileMap.width, newTileMap.height
	local x = math.min(x1, x2)
	local y = math.min(y1, y2)
	local w = math.max(x1 + w1, x2 + w2)
	local h = math.max(y1 + h1, y2 + h2)
	scene.camera.cam:setWorld(x, y, w, h)

	if newTileMap.width > G.width and newTileMap.height > G.height then
		-- follow player if room is big
		scene.camera:startFollowing(scene.player)
		scene.camera.cam:setWorld(newTileMap.pos.x, newTileMap.pos.y, newTileMap.width, newTileMap.height)
	else
		-- normal size room
		local targetCameraPos = {x = newTileMap.pos.x + newTileMap.width/2, y = newTileMap.pos.y + newTileMap.height/2}
		self.cameraPanFlux = flux.to(scene.camera.pos, 1.2, targetCameraPos):ease("expoout"):oncomplete(function() 
			scene.camera.cam:setWorld(newTileMap.pos.x, newTileMap.pos.y, newTileMap.width, newTileMap.height)
			self.prevTileMap.isDrawing = false
			self.cameraPanFlux = nil
		end)
	end

	self.tileMap = newTileMap
end

function Level:update(dt)
	if self.player and self.tileMap then
		local p = self.player
		for i,map in ipairs(self.maps) do
			if rectangleContains(map.pos.x, map.pos.y, map.width, map.height, p.pos.x, p.pos.y, 0, 0) and self.tileMap.uuid ~= map.uuid then
				self:enter(map)
			end
		end
	end
end

return Level