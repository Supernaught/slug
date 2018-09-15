local Scene = require "alphonsus.scene"
local Input = require "alphonsus.input"
local GameObject = require "alphonsus.entities.GameObject"

local Player = require "entities.Player"
local FlyingEnemy = require "entities.enemies.FlyingEnemy"
local Level = require "entities.Level"

local PaletteSwitcher = require 'lib/PaletteSwitcher'
local bump = require "lib.bump"
local shack = require "lib.shack"
local Gamestate = require "lib.hump.gamestate"

local PlayState = Scene:extend()

-- entities
local middlePoint = {}

function PlayState:new()
	PlayState.super.new(self)
end

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

	-- setup shaders
	PaletteSwitcher.init('assets/img/palettes.png', 'alphonsus/shaders/palette.fs');
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
	-- palette switcher
	-- PaletteSwitcher.set();

	PlayState.super.draw(self)

	-- PaletteSwitcher.unset()
end

return PlayState