local Game = require "game"

local menu = Game:addState("menu")

function menu:draw()
    local windowWidth = love.window.getWidth()
    local windowHeight = love.window.getHeight()
    
    local windowCenter = windowWidth / 2
    
    local textw = 250
    
    local textl = windowCenter - (textw / 2)
    local textt = windowHeight / 2
    
    love.graphics.printf("press [Space] to start", textl, textt, textw, "center")

end

function menu:update(dt)
    if love.keyboard.isDown(' ') then
        self:gotoState("ingame")
    end
end