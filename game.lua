local Class = require "lib.middleclass"
local Stateful = require "lib.stateful"
local ResourceManager = require "resourceManager"

local HighScores = require "highScores"

local Game = Class("Game"):include(Stateful)

function Game:printInCenter(message, x, y)
    local windowWidth = sceneWidth
    local windowHeight = sceneHeight
    
    local windowCenterL = x or windowWidth / 2
    local windowCenterT = y or windowHeight / 2
    local textw = 250
    
    local textl = windowCenterL - (textw / 2)
    local textt = windowCenterT
    
    love.graphics.printf(message, textl, textt, textw, "center")

end

function Game:initialize()
    self.useMouse = false
    self.resourceManager = ResourceManager:new()
    self.scores = HighScores:new(self.resourceManager)
end

function Game:draw()
end

function Game:update(dt)
end

return Game