local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local game = require "game"
require "ingame"
require "menu"

function love.load()
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
  if k=="escape" then love.event.quit() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
  if k=="delete" then collectgarbage("collect") end
end
