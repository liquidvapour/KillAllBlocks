local Class = require "lib.middleclass"

local SoundBox = Class("SoundBox")

function SoundBox:initialize()
    self.pip = love.audio.newSource("resources/sound/pip.wav", "static")    
    self.splat = love.audio.newSource("resources/sound/splat.wav", "static")    
    self.plink = love.audio.newSource("resources/sound/plink.wav", "static")    
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

return SoundBox 