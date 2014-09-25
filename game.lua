local Class = require "lib.middleclass"
local Stateful = require "lib.stateful"
local ResourceManager = require "resourceManager"

local HighScores = require "highScores"

local Game = Class("Game"):include(Stateful)

function Game:printInCenter(message)
    local windowWidth = sceneWidth
    local windowHeight = sceneHeight
    
    local windowCenter = windowWidth / 2
    
    local textw = 250
    
    local textl = windowCenter - (textw / 2)
    local textt = windowHeight / 2
    
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