local Class = require "lib.middleclass"

local SoundBox = Class("SoundBox")

function SoundBox:initialize()
    self.pip = love.audio.newSource("resources/sound/pip.wav", "static")    
    self.splat = love.audio.newSource("resources/sound/splat.wav", "static")    
    self.plink = love.audio.newSource("resources/sound/plink.wav", "static")    
    self.explosion = love.audio.newSource("resources/sound/explosion.wav", "static")    
    self.wobly = love.audio.newSource("resources/sound/wobly.wav", "static")    
end

local function playSource(source)
    if source:isPlaying() then
        source:rewind()
    else
        source:play()
    end
end

function SoundBox:hitSide()
    playSource(self.pip)
end

function SoundBox:hitTarget()
    playSource(self.splat)
end

function SoundBox:hitPaddle()
    playSource(self.plink)
end

function SoundBox:hitGoal()
    playSource(self.explosion)
end

function SoundBox:gameover()
    playSource(self.wobly)
end

return SoundBox 