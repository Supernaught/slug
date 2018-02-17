local _ = require "lib.lume"
local timer = require "lib.hump.timer"
local Enemy = require "entities.enemy"

local FlyingEnemy = Enemy:extend()

function FlyingEnemy:new(x, y)
	FlyingEnemy.super.new(self, x, y)
	self.name = "FlyingEnemy"
	self.isFlyingEnemy = true
	self.tag = "FlyingEnemy"

	-- enemy mechanics
	self.hp = 200

	-- movable
	local speed = 250
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

	self.speed = 250

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
	-- knockback
	if other.isBullet and self.bounce then
		local r = _.random(-30,30)
		local angle = math.rad(math.deg(other.angle) + r)
		local d = self:distanceFrom(self.player)
		local bounceForce = self.bounce

		if d > 100 then
			bounceForce = self.bounce/6
		elseif d > 50 then
			bounceForce = self.bounce/4
		else
			bounceForce = self.bounce/3
		end

		self:setVelocityByAngle(angle, bounceForce)
		self.followPlayer = false
		timer.after(0.2, function() self.followPlayer = true end)
	end
end

return FlyingEnemy