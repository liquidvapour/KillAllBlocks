local Class = require "lib.middleclass"

local Side = Class("Side")

local function getDrawableFromTileMap(resourceName, tl, tt, tw, th)
    local image = love.graphics.newImage(resourceName)
    local quad = love.graphics.newQuad(tl, tt, tw, th, image:getWidth(), image:getHeight())
    local canvas = love.graphics.newCanvas(tw, th)
    canvas:setWrap("repeat", "repeat")
    love.graphics.setCanvas(canvas)
    canvas:clear()
    love.graphics.draw(image, quad, 0, 0)
    love.graphics.setCanvas()
    return canvas
end

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
    
    self.canvas = getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 64, 32, 32)
    self.quad = love.graphics.newQuad(0, 0, w, h, 32, 32)     
end

function Side:draw()
    love.graphics.push()
    love.graphics.setColor(self.r, self.g, self.b, 255)
    love.graphics.draw(self.canvas, self.quad, self.l, self.t)
    love.graphics.pop()
end

return Side