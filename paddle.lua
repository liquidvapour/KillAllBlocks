local Class = require "lib.middleclass"

local Paddle = Class("Paddle")

function Paddle:initialize(context)
    self.l = 350
    self.t = 600-32
    self.w = 100
    self.h = 16
    self.tag = "side"
    self.velocityX = 0
    self.speed = 700
    self.context = context
    
    context.world:add(self, self.l, self.t, self.w, self.h)
    
    self.image = love.graphics.newImage("resources/paddle.png")
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
            dx = self.speed * dt
        elseif love.keyboard.isDown("left") then
            dx = -self.speed * dt
        end
        self.l = self.l + dx
    end
    self.context.world:move(self, self.l, self.t)
end

function Paddle:drawBox()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.quad, self.l, self.t)
end

function Paddle:draw()
    self:drawBox()
end

return Paddle