--
-- DrawSystem
-- by Alphonsus
--
-- calls the entity's draw() function
--
local assets = require "assets"

local System = require "lib.knife.system"

local drawSystem = System(
	{ "draw" },
	function(draw, e)
		if e.isVisible and e.isAlive then
			local x, y = e.pos.x, e.pos.y
			local sx, sy = e.scale.x or 1, e.scale.y or 1
			local angle = e.angle or 0

			local ox, oy = e.offset.x, e.offset.y

			if e.isSpark then
				love.graphics.setShader(assets.spark_shader)
			end

			if e.animation then
				e.animation.flippedH = e.flippedH or false
				e.animation:draw(e.sprite, x, y, angle, sx, sy, ox, oy)
			elseif e.sprite then
				love.graphics.draw(e.sprite, x, y, angle, sx, sy, ox, oy)
			end

			if e.draw then e:draw() end

			if e.isLayerYPos then
				e.layer = e.pos.y
			end
		end

		if e.spark then
			love.graphics.setShader()
		end
		
		-- debug
		if e.collider and G.debug then
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle("line", e.collider.x, e.collider.y, e.collider.w, e.collider.h)
			love.graphics.setColor(255, 255, 255)
		end
	end
)

return drawSystem