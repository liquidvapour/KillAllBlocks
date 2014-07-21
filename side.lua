local Class = require "lib.middleclass"

local Side = Class("Side")

function Side:initialize(world, l, t, w, h, r, g, b)
    self.l = l
    self.t = t
    self.w = w
    self.h = h
    self.r = r or 255
    self.g = g or 255
    self.b = b or 255
    self.tag = "side" --needed for balls collision system.
    
    world:add(self, l, t, w, h)
    
    self.image = love.graphics.newImage("resources/circuit.png")
    self.image:setWrap("repeat", "repeat")

    self.quad = love.graphics.newQuad(0, 0, w, h, self.image:getWidth(), self.image:getHeight())
end

function Side:draw()
    love.graphics.push()
    love.graphics.setColor(self.r, self.g, self.b, 255)
    love.graphics.draw(self.image, self.quad, self.l, self.t)
    love.graphics.pop()
end

return Side