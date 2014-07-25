local List = require "lib.list"

local Class = require "lib.middleclass"

local HighScores = Class("HighScores")

function HighScores:initialize()
    self.highScores = List:new({
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100},
        {name = "AAA", score = 100}
    })
end

function HighScores:getScores()
    return self.highScores:getIterator()
end

function HighScores:isHighScore(score)
    if score == nil then return false end
    
    for v in self.highScores:getIterator() do
        if score > v.score then
            return true
        end
    end
    
    return false
end

function HighScores:add(name, score)
    self.highScores:add({name = name, score = score})
    self.highScores:sort(function(a, b) 
        return a.score > b.score
    end)
    self.highScores:removeTail()
end

function HighScores:draw(l, t)
    local i = 1
    for score in self:getScores() do
        love.graphics.print(i..": "..score.name..": "..score.score, l, t)
        i = i + 1
        t = t + 20
    end
end


return HighScores