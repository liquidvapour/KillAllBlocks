local Game = require "game"
local uimenu = require "uimenu"
local menuState = Game:addState("menu")


function menuState:draw()

    love.graphics.draw(self.backgroundImage, self.backgroundQuad, 0, 0)

    local windowWidth = love.window.getWidth()
    local windowHeight = love.window.getHeight()


    
    local windowCenter = windowWidth / 2
    
    local textw = 250
    
    local textl = windowCenter - (textw / 2)
    local textt = windowHeight / 2
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("press [Space] to start", textl, textt, textw, "center")
    self.menu:draw()
end

function menuState:enteredState()
    local image = love.graphics.newImage("resources/title.png")
    self.menu = uimenu:new(image)
    self.menu.onNewGame = function() self:gotoState("ingame") end
    
    self.backgroundImage = love.graphics.newImage("resources/clouds01.png")
    self.backgroundImage:setWrap("repeat", "repeat")
    self.backgroundQuad = love.graphics.newQuad(0, 0, love.window.getWidth(), love.window.getHeight(), 128, 128)
end

function menuState:update(dt)
    if love.keyboard.isDown(' ') then
        self:gotoState("ingame")
    end
    
    self.menu:update(dt)
end

function menuState:escPressed()
    love.event.quit()
end

return menuState