local Class = require "lib.middleclass"

local TextCapture = Class("TextCapture")

function TextCapture:initialize(l, t, w, h, length, font)
    self.text = ""
    self.l = l or 100
    self.t = t or 100
    self.w = w or 200
    self.h = h or 50
    self.length = length or 20
    self.font = font
end

function TextCapture:draw()
    if self.text then
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(self.font)
        
        local r, g, b, a = love.graphics.getColor()
        if self.done then
            love.graphics.setColor(255, 255, 255)
        else
            love.graphics.setColor(200, 100, 200)
        end
        
        
        
        love.graphics.rectangle('line', self.l, self.t, self.w, self.h)
        love.graphics.print(self.text, self.l, self.t)
        love.graphics.setColor(r, g, b, a)
        local oldFont = love.graphics.setFont(oldFont)
    end
end

function TextCapture:update(dt)

end

function TextCapture:textinput(text)
    
    
    if not self.done and text:find('%a') then
        self.text = self.text..text
    end
    print('text length: '..self.text:len())
    if self.text:len() == self.length then 
        self.done = true
    end
end

return TextCapture