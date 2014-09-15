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
local mesh

local function getScreenMesh(canvas)
    local vertices = {
        {
            0, 0, -- position
            0, 0, -- texture coordinates
            255, 255, 255
        },
        {
            love.window.getWidth(), 0, -- position
            1, 0, -- texture coordinates
            255, 255, 255
        },
        {
            love.window.getWidth(), love.window.getHeight(), -- position
            1, 1, -- texture coordinates
            255, 255, 255
        },
        {
            0, love.window.getHeight(), -- position
            0, 1, -- texture coordinates
            255, 255, 255
        }
    }
        
    return love.graphics.newMesh(vertices, canvas, "fan")
end

function love.load()
    local result = love.window.setMode(1024, 768, {fullscreen = false})
    print(string.format("setMode result: %s", result))
    print("width: "..love.window.getWidth()..", height:"..love.window.getHeight())

    myGame = game:new()
    myGame:gotoState("menu")
    
    canvas = love.graphics.newCanvas(800, 600)
    screenQuad = love.graphics.newQuad(0, 0, 1024, 768, 800, 600)
    mesh = getScreenMesh(canvas)
end

function love.update(dt)
    myGame:update(dt)
end

function love.draw()
    canvas:clear()
    love.graphics.setCanvas(canvas)
    myGame:draw()
    love.graphics.setCanvas()
    
    love.graphics.draw(mesh, 0, 0)
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
