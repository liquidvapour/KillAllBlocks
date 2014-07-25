local Class = require "lib.middleclass"
local tween = require("lib.tween")
local utils = require("utils")
local timer = require("hump.timer")

local Menu = Class("Menu")

function Menu:initialize(image)
    self.title = self:createTitle(image)    
    self.menuItems = self:createMenuItems()
    self.selection = self:createSelection()
    self.downPressed = false
    self.upPressed = false
    self.enterPressed = false
    self.onNewGame = nil
    self.onOptions = nil
end

function Menu:createTitle(image)
    local result = {}
    result.image = image
    result.width = 300
    result.height = 200
    result.x = love.window.getWidth()/2-(result.width/2)
    result.y = -result.height
    result.tween = tween.new(2.65, result, {y = 75}, 'outBounce')
    return result
end

function Menu:createSelection()
    local image = love.graphics.newImage("resources/selection.png")
    local result = {
        image = image, 
        currentItemIndex = 1, 
        l = (love.window.getWidth() / 2) - (300 / 2), 
        t = self.menuItems[1].t, 
        tween = nil,
        a = 0
    }
    
    local menuItems = self.menuItems
    
    result.appearingTween = tween.new(2, result, {a = 255})
    
    function result:moveOverTime(itemIndex)
        return tween.new(0.05, self, {t = menuItems[itemIndex].t})
    end
    
    function result:gotoNext()
        self.currentItemIndex = self.currentItemIndex + 1
        if self.currentItemIndex > #menuItems then self.currentItemIndex = 1 end
        self.tween = self:moveOverTime(self.currentItemIndex)
    end

    function result:gotoPreviouse()
        self.currentItemIndex = self.currentItemIndex - 1
        if self.currentItemIndex == 0 then self.currentItemIndex = #menuItems end
        self.tween = self:moveOverTime(self.currentItemIndex)
    end
    
    function result:draw()
        love.graphics.push()
        love.graphics.setColor(255, 255, 255, self.a)
        love.graphics.draw(self.image, self.l, self.t)
        love.graphics.pop()
    end
    
    function result:select()
        local selectedItem = menuItems[self.currentItemIndex]
        if selectedItem.onSelected then
            selectedItem:onSelected()
        end
    end
    
    function result:update(dt)
        self.appearingTween:update(dt)
        if self.tween then
            self.tween:update(dt)
        end 
    end
    
    return result
end

function Menu:createMenuItems()
    local result = utils.newList()
    local itemPause = 0.5
    result:add(self:createItem(
        "resources/newgame.png", 350, itemPause, 
        function() 
            if self.onNewGame then self.onNewGame() end 
        end))
    result:add(self:createItem(
        "resources/options.png", 380, itemPause + 0.1, 
        function() if self.onOptions then self.onOptions() end  end))
    result:add(self:createItem("resources/quit.png", 410, itemPause + 0.2, function() love.event.quit() end))
    return result
end

function Menu:createItem(resource, t, pause, onSelected, r, g, b)
    local image = love.graphics.newImage(resource)
    local menuItem = {
        image = image, 
        l = -150, t = t, w = 300, h = 30, 
        onSelected = onSelected,
        r = r or 255, g = g or 255, b = b or 255, a = 0}
    timer.add(pause, createMenuItemTweenFunction(menuItem, 0.50, "linear"))
    return menuItem
end

function createMenuItemTweenFunction(menuItem, duration, tweenType)
    return function() 
        menuItem.tween = tween.new(duration, menuItem, {l = love.window.getWidth() / 2, a = 255}, tweenType) 
    end
end

function Menu:onDownClicked()
    self.selection:gotoNext()
end

function Menu:onUpClicked()
    self.selection:gotoPreviouse()
end

function Menu:onEnterClicked()
    self.selection:select()
end

function Menu:doKeys()
    if love.keyboard.isDown('down') then
        self.downPressed = true
    elseif self.downPressed then
        self.downPressed = false
        self:onDownClicked()
    end
    
    if love.keyboard.isDown("up") then
        self.upPressed = true
    elseif self.upPressed then
        self.upPressed = false
        self:onUpClicked()
    end
    
    if love.keyboard.isDown("return") then
        self.enterPressed = true
    elseif self.enterPressed then
        print("enter clicked")
        self.enterPressed = false
        self:onEnterClicked()
    end
end

function Menu:update(dt)
    self:doKeys()
    
    self.selection:update(dt)    
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
        love.graphics.draw(v.image, v.l - (v.w / 2), v.t)
    end
    self.selection:draw()
    love.graphics.pop()
end

return Menu