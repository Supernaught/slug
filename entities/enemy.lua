local GameObject = require "alphonsus.entities.GameObject"
local Square = require "alphonsus.entities.Square"
local Circle = require "alphonsus.entities.Circle"

local timer = require "lib.hump.timer"

local Enemy = GameObject:extend()

local KNOCKBACK_FORCE = 800

function Enemy:new(x, y, color)
	Enemy.super.new(self, x, y)
	self.name = "Enemy"
	self.isEnemy = true
	self.tag = "enemy"

	self.layer = G.layers.enemy

	-- placeholder sprite
	self.sprite = assets.redSquare

	-- enemy mechanics
	self.hp = 1
	self.bounceForce = 400
	self.damage = 1

	-- collider
	self.collidableTags.cross = { "isPlayer", "isEnemy" }

	self.collider = {
		x = self.pos.x - self.offset.x,
		y = self.pos.y + self.offset.y,
		w = self.width,
		h = self.height,
		ox = -self.offset.x,
		oy = -self.offset.y
	}

	self.color = color or {155,100,0}
	return self
end

function Enemy:bounce(angle, forceMultipler, random)
	local angle = math.rad(math.deg(angle) + _.random(-(random or 0), random or 0))
	self:setVelocityByAngle(angle, self.bounceForce * (forceMultipler or 1))
	self.followPlayer = false
	timer.after(0.2, function() self.followPlayer = true end)
end

function Enemy:collide(other, col)
	-- knockback
	if other.isPlayer then
		other:onHit(1)
		if self.bounceForce > 0 then self:bounce(other.angle, 2) end
	end
end

function Enemy:onHit(damage, collisionNormal)
	self.hp = self.hp - damage

	self:spark()

	if self.hp <= 0 then
		self:die()
	end
end

function Enemy:die()
	local size = _.random(15,20)
	local c = Circle(self.pos.x, self.pos.y, size, size)
	c.layer = G.layers.explosion
	c:selfDestructIn(0.05)
	scene:addEntity(c)

	Enemy.super.die(self)
end

function Enemy:moveTowardsPosition()
	local distanceToTarget = _.distance(self.pos.x, self.pos.y, self.targetPosition.x, self.targetPosition.y)
	if _.round(distanceToTarget) <= 0 then
		self.targetPosition.x = self.targetPosition.x + _.random(-2,2) * 20
		self.targetPosition.y = self.targetPosition.y + _.random(-2,2) * 20
	end
end

return Enemy