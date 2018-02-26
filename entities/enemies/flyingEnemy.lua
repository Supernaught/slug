local Enemy = require "entities.Enemy"

local timer = require "lib.hump.timer"

local FlyingEnemy = Enemy:extend()

function FlyingEnemy:new(x, y)
	FlyingEnemy.super.new(self, x, y)
	self.name = "FlyingEnemy"
	self.isFlyingEnemy = true
	self.tag = "FlyingEnemy"

	-- enemy mechanics
	self.hp = 5

	-- movable
	local speed = 150
	local maxVelocityX = 120
	local maxVelocityY = 120
	local dragX = math.abs(G.gravity)*2

	self.movable = {
		velocity = { x = 0, y = 0 },
		acceleration = { x = 0, y = 0 },
		drag = { x = dragX, y = dragX },
		maxVelocity = { x = maxVelocityX, y = maxVelocityY },
		defaultMaxVelocity = { x = maxVelocityX, y = maxVelocityY },
		speed = { x = speed, y = speed }
	}

	self.speed = speed

	self.followPlayer = true
	self.followSpeed = 0.05
	if self.followPlayer then
		self.player = scene:getObject("isPlayer")[1]
	end

	table.insert(self.collidableTags.cross, "isOneWay")

	return self
end

function FlyingEnemy:update(dt)
	FlyingEnemy.super.update(dt)
	local playerX, playerY = self.player:getOffsetPosition()
	local selfX, selfY = self:getOffsetPosition()

	if self.followPlayer and self.player then
		if math.abs(self:distanceFrom(self.player)) > 20 then
			local angle = _.angle(selfX, selfY, playerX, playerY)
			local velX, velY = _.vector(angle, self.speed)
			self.movable.velocity.x = _.lerp(self.movable.velocity.x, velX, self.followSpeed*1.5)
			self.movable.velocity.y = _.lerp(self.movable.velocity.y, velY, self.followSpeed)
		end
	end
end

function FlyingEnemy:collide(other, col)
	FlyingEnemy.super.collide(self, other, col)
	-- knockback
	if other.isBullet and self.bounceForce > 0 then
		local r = _.random(-30,30)
		local angle = math.rad(math.deg(other.angle) + r)
		local d = self:distanceFrom(self.player)
		local bounceMultiplier = 1

		if d > 100 then
			bounceMultiplier = bounceMultiplier/6
		elseif d > 50 then
			bounceMultiplier = bounceMultiplier/4
		else
			bounceMultiplier = bounceMultiplier/3
		end

		self:bounce(angle, bounceMultiplier, 30)
	end
end

return FlyingEnemy