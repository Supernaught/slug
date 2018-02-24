local GameObject = require "alphonsus.gameobject"
local Input = require "alphonsus.input"
local Particles = require "alphonsus.particles"
local anim8 = require "lib.anim8"
local _ = require "lib.lume"
local assets = require "assets"

local Circle = require "alphonsus.circle"
local Bullet = require "entities.bullet"

local Player = GameObject:extend()

function Player:new(x, y, playerNo)
	Player.super.new(self, x, y)
	self.name = "Player"

	-- tags
	self.isPlayer = true
	self.playerNo = playerNo
	self.tag = "player"

	-- slugcaster mechanics
	self.shootAngle = 0

	-- draw/sprite component
	self.layer = G.layers.player
	self.isLayerYPos = true
	self.sprite = assets.player
	self.flippedH = false
	self.offset = { x = G.tile_size/2, y = G.tile_size/2 }
	local g = anim8.newGrid(G.tile_size, G.tile_size, self.sprite:getWidth(), self.sprite:getHeight())
	self.idleAnimation = anim8.newAnimation(g('1-3',1), 0.1)
	self.animation = self.idleAnimation

	-- physics
	self.isSolid = true

	-- platformer setup
	local speed = 250
	local maxVelocityX = 140
	local maxVelocityY = 120


	-- self.friction = 10
	self.movable = {
		velocity = {
			x = 0,
			y = 0
		},
		acceleration = {
			x = 0,
			y = 0
		},
		drag = {
			x = 350,
			y = G.gravity
		},
		maxVelocity = {
			x = maxVelocityX,
			y = maxVelocityY
		},
		defaultMaxVelocity = {
			x = maxVelocityX,
			y = maxVelocityY
		},
		speed = {
			x = speed,
			y = speed
		}
	}

	self.platformer = {
		wasGrounded = false,
		isGrounded = false,
		jumpForce = -300,
	}

	-- particles
	self.trailPs = Particles()
	local playerTrail = require "entities.particles.playerTrail"
	if self.playerNo == 2 then playerTrail.colors = {82, 127, 157, 255} end
	self.trailPs:load(playerTrail)
	-- scene:addEntity(self.trailPs)

	-- collider
	self.collider = {
		x = self.pos.x - self.offset.x,
		y = self.pos.y + self.offset.y,
		w = self.width,
		h = self.height,
		ox = -self.offset.x,
		oy = -self.offset.y
	}

	self.collidableTags.cross = { "isEnemy" }

	-- shooter
	self.shooter = {
		canAtk = true,
		atkDelay = 0.1,
		didShoot = false,
	}
	
	return self
end

function Player:collide(other, col)
	if other.isSlope then
		local x = 11*16
		local y = 9*16

		local y1 = y - (self.pos.x - x) * (32/(4*16))
		self.pos.y = y1 - 8
		self.collider.y = y1 - 8
	end
end

function Player:update(dt)
	self:moveControls(dt)

	if self.trailPs then
		local x, y = self:getMiddlePosition()
		self.trailPs.pos.x = x + _.random(-5,5)
		self.trailPs.pos.y = y + 10
		self.trailPs.ps:emit(1)
	end

	if self.platformer then
		local jump = Input.isKeyDown('space')

		if jump then
			self.movable.drag.y = G.gravity/2
		else
			self.movable.drag.y = G.gravity
		end
	end

	-- if self.trailPs then
	-- 	self.trailPs.ps:setPosition(self.pos.x + math.random(-2,2), self.pos.y + 10)
	-- 	self.trailPs.ps:emit(1)
	-- end
end

function Player:onLand()
end

function Player:shoot()
	local x, y = self.pos.x, self.pos.y
	local b = Bullet(x, y, self.shootAngle, nil, self)
	scene:addEntity(b)
end

function Player:moveControls(dt)
	local jump = Input.wasKeyPressed('space')
	if jump then self:jump() end

	local left = Input.isDown(self.playerNo .. '_left') or Input.isAxisDown(self.playerNo, 'leftx', '<')
	local right = Input.isDown(self.playerNo .. '_right') or Input.isAxisDown(self.playerNo, 'leftx', '>')
	local up = Input.isDown(self.playerNo .. '_up') or Input.isAxisDown(self.playerNo, 'lefty', '<')
	local down = Input.isDown(self.playerNo .. '_down') or Input.isAxisDown(self.playerNo, 'lefty', '>')

	-- movement
	if up and not down then
		self.movable.acceleration.y = self.movable.speed.y
	elseif down and not up then
		self.movable.acceleration.y = -self.movable.speed.y
	else
		self.movable.acceleration.y = 0
	end
	if left and not right then
		self.movable.acceleration.x = self.movable.speed.x
		self.direction = Direction.left
	elseif right and not left then
		self.movable.acceleration.x = -self.movable.speed.x
		self.direction = Direction.right
	else
		self.movable.acceleration.x = 0
	end

	-- reduce gravity if shooting sideways
	if (left or right) and self.movable.acceleration.y == 0 then
		self.movable.maxVelocity.y = self.movable.defaultMaxVelocity.y/10
	else
		self.movable.maxVelocity.y = self.movable.defaultMaxVelocity.y
	end

	-- shooting
	if left or right or up or down then
		self.shooter.didShoot = true

		local targetAngle = self.shootAngle

		if right and not left then targetAngle = 0
		elseif down and not up then targetAngle = 90
		elseif left and not right then targetAngle = 180
		elseif up and not down then targetAngle = 270
		end

		if left and up then
			targetAngle = targetAngle + 45
		elseif right and up then
			targetAngle = targetAngle - 45
		elseif left and down then
			targetAngle = targetAngle + 45
		elseif right and down then
			targetAngle = targetAngle + 45
		end

		self.shootAngle = _.lerp(self.shootAngle, targetAngle, 10000 * dt)
	else
		self.shooter.didShoot = false
	end
end

function Player:draw()
end

function Player:collisionFilter(other)
	if self.shooter.didShoot and self.shootAngle == 270 and other.isOneWay then
		return "cross"
	end

	if other.isBullet then
		return "cross"
	end

	return Player.super.collisionFilter(self, other)
end

function Player:onHit(damage)
	print(damage)
end

return Player