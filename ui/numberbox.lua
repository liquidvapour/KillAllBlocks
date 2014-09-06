local Class = require "lib.middleclass"
local tween = require "lib.tween"

local NumberBox = Class("NumberBox")

function NumberBox:initialize(l, t, w, font)
    self.l = l
    self.t = t
    self.w = w
    self.value = 0
    self.font = font
end

function NumberBox:setValue(value)
    if self.value == value then return end
    
    self.tween = tween.new(0.2, self, {value = value})
end

function NumberBox:update(dt)
    if self.tween then
        self.tween:update(dt)
    end
end

function NumberBox:draw()
    local currentFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    love.graphics.printf(string.format('%i', self.value), self.l, self.t, self.w, 'right')
    love.graphics.setFont(currentFont)
end

return NumberBox