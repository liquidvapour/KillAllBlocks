local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local game = require "game"
require "ingame"
require "menu"
require "gameover"
require "captureName"

local canvas
local screenQuad

function love.load()
    local result = love.window.setMode(1024, 768, {fullscreen = false})
    print(string.format("setMode result: %s", result))
    print("width: "..love.window.getWidth()..", height:"..love.window.getHeight())

    myGame = game:new()
    myGame:gotoState("menu")
    
    canvas = love.graphics.newCanvas(800, 600)
    screenQuad = love.graphics.newQuad(0, 0, 1024, 768, 800, 600)
end

function love.update(dt)
    myGame:update(dt)
end

function love.draw()
    canvas:clear()
    love.graphics.setCanvas(canvas)
    myGame:draw()
    love.graphics.setCanvas()
    
    love.graphics.draw(canvas, screenQuad, 0, 0)
end

-- Non-player keypresses
function love.keypressed(k)
  if k=="escape" then myGame:escPressed() end
  if k=="return" and myGame.returnPressed then myGame:returnPressed() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
  if k=="delete" then collectgarbage("collect") end
end

function love.mousepressed(x, y, button)
    if button == "l" then
        myGame.useMouse = not myGame.useMouse
    end
end
