local Class = require "lib.middleclass"

local Background = Class("background")

local width, height = 128, 128

function Background:initialize(image, speed, vx, vy)
    self.x = 0
    self.y = 0
    self.image = image
    self.speed = speed or 0
    self.vx = vx or 0
    self.vy = vy or 0
    self.quad = love.graphics.newQuad(0, 0, love.window.getWidth(), love.window.getHeight(), width, height)
end

function Background:update(dt)
    self.x = (self.x + (self.speed * self.vx * dt)) % width
    self.y = (self.y + (self.speed * self.vy * dt)) % height
    self.quad:setViewport(self.x, self.y, love.window.getWidth(), love.window.getHeight())
end

function Background:draw()
    love.graphics.draw(self.image, self.quad, 0, 0)
end

return Background