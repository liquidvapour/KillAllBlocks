local Class = require "lib.middleclass"
local tween = require("lib.tween")
local utils = require("utils")
local Menu = Class("Menu")


function Menu:initialize(image)
    self.title = {}
    self.title.image = image
    self.title.width = 300
    self.title.height = 200
    self.title.x = love.window.getWidth()/2-(self.title.width/2)
    self.title.y = -self.title.height
    self.title.tween = tween.new(2.65, self.title, {y=100}, 'outBounce')
    
    self.menuItems = {}
    
    local menuItem = {text = "start", l = -150, t = 350, w = 300, h = 30}
    menuItem.tween = tween.new(1, menuItem, {l = love.window.getWidth() / 2}, "inCubic")
    table.insert(self.menuItems, menuItem)
    
end

function Menu:start()
    
end

function Menu:update(dt)
    self.title.tween:update(dt)
    for i, v in ipairs(self.menuItems) do
        v.tween:update(dt)
    end
end

function Menu:draw()
    love.graphics.draw(self.title.image, self.title.x, self.title.y)
    --love.graphics.rectangle("fill", self.title.x, self.title.y, self.title.width, self.title.height)
    
    for i, v in ipairs(self.menuItems) do
        utils.printCenter(v.text, v.l, v.t, v.w)
    end
end

return Menu