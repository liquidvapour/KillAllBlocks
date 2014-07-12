local Class = require "lib.middleclass"

local Scorer = Class("Scorer")

function Scorer:initialize()
    self:reset()
end

function Scorer:hitTarget()
    self.combo = self.combo + 1
    self:setScore(self:getScore() + (1 * (self.combo)))    
end

function Scorer:hitSide()
    
end

function Scorer:hitPaddle()
    self:resetCombo()
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

function Scorer:reset()
    self.score = 0
    self:resetCombo()
end

function Scorer:resetCombo()
    self.combo = 0
end

return Scorer