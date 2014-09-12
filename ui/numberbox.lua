local Class = require "lib.middleclass"
local tween = require "lib.tween"

local NumberBox = Class("NumberBox")

function NumberBox:initialize(l, t, w, font)
    self.l = l
    self.t = t
    self.w = w
    self.value = 0
    self.font = font
    self.scale = 1
    self.animating = false
end

function NumberBox:setValue(value)
    if self.value == value then return end
    
    self.tween = tween.new(0.2, self, {value = value})

    self.startAnim = true
end

local function sinIt(time, begin, change, duration) return change * math.sin(time / duration * (math.pi)) + begin end
local scaleTime = 0.15

function NumberBox:update(dt)
    if self.tween then
        self.tween:update(dt)
    end
    
    if self.startAnim and not self.animating then
        self.startAnim = false
        self.animating = true
        self.animTime = 0
    end
    
    if self.animating then
        if self.animTime <= scaleTime then
            self.animTime = self.animTime + dt
            self.scale = sinIt(self.animTime, 1, 1.075 - 1, scaleTime)
        else
            self.animating = false
            self.scale = 1
        end
    end
end

function NumberBox:draw()
    local currentFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    local halfWidth = self.w / 2
    local tl = self.l + (halfWidth)
    love.graphics.push()
    love.graphics.translate(tl, 0)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.printf(string.format('%i', self.value), -(halfWidth), self.t, self.w, 'right')
    love.graphics.setFont(currentFont)
    love.graphics.pop()
end

return NumberBox