local Class = require "lib.middleclass"

local TextCapture = Class("TextCapture")

function TextCapture:initialize(l, t, w, h)
    self.text = ""
    self.l = l or 100
    self.t = t or 100
    self.w = w or 200
    self.h = h or 50
end

function TextCapture:draw()
    if self.text then
        love.graphics.rectangle('line', self.l, self.t, self.w, self.h)
        love.graphics.print(self.text, self.l, self.t)
    end
end

function TextCapture:update(dt)
end

function TextCapture:textinput(text)
    if text: find('%a') then
        self.text = self.text..text
    end
end

return TextCapture