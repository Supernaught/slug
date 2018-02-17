local _ = require "lib.lume"
local Object = require "lib.classic"
local timer = require "lib.hump.timer"

local GameObject = Object:extend()
local assets = require "assets"

Direction = {
	up = 'up',
	down = 'down',
	left = 'left',
	right = 'right'
}

function GameObject:new(x, y, w, h)
	-- gameobject
	self.name = "GameObject"
	self.tag = ""
	self.isAlive = true
	self.toRemove = false

	self.isVisible = true
	self.isSolid = true

	-- draw layer
	self.layer = 0

	-- if true, drawSystem will set self.layer to self.pos.y on update loop
	-- used for 2.5D topdown games
	self.isLayerYPos = false

	-- transform
	self.pos = { x = x or 0, y = y or 0 }
	self.width = w or G.tile_size
	self.height = h or G.tile_size
	self.offset = { x = self.width/2, y = self.height/2 }
	self.scale = { x = 1, y = 1 }
	self.angle = 0 -- in radians

	-- collider component
	-- self.collider = {
	-- 	x = x - self.offset.x,
	-- 	y = y - self.offset.y,
	-- 	w = self.width,
	-- 	h = self.height,
	-- 	ox = 0,
	-- 	oy = 0
	-- }

	-- flicker
	self.isFlickering = false
	self.flickerDelay = 0.05

	self.collidableTags = {
		-- only collides with these tags, ignores the rest
		only = {},

		-- if collides with entities with these tags, they will "cross"
		-- and call collide() function to collidees
		cross = {},

		-- no collision or trigger with these tags
		none = {}
	}

	return self
end

function GameObject:update(dt)
end

function GameObject:draw(dt)
end

function GameObject:selfDestructIn(seconds)
	timer.after(seconds, function() self.toRemove = true end)
end

function GameObject:die()
	self.toRemove = true
end

function GameObject:collisionFilter(other)
	-- for i,tag in ipairs(self.collidableTags.solid) do
	-- 	if other[tag] then return "solid" end
	-- end

	for i,tag in ipairs(self.collidableTags.cross) do
		if other[tag] then return "cross" end
	end

	-- if other.isSlope then return "cross" end
	if self.isSolid then
		if other.isSolid then return "slide" end
		if other.isOneWay then return "onewayplatform" end
	end

	return "cross"
end

-- ====================
-- UTILS
-- ====================

function GameObject:spark(duration)
	self.isSpark = true
	timer.after(duration or 0.03, function() self.isSpark = false end)
end

function GameObject:flicker(duration, blinkDelay)
	self.isFlickering = true
	self.flickerDelay = blinkDelay or 0.05

	self:blink()

	if duration > 0 then
		timer.after(duration, function()
			self.isFlickering = false
			self.isVisible = true
		end)
	end
end

function GameObject:blink()
	if not self.isFlickering then self.isVisible = true return end

	timer.after(self.flickerDelay, function()
		self.isVisible = not self.isVisible
		self:blink()
	end)
end

function GameObject:getMiddlePosition()
	return self.pos.x + self.width/2, self.pos.y + self.height/2
end

function GameObject:getOffsetPosition()
	return self.pos.x + self.offset.x, self.pos.y + self.offset.y
end

function GameObject:distanceFrom(gameobject)
	return _.distance(self.pos.x, self.pos.y, gameobject.pos.x, gameobject.pos.y)
end

function GameObject:getNearbyEntities(distance, tag)
	return scene:getNearbyEntitiesFromSource(self, distance, tag)
end

function GameObject:getNearestEntity(withDistance, tag)
	return scene:getNearestEntityFromSource(self, withDistance, tag)
end

function GameObject:setVelocityByAngle(angle, speed)
	assert(self.movable, "GameObject has no movable component")
	local magnitude = speed or self.movable.speed.x or self.movable.speed.y
	self.movable.velocity.x, self.movable.velocity.y = _.vector(angle, magnitude)
end

return GameObject