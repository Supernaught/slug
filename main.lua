io.stdout:setvbuf("no")
tlog = require "alphonsus.tlog"

local Input = require "alphonsus.input"

local Gamestate = require "lib.hump.gamestate"
local gamera = require "lib.gamera"
local push = require "lib.push"
local shack = require "lib.shack"
local timer = require "lib.hump.timer"

assets = require "assets"

local PlayState = require "playstate"
local MenuState = require "menustate"

function love.load()
	love.mouse.setVisible(false)

	-- setup push screen
	local windowWidth, windowHeight
	local gameWidth, gameHeight
	if G.fullscreen then
		windowWidth, windowHeight = love.window.getDesktopDimensions()

		local scale = G.scale
		G.scale = 1
		gameWidth, gameHeight = windowWidth/scale, windowHeight/scale
		G.width = gameWidth
		G.height = gameHeight
	else
		gameWidth, gameHeight = G.width, G.height
		windowWidth, windowHeight = G.width * G.scale, G.height * G.scale
	end
	push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = G.fullscreen, pixelperfect = true})

	-- setup screenshake
	shack:setDimensions(push:getDimensions())

	-- register controls
	Input.register({
		["zoomIn"] = {"1"},
		["zoomOut"] = {"2"},
		["rotate"] = {"3"},

		["1_left"] = {"left"},
		["1_right"] = {"right"},
		["1_down"] = {"down"},
		["1_up"] = {"up"},
	})

	-- setup Gamestate
	Gamestate.registerEvents()
	playState = PlayState()
	menuState = MenuState()
	Gamestate.switch(menuState)
	Gamestate.switch(playState)
end

function love.update(dt)
	shack:update(dt)
	timer.update(dt)
end

function love.draw()
end

function setupBgMusic()
	-- assets.music:setVolume(0.8)
	-- assets.music:setLooping(true)
	-- assets.music:play()
end