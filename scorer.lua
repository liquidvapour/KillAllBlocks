local Class = require "lib.middleclass"

local Scorer = Class("Scorer")

function Scorer:initialize()
    self:setScore(0)
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

function Scorer:getCombo()
    return self.combo
end

function Scorer:getScore()
    return self.score
end

function Scorer:setScore(value)
    self.score = value
end

return Scorer