--
-- CollisionSystem (powered by bump.lua)
-- by Alphonsus
--
-- updates the entity colliders positions
-- handles collision
--
--

local System = require "lib.knife.system"

local collisionSystem = System(
	{ "collider" },
	function(collider, e, bumpWorld)
		-- move the entity's collider to its curent pos
		local ox, oy = collider.ox or 0, collider.oy or 0
		local cx, cy = e.pos.x + ox, e.pos.y + oy
		local filter = collisionFilter

		local x, y, cols, len = bumpWorld:move(e, cx, cy, filter)
		e.collider.x = x
		e.collider.y = y

		-- update the entity's position after adjusting collision
		e.pos.x = x - ox
		e.pos.y = y - oy

		if e.platformer then
			e.platformer.wasGrounded = e.platformer.isGrounded
			e.platformer.isGrounded = false
		end

		-- loop all collision
		for i=1,len do
			local col = cols[i]
			local col1, col2 = col.item, col.other

			if col1.platformer and col2.isTile then
				local p = col1.platformer

				if col.normal.x ~= 0 and not (col2.isSlope or col2.isOneWay) then
					col1.movable.velocity.x = 0
				end

				-- touched ground
				if col.normal.y == -1 and not (col2.isOneWay and col.overlaps) then
					p.isGrounded = true
					col1.movable.velocity.y = 0
				end
				if col.normal.y == 1 and not col2.isOneWay then
					col1.movable.velocity.y = 0
				end
				if p.isGrounded and not p.wasGrounded then
					if col1.onLand then col1.onLand() end
				end
			end

			if col1.collide and not col1.toRemove then col1:collide(col2, col) end
			if col2.collide and not col2.toRemove then col2:collide(col1, col) end
		end
	end
)

function collisionFilter(item, other)
	if item.collisionFilter then
		return item:collisionFilter(other)
	end

	return "cross"
end

return collisionSystem