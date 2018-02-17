local GameObject = require "alphonsus.gameobject"

local _ = require "lib.lume"
local timer = require "lib.hump.timer"

local Circle = require "alphonsus.circle"
local Square = require "alphonsus.square"
local Explosion = require "entities.explosion"

local Bullet = GameObject:extend()

-- angle in degrees
function Bullet:new(x, y, angle, speed, owner)
	Bullet.super.new(self, x, y)
	self.name = "Bullet"
	self.isBullet = true
	self.isSolid = false
	-- self.angle = angle or 90
	self.angle = math.rad((angle or 90) + _.random(-5,5))
	self.layer = G.layers.bullet
	self.isLayerYPos = false

	local gapX, gapY = _.vector(self.angle, _.random(10,15))
	self.pos.x = self.pos.x + gapX
	self.pos.y = self.pos.y + gapY

	-- bullet mechanics
	self.damage = 1

	local speed = speed or 250

	self.owner = owner
	self.tag = self.owner.tag

	local maxVelocity = speed

	-- sprite
	self.sprite = assets.bullet

	-- movable component
	self.movable = {
		velocity = { x = velX, y = velY },
		drag = { x = 0, y = 0 },
		maxVelocity = { x = maxVelocity, y = maxVelocity },
		speed = { x = speed, y = speed },
		acceleration = { x = 0, y = 0 }
	}

	self:setVelocityByAngle(self.angle, speed)

	self.width = 16
	self.height = 8

	self.offset = { x = 8, y = 8 }

	-- collider
	self.collider = {
		-- ox = -self.offset.x/2,
		-- oy = -self.offset.y/2,
		-- x = x,
		-- y = y,
		-- w = 8-self.offset.x/2,
		-- h = 8-self.offset.y/2,

		ox = -4,
		oy = -4,
		x = self.pos.x,
		y = self.pos.y,
		w = 7,
		h = 7,
	}

	self:selfDestructIn(1)

	self.color = {255,255,255}
	return self
end

function Bullet:update(dt)
	-- -- rotate towards target
	-- if self.target and _.distance(self.pos.x, self.pos.y, self.target.pos.x, self.target.pos.y) < 100 then
	-- 	local targetAngle = _.angle(self.pos.x, self.pos.y, self.target.pos.x, self.target.pos.y)
	-- 	self.angle = _.lerp(self.angle, targetAngle, dt * 1)
	-- 	print("lerping to " .. self.target.name .. " " .. targetAngle)
	-- 	-- self.angle = _.angle(self.pos.x, self.pos.y, self.target.pos.x, self.target.pos.y)
	-- end
end

function Bullet:collide(other, col)
	if other.isEnemy then
		other:onHit(self.damage)
		self:die()
	end

	if (other.isTile and not other.isOneWay) then
		self:die()
	end
	-- if self.tag ~= other.tag then
	-- 	self.toRemove = true

end

function Bullet:die()
	-- local x, y = self:getMiddlePosition()
	-- local size = _.random(8,16)
	local size = _.random(6,12)
	local x, y = self.pos.x, self.pos.y

	local c = Circle(x, y, size, size)
	c.layer = G.layers.explosion
	c:selfDestructIn(0.01)
	scene:addEntity(c)
	-- for i=0,5 do
	-- 	local size = _.random(10,20)
	-- 	scene:addEntity(Explosion(x + _.random(-6,6), y + _.random(-6,6), size, size))
	-- end
	-- scene.camera:shake(2)
	
	Bullet.super.die(self)
end

return Bullet