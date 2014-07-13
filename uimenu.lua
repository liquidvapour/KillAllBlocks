local Class = require "lib.middleclass"
local tween = require("lib.tween")
local utils = require("utils")
local timer = require("hump.timer")
local Menu = Class("Menu")


function Menu:initialize(image)
    self.title = {}
    self.title.image = image
    self.title.width = 300
    self.title.height = 200
    self.title.x = love.window.getWidth()/2-(self.title.width/2)
    self.title.y = -self.title.height
    self.title.tween = tween.new(2.65, self.title, {y=75}, 'outBounce')
    
    self.menuItems = {}
    
    table.insert(self.menuItems, self:createItem("start", 350, 0, 255, 0, 0))
    table.insert(self.menuItems, self:createItem("options 01", 380, 1, 0, 255, 0))
    table.insert(self.menuItems, self:createItem("options 02", 410, 2, 0, 0, 255))
end

function Menu:createItem(message, t, pause, r, g, b)
    local menuItem = {text = message, l = -150, t = t, w = 300, h = 30, r = r, g = g, b = b, a = 0}
    timer.add(pause, function() menuItem.tween = tween.new(2.5, menuItem, {l = love.window.getWidth() / 2, a = 255}, "linear") end)
    return menuItem
end

function Menu:start()
    
end

function Menu:update(dt)
    timer.update(dt)
    self.title.tween:update(dt)
    for i, v in ipairs(self.menuItems) do
        if v.tween then
            v.tween:update(dt)
        end
    end
end

function Menu:draw()
    love.graphics.push()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.title.image, self.title.x, self.title.y)
    --love.graphics.rectangle("fill", self.title.x, self.title.y, self.title.width, self.title.height)
    
    for i, v in ipairs(self.menuItems) do
        love.graphics.setColor(v.r, v.g, v.b, v.a)
        love.graphics.rectangle("fill", v.l - (v.w / 2), v.t, v.w, v.h)
        love.graphics.setColor(0, 0, 0)
        utils.printCenter(v.text, v.l, v.t, v.w)
    end
    love.graphics.pop()
end

return Menu