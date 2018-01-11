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
		local x, y, cols, len = bumpWorld:move(e, cx, cy, e.collisionFilter or defaultCollisionFilter)
		e.collider.x = x
		e.collider.y = y

		if e.platformer then
			e.platformer.isGrounded = false
		end

		-- loop all collision
		for i=1,len do
			local col = cols[i]
			local col1, col2 = col.item, col.other

			if col1.platformer and col.normal.x == 0 then
				col1.platformer.isGrounded = col.normal.y < 0
			end

			if col1.collide then col1:collide(col2) end
			if col2.collide then col2:collide(col1) end
		end

		e.pos.x = x - ox
		e.pos.y = y - oy
	end
)

function defaultCollisionFilter(item, other)
	if item.isSolid and other.isSolid then return "slide" end
	return "cross"
end

return collisionSystem