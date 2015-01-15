local Class = require "lib.middleclass"
local Utils = require "lib.utils"
local Target = Class("Target")

function Target.drawCanvas()
    Target.canvas = Utils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 128, 32, 32)
end

function Target:initialize(world, l,t,w,h, tag, timer)
    self.l = l 
    self.t = t 
    self.w = w 
    self.h = h 
    self.tag = tag
    self.timer = timer
    world:add(self, l, t, w, h)
    
    self.quad = love.graphics.newQuad(0, 0, w, h, 32, 32)     
end

function Target:hit()
    self.hot = true
    self.timer:add(0.15, function() self.hot = false end)
end

function Target:draw(r,g,b)
    if self.hot then
        love.graphics.setColor(250, 216, 100, 255)
    else
        love.graphics.setColor(255, 255, 255, 255)
    end
    love.graphics.draw(Target.canvas, self.quad, self.l, self.t)
end

return Target
