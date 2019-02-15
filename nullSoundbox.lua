local Class = require "lib.middleclass"

local NullSoundBox = Class("NullSoundBox")

function NullSoundBox:initialize()
end

function NullSoundBox:startIntroBackingTrack()
end

function NullSoundBox:stopIntroBackingTrack()
end

function NullSoundBox:startBackingTrack()
end

function NullSoundBox:stopBackingTrack()
end

function NullSoundBox:hitSide()
end

function NullSoundBox:hitTarget()
end

function NullSoundBox:hitPaddle()
end

function NullSoundBox:hitGoal()
end

function NullSoundBox:gameover()
end

return NullSoundBox 