local Class = require "lib.middleclass"

local SoundBox = Class("SoundBox")

function SoundBox:initialize()
    self.pip = love.audio.newSource("resources/sound/pip.wav", "static")    
end

function SoundBox:hitWall()
    self.pip:play()
end

return SoundBox 