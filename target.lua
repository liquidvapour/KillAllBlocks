local Class = require "lib.middleclass"
local Utils = require "lib.utils"
local Target = Class("Target")
Target.canvas = Utils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 128, 32, 32)

function Target:initialize(world, l,t,w,h, tag)
    self.l = l 
    self.t = t 
    self.w = w 
    self.h = h 
    self.tag = tag
    world:add(self, l, t, w, h)
    
    self.quad = love.graphics.newQuad(0, 0, w, h, 32, 32)     
end

function Target:draw(r,g,b)
    --love.graphics.setColor(r,g,b,70)
    --love.graphics.rectangle("fill", self.l, self.t, self.w, self.h)
    --love.graphics.setColor(r,g,b)
    --love.graphics.rectangle("line", self.l, self.t, self.w, self.h)
    love.graphics.push()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Target.canvas, self.quad, self.l, self.t)
    love.graphics.pop()

end

return Target