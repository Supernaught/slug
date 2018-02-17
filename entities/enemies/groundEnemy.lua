local _ = require "lib.lume"
local Enemy = require "entities.enemy"

local GroundEnemy = Enemy:extend()

function GroundEnemy:new(x, y)
	GroundEnemy.super.new(self, x, y)
	self.name = "GroundEnemy"
	self.isGroundEnemy = true
	self.tag = "GroundEnemy"

	-- movable
	local speed = 250
	local maxVelocityX = 300
	local maxVelocityY = 300
	local dragY = math.abs(G.gravity)*2
	local dragX = dragY

	self.movable = {
		velocity = { x = 0, y = 0 },
		acceleration = { x = 0, y = 0 },
		drag = { x = dragX, y = G.gravity },
		maxVelocity = { x = maxVelocityX, y = maxVelocityY },
		defaultMaxVelocity = { x = maxVelocityX, y = maxVelocityY },
		speed = { x = speed, y = speed }
	}

	-- platformer
	self.platformer = {
		wasGrounded = false,
		isGrounded = false,
	}

	return self
end

return GroundEnemy