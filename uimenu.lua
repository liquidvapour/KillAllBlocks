local Class = require "lib.middleclass"
local tween = require("lib.tween")
local utils = require("utils")
local timer = require("hump.timer")
local Menu = Class("Menu")

function Menu:initialize(image)
    self.title = self:createTitle(image)    
    self.menuItems = self:createMenuItems()
end

function Menu:createTitle(image)
    local result = {}
    result.image = image
    result.width = 300
    result.height = 200
    result.x = love.window.getWidth()/2-(result.width/2)
    result.y = -result.height
    result.tween = tween.new(2.65, result, {y=75}, 'outBounce')
    return result
end

function Menu:createMenuItems()
    local result = utils.newList()
    local itemPause = 0.15
    result:add(self:createItem("resources/newgame.png", 350, itemPause * 0, 255, 0, 0))
    result:add(self:createItem("resources/selection.png", 350, itemPause * 0, 255, 0, 0))
    result:add(self:createItem("resources/options.png", 380, itemPause * 1, 0, 255, 0))
    result:add(self:createItem("resources/quit.png", 410, itemPause * 2, 0, 0, 255))
    return result
end

function Menu:createItem(resource, t, pause, r, g, b)
    local image = love.graphics.newImage(resource)
    local menuItem = {image = image, l = -150, t = t, w = 300, h = 30, r = r, g = g, b = b, a = 0}
    timer.add(pause, function() menuItem.tween = tween.new(0.5, menuItem, {l = love.window.getWidth() / 2, a = 255}, "linear") end)
    return menuItem
end

function Menu:update(dt)
    timer.update(dt)
    self.title.tween:update(dt)
    for v in self.menuItems:iterate() do
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
--        love.graphics.setColor(v.r, v.g, v.b, v.a)
--        love.graphics.rectangle("fill", v.l - (v.w / 2), v.t, v.w, v.h)
--        love.graphics.setColor(0, 0, 0)
        love.graphics.draw(v.image, v.l - (v.w / 2), v.t)
    end
    love.graphics.pop()
end

return Menu