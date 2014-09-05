local Class = require "lib.middleclass"

local Scorer = Class("Scorer")

function Scorer:initialize()
    self:reset()
end

function Scorer:hitTarget()
    self.combo = self.combo + 1
    self.score = self.score + (self.combo * self.combo)
end

function Scorer:hitSide()
    
end

function Scorer:hitPaddle()
--    self:resetCombo()
    self.combo = self.combo - 1
    if self.combo < 0 then
        self.combo = 0
    end
end

function Scorer:hitGoal()
    self.combo = 0
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
    self:resetScore()
    self:resetCombo()
end

function Scorer:resetScore()
    self.score = 0
end

function Scorer:resetCombo()
    self.combo = 0
end

return Scorer