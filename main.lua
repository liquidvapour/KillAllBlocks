local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local game = require "game"
require "ingame"
require "menu"
require "gameover"
require "captureName"

local SoundBox = require "soundbox"
local ProFi = require "lib/ProFi"
-------------------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------------------
sceneWidth, sceneHeight = 800, 600

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------
local canvas
local mesh
local shader = nil 
local myGame

local innerRun = love.run

local profileingActive = false

function love.run()
    if profileingActive then
        ProFi:start()
        print("start run")
        innerRun()
        print("end run")
        ProFi:stop()
        ProFi:writeReport("_profile.txt")
    else
        print("start run")
        innerRun()
        print("end run")
    end
end

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
    print(string.format("setMode result: %s", result))
    print("width: "..love.window.getWidth()..", height:"..love.window.getHeight())

    local soundbox = SoundBox:new()
    
    myGame = game:new(soundbox)
    
    myGame:gotoState("menu")
    
    canvas = love.graphics.newCanvas(sceneWidth, sceneHeight)
    canvas:setFilter('linear', 'linear')
    mesh = getScreenMesh(canvas)
    
    local originalBlendMode = love.graphics.getBlendMode()
    print('originalBlendMode: '..originalBlendMode)

    shader = love.graphics.newShader('shaders/scanline-3x.frag')
    --shader:send('inputSize', {sceneWidth, sceneHeight})
    --shader:send('outputSize', {outputWidth, outputHeight})
    --shader:send('textureSize', {sceneWidth, sceneHeight})
end

function love.update(dt)
    myGame:update(dt)
end

local function drawGameToCanvas()
    canvas:clear()
    love.graphics.setCanvas(canvas)
    love.graphics.setBlendMode('alpha')
    myGame:draw()
    love.graphics.setCanvas()
end

local function drawWithArtifacts()
    drawGameToCanvas()
    
    love.graphics.setBlendMode('premultiplied')    
    love.graphics.setShader(shader)
    love.graphics.draw(mesh, 0, 0)
    love.graphics.setShader()
end

local function cleanDraw()
    drawGameToCanvas()
    
    love.graphics.setBlendMode('premultiplied')    
    love.graphics.draw(mesh, 0, 0)
    love.graphics.setShader()
end

function love.draw()
    cleanDraw()
end

-- Non-player keypresses
function love.keypressed(k)
  if k=="escape" then myGame:escPressed() end
  if k=="return" and myGame.returnPressed then myGame:returnPressed() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
  if k=="delete" then collectgarbage("collect") end
  if k=="right" and myGame.rightPressed then myGame:rightPressed() end
  if k=="up" and myGame.upPressed then myGame:upPressed() end  
  if k=="left" and myGame.leftPressed then myGame:leftPressed() end  
end



function love.mousepressed(x, y, button)
    if button == "l" then
        myGame.useMouse = not myGame.useMouse
    end
end
