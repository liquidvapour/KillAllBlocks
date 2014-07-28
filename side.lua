local Class = require "lib.middleclass"
local GraphicsUtils = require "lib.utils"

local Side = Class("Side")

function Side.drawCanvas()
    Side.canvas = GraphicsUtils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 64, 32, 32)
end

function Side:initialize(world, l, t, w, h, r, g, b)
    self.l = l
    self.t = t
    self.w = w
    self.h = h
    self.r = r or 255
    self.g = g or 255
    self.b = b or 255
    self.tag = "side" --needed for ball's collision system.
    
    world:add(self, l, t, w, h)
    
    self.quad = love.graphics.newQuad(0, 0, w, h, 32, 32)     
end

function Side:draw()
    love.graphics.setColor(self.r, self.g, self.b, 255)
    love.graphics.draw(Side.canvas, self.quad, self.l, self.t)
end

return Side