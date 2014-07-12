local Game = require "game"

local gameover = Game:addState("gameover")

function gameover:draw()
    self:printInCenter("Game Over")
end

function gameover:escPressed()
    self:gotoState("menu")
end

return gameover