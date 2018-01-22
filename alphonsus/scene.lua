-- 
-- Scene.lua
-- a game scene (like a Unity scene)
-- 

local _ = require "lib.lume"
local Object = require "lib.classic"
local shack = require "lib.shack"
local push = require "lib.push"
local gamera = require "lib.gamera"
local bump = require "lib.bump"

local assets = require "assets"
local removeSystem = require "systems.removeSystem"
local updateSystem = require "systems.updateSystem"
local drawSystem = require "systems.drawSystem"
local collisionSystem = require "systems.collisionSystem"
local movableSystem = require "systems.movableSystem"
local moveTowardsAngleSystem = require "systems.moveTowardsAngleSystem"
local moveTowardsPositionSystem = require "systems.moveTowardsPositionSystem"

local Camera = require "alphonsus.camera"
local Input = require "alphonsus.input"

local Scene = Object:extend()

function Scene:init()
end

function Scene:new()
	self.bgColor = {0,0,0,255}
	return self
end

function Scene:enter()
	self.entities = {}

	-- setup cam
	self.camera = Camera(0, 0, G.width, G.height)
	self.camera.cam:setWindow(0, 0, G.width, G.height)

	-- setup collision world
	self.bumpWorld = bump.newWorld()
end

-- Add entity to ECS and bump world
function Scene:addEntity(e)
	table.insert(self.entities, e)

	local col = e.collider

	if col and col.x and col.y and col.w and col.h then
		self.bumpWorld:add(e, col.x, col.y, col.w, col.h)
	end
end

function Scene:keypressed(k)
	Input.onKeyPress(k)
end

function Scene:update(dt)
	for i, e in ipairs(self.entities) do
		updateSystem(e, e, dt)
		moveTowardsAngleSystem(e, e, dt)
		moveTowardsPositionSystem(e, e, dt)
		movableSystem(e, e, dt)
		collisionSystem(e, e, self.bumpWorld)
		removeSystem(e, i, self.entities, self.bumpWorld)
	end

	self.camera:update(dt)
	self:stateUpdate(dt)
	Input.clear()
end

-- basically the update function for states/scenes
function Scene:stateUpdate(dt)
end

function Scene:draw()
	push:start()
	self.camera.cam:draw(function(l,t,w,h)
		love.graphics.setColor(unpack(self.bgColor))
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255,255,255,255)
		shack:apply()
		-- love.graphics.draw(assets.bg, 0, 0)
		for _, e in ipairs(_.sort(self.entities, function(a,b) return a.layer < b.layer end)) do
			drawSystem(e, e)
		end
	end)
	push:finish()

	if G.debug then
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
		love.graphics.print("Game Objects: "..tostring(#self.entities), 10, 25)
	end
end

-- HELPER FUNCTIONS
function Scene:getNearestEntityFromSource(source, maxDistance, tag)
	-- get visible entities except source
	local filteredEntities = _.reject(self.entities, function(e)
		return source.pos.x == e.pos.x and source.pos.y == e.pos.y
	end)

	if tag then
		filteredEntities = _.filter(filteredEntities, function(e) return e.tag == tag end)
	end

	local visibleEntities = self.camera:getVisibleEntities(filteredEntities)

	if maxDistance then
		-- filter max distance
		visibleEntities = _.filter(visibleEntities, function(e) return e:distanceFrom(source) < maxDistance end)
	end

	-- sort visible entities by distance to source (ascending)
	local sortedEntities = _.sort(visibleEntities, function(a,b)
		return a:distanceFrom(source) < b:distanceFrom(source)
	end)

	return sortedEntities[1]
end

function Scene:getNearbyEntitiesFromSource(source, distance, tag)
	return _.filter(self.entities, function(e)
		return _.distance(source.pos.x, source.pos.y, e.pos.x, e.pos.y) < distance and e.tag == tag
	end)
end

return Scene