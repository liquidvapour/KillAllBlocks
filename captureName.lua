local Game = require "game"

local TextCapture = require "ui.textcapture"

local captureName = Game:addState("captureName")

local currentInstance = nil

function captureName:enteredState(finalScore)
    self.finalScore = finalScore
    
    self.textCapture = TextCapture:new(310, 500, 200, 50, 3, self.resourceManager:getResource("NovaMono40"))
    currentInstance = self
    
    love.graphics.setColor(255, 255, 255, 255)
end

function captureName:exitedState(oldState)
    currentInstance = nil
end

function captureName:draw()
    self:printInCenter("High Score!\n "..self.finalScore.."\nPress [ESC] to restart", nil, 40)
    self.scores:draw()
    self.textCapture:draw()
end

function captureName:update(dt)
    self.textCapture:update(dt)
end

function captureName:escPressed()
    self:gotoState("gameover")
end

function captureName:returnPressed()
    if self.textCapture.done then
        self:addScore()
    end
end

function captureName:addScore()
    self.scores:add(self.textCapture.text, self.finalScore)
    self:gotoState("gameover")
end

function love.textinput(text)
    if currentInstance then
        currentInstance.textCapture:textinput(text)
    end
end

return captureName