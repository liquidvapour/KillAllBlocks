local Game = require "game"

local gameover = Game:addState("gameover")

function gameover:enteredState(finalScore)
    self.finalScore = finalScore
end

function gameover:draw()
    self:printInCenter("Game Over!\n final score: "..self.finalScore.."\nPress [ESC] to restart")
end

function gameover:escPressed()
    self:gotoState("menu")
end

return gameover