local Class = require "lib.middleclass"
local Stateful = require "lib.stateful"

local Game = Class("Game"):include(Stateful)

function Game:printInCenter(message)
    local windowWidth = love.window.getWidth()
    local windowHeight = love.window.getHeight()
    
    local windowCenter = windowWidth / 2
    
    local textw = 250
    
    local textl = windowCenter - (textw / 2)
    local textt = windowHeight / 2
    
    love.graphics.printf(message, textl, textt, textw, "center")

end

function Game:initialize()
    self.score = 0
end

function Game:draw()
end

function Game:update(dt)
end

function Game:getScore()
    return self.myScorer:getScore()
end

function Game:setScore(value)
    self.myScorer:setScore(value)
end

function Game:getCombo()
    return self.myScorer:getCombo()
end

return Game