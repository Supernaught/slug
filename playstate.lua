local Scene = require "alphonsus.scene"
local Input = require "alphonsus.input"
local GameObject = require "alphonsus.gameobject"

local PaletteSwitcher = require 'lib/PaletteSwitcher'
local bump = require "lib.bump"
local shack = require "lib.shack"
local _ = require "lib.lume"
local moonshine = require "lib.moonshine"
local Gamestate = require "lib.hump.gamestate"

local Square = require "alphonsus.square"
local Player = require "entities.player"
local Bullet = require "entities.bullet"
local Enemy = require "entities.enemy"
local GroundEnemy = require "entities.enemies.groundEnemy"
local FlyingEnemy = require "entities.enemies.flyingEnemy"
local TileMap = require "alphonsus.tilemap"

local PlayState = Scene:extend()

-- entities
local player = {}
local player2 = {}
local middlePoint = {}
local tileMap = {}

-- helper function
function getMiddlePoint(pos1, pos2)
	return (pos1.x + pos2.x)/2 + player.width/2, (pos1.y + pos2.y)/2 - player.width/2
end

function PlayState:enter()
	PlayState.super.enter(self)
	scene = self
	self.bumpWorld = bump.newWorld()

	self.bgColor = {20, 20, 20}

	-- setup tile map
	self.tileMap = TileMap("assets/maps/test.lua", nil, nil, self.bumpWorld)
	self:addEntity(self.tileMap)

	-- setup player
	player = Player(self.tileMap.width/2, 50, 1)
	self:addEntity(player)

	-- add sample enenmy
	self:addEntity(FlyingEnemy(-10, 100))
	-- self:addEntity(FlyingEnemy(self.tileMap.width+16, 100))
	-- self:addEntity(GroundEnemy(80, 100))

	-- setup camera
	self.camera:startFollowing(player)
	self.camera.followSpeed = 5
	-- print(tileMap.width * G.tile_size, tileMap.height * G.tile_size)
	self.camera.cam:setWorld(0,0,(self.tileMap.map.width) * G.tile_size, self.tileMap.map.height * G.tile_size)

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