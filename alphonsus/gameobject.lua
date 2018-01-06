local Object = require "lib.classic"

local GameObject = Object:extend()
local assets = require "assets"

function GameObject:new(x,y)
	-- gameobject
	self.name = "GameObject"
	self.isAlive = true
	self.visible = true
	self.zIndex = 1

	-- transform
	self.pos = { x = x or 0, y = y or 0 }
	-- self.offset = { x = 0, y = 0}
	self.scale = {}
	self.angle = 0 -- in radians

	return self
end

-- function GameObject:setDrawLayer(newZIndex)
-- 	self["zIndex" .. self.zIndex] = nil
-- 	self.zIndex = newZIndex
-- 	self["zIndex" .. (newZIndex or 1)] = true
-- end

return GameObject