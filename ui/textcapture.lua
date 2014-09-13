local Class = require "lib.middleclass"

local TextCapture = Class("TextCapture")

function TextCapture:initialize()
    self.text = ""
end

function TextCapture:draw()
    if self.text then
        love.graphics.rectangle('line', 100, 100, 200, 50)
        love.graphics.print(self.text, 100, 100)
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