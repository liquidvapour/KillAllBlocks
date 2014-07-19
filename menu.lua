local Game = require "game"
local uimenu = require "uimenu"
local Background = require "background"
local menuState = Game:addState("menu")

function menuState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    self.backg:draw()
    self.backg2:draw()

    local windowWidth = love.window.getWidth()
    local windowHeight = love.window.getHeight()
   
    local windowCenter = windowWidth / 2
    
    local textw = 250
    
    local textl = windowCenter - (textw / 2)
    local textt = windowHeight / 2
    love.graphics.printf("press [Space] to start", textl, textt, textw, "center")
    self.menu:draw()
end

function menuState:enteredState()
    local image = love.graphics.newImage("resources/title.png")
    self.menu = uimenu:new(image)
    self.menu.onNewGame = function() self:gotoState("ingame") end
    
    self.backgroundImage = love.graphics.newImage("resources/clouds01.png")
    self.backgroundImage:setWrap("repeat", "repeat")
    
    self.backg = Background:new(self.backgroundImage, 0, 0, 50, -1, -1)    
    self.backg2 = Background:new(self.backgroundImage, 0, 65, 20, 1, 0)
    love.graphics.setBackgroundColor(0, 0, 0)
end

function menuState:exitedState()
	self.menu = nil
	self.backgroundImage = nil
	self.backgroundQuad = nil
end

function menuState:update(dt)
    self.backg:update(dt)
    self.backg2:update(dt)
    
    if love.keyboard.isDown(' ') then
        self:gotoState("ingame")
    end
    
    if self.menu then
        self.menu:update(dt)
    end
end

function menuState:escPressed()
    love.event.quit()
end

return menuState