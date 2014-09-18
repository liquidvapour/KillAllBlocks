local Class = require "lib.middleclass"
local Utils = require "lib.utils"
local Paddle = Class("Paddle")

function Paddle:initialize(context)
    self.w = 128
    self.h = 16
    
    self.l = (sceneWidth - self.w) / 2
    self.t = 600-40
    
    self.tag = "side"
    self.velocityX = 0
    self.speed = 600
    self.context = context
    
    context.world:add(self, self.l, self.t, self.w, self.h)
    
    self.image = Utils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 128, 32, 32, 16)
    self.image:setFilter("nearest", "nearest")
    self.quad = love.graphics.newQuad(0, 0, self.w, self.h, self.image:getWidth(), self.image:getHeight())

end

function Paddle:update(dt)
    if not self.context.ready then return end

    local dx, dy = 0, 0
    if self.context.useMouse then
        self.l = love.mouse.getX() - (self.w/2)
    else
        if love.keyboard.isDown("right") then
            self.velocityX = self.speed 
        elseif love.keyboard.isDown("left") then
            self.velocityX = -self.speed
        else
            self.velocityX = 0
        end
        self.l = self.l + (self.velocityX * dt)
    end
    self.context.world:move(self, self.l, self.t)
end

function Paddle:drawBox()
    love.graphics.push()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.quad, self.l, self.t)
    love.graphics.pop()
end

function Paddle:draw()
    self:drawBox()
end

return Paddle