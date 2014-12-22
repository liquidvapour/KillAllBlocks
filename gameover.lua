local SoundBox = require "soundbox"

local Game = require "game"
local gameover = Game:addState("gameover")

function gameover:enteredState(finalScore)
    self.finalScore = finalScore or 0
    if self.scores:isHighScore(finalScore) then
        self:gotoState("captureName", finalScore)
    end

    self.soundBox = SoundBox:new()
    self.soundBox:startIntroBackingTrack()
end

function gameover:exitedState()
    if self.soundBox then
        self.soundBox:stopIntroBackingTrack()
    end
    --self.soundBox = nil
end

function gameover:draw()
    if not self.finalScore then
        self:printInCenter("Game Over!\n final score: "..self.finalScore.."\nPress [ESC] to restart", nil, 40)
    else
        self:printInCenter("Game Over!\n Press [ESC] to restart", nil, 40)
    end
    self.scores:draw()
end

function gameover:escPressed()
    self:gotoState("menu")
end

return gameover