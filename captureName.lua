local Game = require "game"
local captureName = Game:addState("captureName")

function captureName:enteredState(finalScore)
    self.finalScore = finalScore
    self.scores:add("BBB", finalScore)
end

function captureName:draw()
    self:printInCenter("High Score!\n "..self.finalScore.."\nPress [ESC] to restart")
    self.scores:draw(300, 75)
end

function captureName:escPressed()
    self:gotoState("gameover")
end

return captureName