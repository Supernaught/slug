local sti = require "lib.sti"
local GameObject = require "alphonsus.entities.GameObject"
local TileMap = GameObject:extend()

function TileMap:new(mapPath, xOffset, yOffset, bumpWorld)
	TileMap.super.new(self, xOffset or 0, yOffset or 0)
	self.name = "TileMap"
	self.isTileMap = true

	self.isDrawing = true

	self.bumpWorld = bumpWorld

	self.mapPath = mapPath

	-- self.map = sti("maps/plain.lua")
	-- self.map = sti("maps/plain2.lua")
	local map = sti(mapPath, { "bump" }, xOffset or 0, yOffset or 0)
	self.map = map
	self.map:bump_init(self.bumpWorld)
	self.map:resize(1000,1000)

	for lindex, layer in ipairs(map.layers) do
		-- solid tile layer
		if layer.properties.isDecor then
			for y, tiles in ipairs(layer.data) do
				for x, tile in pairs(tiles) do
					-- local xpos, ypos = x * map.tilewidth, y * map.tileheight
					-- TODO: add gameobject
				end
			end
		elseif layer.data then
			local isOneWayLayer = layer.properties.isOneWay
			local isSolidLayer = layer.properties.isSolid
			local isSlopeLayer = layer.properties.isSlope

			for y, tiles in ipairs(layer.data) do
				for x, tile in pairs(tiles) do
					local isOneWay = layer.properties.isOneWay or tile.properties.isOneWay
					local isSolid = not isOneWay and (layer.properties.isSolid or tile.properties.isSolid)
					local isSlope = layer.properties.isSlope or tile.properties.isSlope

					local xpos, ypos = (x-1) * map.tilewidth, (y-1) * map.tileheight
					local bumpObject = {
						collider = {
							x = x-1 + (xOffset or 0)/16,
							y = y-1 + (yOffset or 0)/16,
							w = tile.width,
							h = isOneWay and 1 or tile.height,
						},
						name = layer.name,
						isOneWay = isOneWay,
						isSolid = isSolid,
						isSlope = isSlope,
						isTile = true
					}

					if isOneWay or isSolid or isSlope then
						bumpWorld:add(bumpObject, xpos + (xOffset or 0), ypos + (yOffset or 0), tile.width, tile.height)
					end
				end
			end
		end

		-- if layer.type == "objectgroup" then
		--     for _, object in ipairs(layer.objects) do
		--         local ctor = require("src.entities." .. object.type)
		--         local e = ctor(object)
		--         if object.type == "Player" then
		--             player = e
		--         end
		--         world:add(e)
		--     end
		--     tileMap:removeLayer(lindex)
		-- end
	end

	self.width = self.map.width * self.map.tilewidth
	self.height = self.map.height * self.map.tileheight

	return self
end

function TileMap:addBorderCollisions()
	scene:addEntity()
end

function TileMap:update(dt)
end

function TileMap:draw()
	if not self.isDrawing then return end

	local camScale = scene.camera.cam:getScale()
	local l,t = scene.camera.cam:getVisible()
	self.map:draw(math.floor(-l), math.floor(-t), camScale, camScale)

	local items,len = self.bumpWorld:getItems()
	for i,item in ipairs(items) do
		if item.collider and G.debug then
			local x,y,w,h = item.collider.x, item.collider.y, item.collider.w, item.collider.h
			if item.isOneWay then
				love.graphics.setColor(0, 255, 0)
			elseif item.isSlope then
				love.graphics.setColor(255, 255, 0)
			else
				love.graphics.setColor(255, 0, 0)
			end
			love.graphics.rectangle("line", x * self.map.tilewidth, y * self.map.tileheight, w, h)
			love.graphics.setColor(255, 255, 255)
		end
	end
end

return TileMap