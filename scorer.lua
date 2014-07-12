local Class = require "lib.middleclass"

local Scorer = Class("Scorer")

function Scorer:initialize(game)
    self.game = game
    self.game:setScore(0)
    self.combo = 1
end

function Scorer:hitTarget()
    self:setScore(self:getScore() + (1 * self.combo))    
    self.combo = self.combo + 1
end

function Scorer:hitSide()
    
end

function Scorer:hitPaddle()
    self.combo = 1
end

function Scorer:getScore()
    return self.game:getScore()
end

function Scorer:setScore(value)
    return self.game:setScore(value)
end

return Scorer