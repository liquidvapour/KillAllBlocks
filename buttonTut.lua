local Class = require "lib.middleclass"

local ButtonTut = Class("ButtonTut")

function ButtonTut:initialize(resource, timer)
    self.image = love.graphics.newImage(resource)
    self.button = "right"
    self.location = { x = 500, y = 500, w = 32, h = 32}
    self.dimmed = false
    self.visible = true
    
    local selfRef = self
    timer:addPeriodic(
        0.1, 
        function() 
            selfRef.dimmed = not selfRef.dimmed 
        end)

end

function ButtonTut:draw()
    if not self.visible then return end
    
    local alpha = 255
    if self.dimmed then
        alpha = 100
    end
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.draw(self.image, self.location.x-(self.location.w/2), self.location.y-(self.location.h/2))

end

function ButtonTut:pressed()
    self.visible = false
end

return ButtonTut