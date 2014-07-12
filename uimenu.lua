local Class = require "lib.middleclass"
local tween = require("lib.tween")

local Menu = Class("Menu")


function Menu:initialize(image)
    self.title = {}
    self.title.image = image
    self.title.width = 300
    self.title.height = 200
    self.title.x = love.window.getWidth()/2-(self.title.width/2)
    self.title.y = -self.title.height
    self.title.tween = tween.new(2.6, self.title, {y=100}, 'outBounce')
end

function Menu:start()
    
end

function Menu:update(dt)
    self.title.tween:update(dt)
end

function Menu:draw()
    love.graphics.draw(self.title.image, self.title.x, self.title.y)
    --love.graphics.rectangle("fill", self.title.x, self.title.y, self.title.width, self.title.height)
end

return Menu