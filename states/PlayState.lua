local Scene = require "alphonsus.scene"
local Input = require "alphonsus.input"
local GameObject = require "alphonsus.entities.GameObject"

local Player = require "entities.Player"
local FlyingEnemy = require "entities.enemies.FlyingEnemy"
local Level = require "entities.Level"

local PaletteSwitcher = require 'lib/PaletteSwitcher'
local bump = require "lib.bump"
local shack = require "lib.shack"
local moonshine = require "lib.moonshine"
local Gamestate = require "lib.hump.gamestate"

local PlayState = Scene:extend()

-- entities
local middlePoint = {}

function PlayState:new()
	PlayState.super.new(self)
end

-- helper function
-- function getMiddlePoint(pos1, pos2)
-- 	return (pos1.x + pos2.x)/2 + self.player.width/2, (pos1.y + pos2.y)/2 - self.player.width/2
-- end

function PlayState:enter()
	PlayState.super.enter(self)

	self.player = {}

	scene = self
	self.bumpWorld = bump.newWorld()

	self.bgColor = {20, 20, 20}

	-- setup player
	self.player = Player(60, 60, 1)
	self:addEntity(self.player)

	-- setup level
	self.level = Level(self.player)
	self:addEntity(self.level)

	-- add sample enenmy
	-- self:addEntity(FlyingEnemy(-10, 100))

	-- setup camera
	-- self.camera:startFollowing(self.player)
	self.camera.followSpeed = 5
	-- self.camera.cam:setWorld(0,0,(self.level.tileMap.map.width) * G.tile_size, self.level.tileMap.map.height * G.tile_size)

	-- setup shaders
	PaletteSwitcher.init('assets/img/palettes.png', 'alphonsus/shaders/palette.fs');
	sepiaShader = love.graphics.newShader('alphonsus/shaders/sepia.fs')
	bloomShader = love.graphics.newShader('alphonsus/shaders/bloom.fs')

	effect = moonshine(moonshine.effects.filmgrain)
	-- effect.filmgrain.size = 2
end

function PlayState:stateUpdate(dt)
	PlayState.super.stateUpdate(self, dt)

	if Input.wasKeyPressed('`') then
		G.debug = not G.debug
 	end

 	if Input.wasKeyPressed('r') then
		Gamestate.switch(self)
	end
end

function PlayState:draw()
	-- moonshine shader
	-- effect(function()
		-- PlayState.super.draw(self)
	-- end)

	-- palette switcher
	-- PaletteSwitcher.set();
	-- love.graphics.setShader(bloomShader)

	PlayState.super.draw(self)

	-- PaletteSwitcher.unset()
	-- love.graphics.setShader()
end

return PlayState