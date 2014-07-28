local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local game = require "game"
require "ingame"
require "menu"
require "gameover"
require "captureName"

function love.load()
    local result = love.window.setMode(800, 600, {fullscreen = true})
    print(string.format("setMode result: %s", result))
    print("width: "..love.window.getWidth()..", height:"..love.window.getHeight())

    myGame = game:new()
    myGame:gotoState("menu")
end

function love.update(dt)
    myGame:update(dt)
end

function love.draw()
    myGame:draw()
end

-- Non-player keypresses
function love.keypressed(k)
  if k=="escape" then myGame:escPressed() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
  if k=="delete" then collectgarbage("collect") end
end

function love.mousepressed(x, y, button)
    if button == "l" then
        myGame.useMouse = not myGame.useMouse
    end
end
