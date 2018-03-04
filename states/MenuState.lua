local Input = require "alphonsus.input"
local Scene = require "alphonsus.Scene"

local UIText = require "alphonsus.entities.UIText"

local Gamestate = require "lib.hump.gamestate"
local flux = require "lib.flux"

local PlayState = require "states.PlayState"

local MenuState = Scene:extend()

function MenuState:enter()
	MenuState.super.enter(self)
	local titleText = UIText(0, -20, "SLUGCASTER", nil, nil, nil, assets.font_lg)
	local subtitle = UIText(0, G.height * 0.8, "PRESS START TO PLAY", nil, nil, 24, assets.font_sm)

	self:addEntity(subtitle)
	self:addEntity(titleText)

	flux.to(titleText.pos, 1, {y = G.height * 0.25})
end

function MenuState:stateUpdate(dt)
	MenuState.super.stateUpdate(self, dt)

	if Input.wasKeyPressed('return') then
		Gamestate.switch(PlayState())
	end
end

return MenuState