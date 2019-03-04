local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local game = require "game"
require "ingame"
require "menu"
require "gameover"
require "captureName"

local SoundBox = require "soundbox"
local NullSoundBox = require "nullSoundbox"
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

-- local innerRun = love.run

local profileingActive = false

-- function love.run()
--     run = innerRun()
--     return function()
--         if profileingActive then
--             ProFi:start()
--             print("start run")
--             run()
--             print("end run")
--             ProFi:stop()
--             ProFi:writeReport("_profile.txt")
--         else
--             print("start run")
--             run()
--             print("end run")
--         end
--     end
-- end

local function getScreenMesh(canvas)
    local vertices = {
        {
            0, 0, -- position
            0, 0, -- texture coordinates
            1, 1, 1
        },
        {
            love.graphics.getWidth(), 0, -- position
            1, 0, -- texture coordinates
            1, 1, 1
        },
        {
            love.graphics.getWidth(), love.graphics.getHeight(), -- position
            1, 1, -- texture coordinates
            1, 1, 1
        },
        {
            0, love.graphics.getHeight(), -- position
            0, 1, -- texture coordinates
            1, 1, 1
        }
    }
        
    result = love.graphics.newMesh(vertices, "fan")
    result:setTexture(canvas)
    return result
end

function love.load()
    print(string.format("setMode result: %s", result))
    print("width: "..love.graphics.getWidth()..", height:"..love.graphics.getHeight())

    --local soundbox = SoundBox:new()
    local soundbox = NullSoundBox:new()

    print('sandbox: '..soundbox)

    myGame = game:new(soundbox)
    
    myGame:gotoState("menu")
    
    canvas = love.graphics.newCanvas(sceneWidth, sceneHeight)
    canvas:setFilter('linear', 'linear')
    mesh = getScreenMesh(canvas)
    
    local originalBlendMode = love.graphics.getBlendMode()
    print('originalBlendMode: '..originalBlendMode)

    --shader = love.graphics.newShader('shaders/scanline-3x.frag')
    --shader:send('inputSize', {sceneWidth, sceneHeight})
    --shader:send('outputSize', {outputWidth, outputHeight})
    --shader:send('textureSize', {sceneWidth, sceneHeight})
end

local minDT = 1/60
local nextTime = love.timer.getTime() 

function love.update(dt)
    print("dt: "..(dt*1000))
    nextTime = nextTime + minDT
    myGame:update(dt)
end

local function drawGameToCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setBlendMode('alpha')
    myGame:draw()
    love.graphics.setCanvas()
end

local function drawWithArtifacts()
    drawGameToCanvas()
    
    love.graphics.setBlendMode('alpha', 'premultiplied')    
    love.graphics.setShader(shader)
    love.graphics.draw(mesh, 0, 0)
    love.graphics.setShader()
end

local function cleanDraw()
    drawGameToCanvas()
    
    love.graphics.setBlendMode('alpha', 'premultiplied')    
    love.graphics.draw(mesh, 0, 0)
    love.graphics.setShader()
end

function love.draw()
    cleanDraw()
    
    local currentTime = love.timer.getTime()
	if nextTime <= currentTime then
		nextTime = currentTime
    else
        --love.timer.sleep(nextTime - currentTime)
	end
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
