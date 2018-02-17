--
-- PlatformerMovableSystem
-- by Alphonsus
--
-- movement physics
--
-- Required:
--
-- self.movable = {
-- 	velocity = { x = 0, y = 0 },
-- 	acceleration = { x = 0, y = 0 },
-- 	drag = { x = 0, y = 0 },
-- 	maxVelocity = { x = math.huge, y = math.huge },
-- 	speed = { x = 0, y = 0 } -- used to assign to acceleration
-- }
--
--

local _ = require "lib.lume"
local vector = require "lib.hump.vector-light"
local Vec = require "lib.hump.vector"
local System = require "lib.knife.system"

local platformerMovableSystem = System(
	{ "movable", "platformer" },
	function(movable, platformer, e, dt)		
		local mov = movable
		local vel, accel, maxVel, drag = mov.velocity, mov.acceleration, mov.maxVelocity, mov.drag

		-- Update velocity
		vel.x = vel.x + (accel.x * dt)
		vel.y = vel.y + (accel.y * dt)
		
		-- Apply drag if not accelerating
		if accel.x == 0 and drag.x > 0 then
			local sign = _.sign(vel.x)
			if e.friction then
				vel.x = _.lerp(vel.x, 0, e.friction)
			else
				vel.x = vel.x - drag.x * dt * sign
			end
			if (vel.x < 0) ~= (sign < 0) then
				vel.x = 0
			end
		end
		if accel.y == 0 and drag.y ~= 0 then
			local sign = _.sign(vel.y)
			vel.y = vel.y - drag.y * dt
			if (vel.y < 0) ~= (sign < 0) then
				vel.y = 0
			end
		end

		-- Update max velocity
		if math.abs(vel.x) > maxVel.x then
			vel.x = maxVel.x * _.sign(vel.x)
		end
		if math.abs(vel.y) > maxVel.y then
			vel.y = maxVel.y * _.sign(vel.y)
		end

		-- update position
		e.pos.x = e.pos.x + vel.x * dt
		e.pos.y = e.pos.y + vel.y * dt
	end
)

return platformerMovableSystem