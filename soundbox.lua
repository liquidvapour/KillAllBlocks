local Class = require "lib.middleclass"

local SoundBox = Class("SoundBox")

function SoundBox:initialize()
    self.pip = love.audio.newSource("resources/sound/pip.wav", "static")    
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
    playSource(self.pip)
end

return SoundBox 