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

		TileMap("assets/maps/r2.lua", G.width * 0, G.height * 1, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 1, G.height * 1, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 2, G.height * 1, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 3, G.height * 1, scene.bumpWorld),

		TileMap("assets/maps/r1.lua", G.width * 0, G.height * 2, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 1, G.height * 2, scene.bumpWorld),
		TileMap("assets/maps/r1.lua", G.width * 2, G.height * 2, scene.bumpWorld),
		TileMap("assets/maps/r2.lua", G.width * 3, G.height * 2, scene.bumpWorld),
	}

	for i, map in ipairs(self.maps) do
		map.isDrawing = false
		scene:addEntity(map)
	end

	self.tileMap = self.maps[1]
	self.tileMap.isDrawing = true
	self.prevTileMap = {}
	-- self:enter(self.maps[1])

	self.cameraPanFlux = nil
end

function Level:enter(newTileMap)
	-- scene.camera.followTarget = nil

	self.prevTileMap = self.tileMap
	newTileMap.isDrawing = true

	-- pan camera to room
	scene.camera.cam:setWorld(0,0,10000,10000)
	if self.cameraPanFlux then
		self.cameraPanFlux:stop()

		self.cameraPanFlux = nil

		if self.prevTileMap then
			self.prevTileMap.isDrawing = false
		end
	end
	self.cameraPanFlux = flux.to(scene.camera.pos, 1.2, {x = newTileMap.pos.x + newTileMap.width/2, y = newTileMap.pos.y + newTileMap.height/2}):ease("expoout"):oncomplete(function() 
		scene.camera.cam:setWorld(newTileMap.pos.x, newTileMap.pos.y, newTileMap.width, newTileMap.height)
		self.prevTileMap.isDrawing = false
		self.cameraPanFlux = nil
	end)

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