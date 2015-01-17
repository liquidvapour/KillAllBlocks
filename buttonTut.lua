local Class = require "lib.middleclass"

local ButtonTut = Class("ButtonTut")

local function lerp(a,b,t) return a+(b-a)*t end
local function sawTooth(t) return t - math.floor(t) end

function ButtonTut:initialize(resource, timer)
    self._location = { x = 0, y = 0 }
    self.image = love.graphics.newImage(resource)
    self.button = "right"
    self.location = { x = 500, y = 500, w = 32, h = 32}
    self.offset = { x = 0, y = 0 }
    self.dimmed = false
    self.visible = true
    
    local selfRef = self
    timer:addPeriodic(
        0.1, 
        function() 
            selfRef.dimmed = not selfRef.dimmed 
        end)

    self.totalTime = 0
end

function ButtonTut:update(dt)
    self.totalTime = self.totalTime + dt    
    local t = sawTooth(self.totalTime)
    self._location.x = lerp(self.location.x, self.location.x + self.offset.x, t)
    self._location.y = lerp(self.location.y, self.location.y + self.offset.y, t)
    print("totalTime:"..self.totalTime..", t:"..t..", x:"..self.location.x..", y:"..self.location.y)
end

function ButtonTut:draw()
    if not self.visible then return end
    
    local alpha = 255
    if self.dimmed then
        alpha = 100
    end
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.draw(self.image, self._location.x-(self.location.w/2), self._location.y-(self.location.h/2))

end

function ButtonTut:pressed()
    self.visible = false
end

return ButtonTut