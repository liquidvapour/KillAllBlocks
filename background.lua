local Class = require "lib.middleclass"

local Background = Class("background")

local width, height = 128, 128

local function normalize(x, y)
    if x == 0 and y == 0 then return x, y end

    local length = math.sqrt(x * x + y * y)

    if length == 1 then return x, y end

    nx, ny = x / length, y / length

    return x / length, y / length
end

function Background:initialize(image, x, y, speed, vx, vy)
    self.x = x or 0
    self.y = y or 0
    self.image = image
    self.speed = speed or 0
    self.vx, self.vy = normalize(vx, vy)
    self.quad = love.graphics.newQuad(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), width, height)
end

function Background:update(dt)
    self.x = (self.x + (self.speed * self.vx * dt)) % width
    self.y = (self.y + (self.speed * self.vy * dt)) % height
    self.quad:setViewport(self.x, self.y, love.graphics.getWidth(), love.graphics.getHeight())
end

function Background:draw()
    love.graphics.draw(self.image, self.quad, 0, 0)
end

return Background
