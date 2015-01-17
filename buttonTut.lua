local Class = require "lib.middleclass"

local ButtonTut = Class("ButtonTut")

function ButtonTut:initialize(resource, timer)
    self.image = love.graphics.newImage(resource)
    self.button = "right"
    self.location = { x = 500, y = 500, w = 32, h = 32}
    self.visible = false
    
    local selfRef = self
    timer:addPeriodic(
        0.1, 
        function() 
            selfRef.visible = not selfRef.visible 
        end)

end

function ButtonTut:draw()
    local alpha = 255
    if self.visible then
        alpha = 100
    end
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.draw(self.image, self.location.x-(self.location.w/2), self.location.y-(self.location.h/2))
end

return ButtonTut