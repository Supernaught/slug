local _ = require "lib.lume"
local GameObject = require "alphonsus.gameobject"
local Square = require "alphonsus.square"

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

	self.bounce = 400

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

function Enemy:collide(other, col)
	-- knockback
	if other.isBullet and self.bounce then
		-- self.movable.velocity.x = KNOCKBACK_FORCE
		local angle = math.rad(math.deg(other.angle) + _.random(0,0))
		self:setVelocityByAngle(angle, self.bounce)
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