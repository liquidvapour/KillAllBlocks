local Game = require "game"
local Ball = require "ball"
local Paddle = require "paddle"
local Side = require "side"
local Target = require "target"

local bump = require "bump"
local bump_debug = require "bump_debug"
local vector = require "hump.vector"
local timer = require "hump.timer"
local scorer = require "scorer"

local ingame = Game:addState("ingame")

local instructions = [[
  pong simple game

    arrows: move
    space: release ball
    tab: toggle debug info
    delete: run garbage collector
]]


-- World creation

local hitGoal = false
local playerStates = {}
--local currentState

local function removeItemFrom(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then
            table.remove(tbl, key)
        end 
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function ingame:hitTarget()
    self.myScorer:hitTarget()
end

function ingame:hitSide()
    self.myScorer:hitSide()
end

function ingame:hitBlock(block)
    removeItemFrom(self.blocks, block)
    self.world:remove(block)
    self.blockCount = self.blockCount - 1
    self:hitTarget()
    if self.blockCount == 0 then
        self:gotoState("gameover", self.myScorer:getScore())
    end
end

function ingame:hitPaddle()
    self.myScorer:hitPaddle()
end

function ingame:getScore()
    return self.myScorer:getScore()
end

function ingame:setScore(value)
    self.myScorer:setScore(value)
end

function ingame:getCombo()
    return self.myScorer:getCombo()
end

function ingame:addToBlockList(block)
  self.blocks[#self.blocks+1] = block
end


function ingame:drawBlocks()
    for _,block in ipairs(self.blocks) do
        block:draw(255,0,0)
    end
end

-- Message/debug functions
function ingame:drawMessage()
  local msg = instructions:format(tostring(shouldDrawDebug))
  love.graphics.setColor(0, 0, 0, 170)
  love.graphics.rectangle("fill", 95, 9, 140, 15)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(msg, 550, 10)
  love.graphics.print("score: "..self:getScore()..", combo: "..self:getCombo(), 100, 10)
  love.graphics.print(("draw time: %.3fms"):format(self.drawTime * 1000), 630, 540)
  love.graphics.print(("update time: %.3fms"):format(self.updateTime * 1000), 630, 510)
end

function ingame:drawDebug()
  bump_debug.draw(self.world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580)
  
end


function ingame:setupTargets()

    local targetWidth = 128
    local targetHeight = 32
    local numRows = 6
    local numColumns = 4
    local count = 0
    
    
    local totalWidth = numColumns * targetWidth
    local screenWidth = love.window.getWidth()
    
    local xOffset = (screenWidth - totalWidth) / 2
    
    local tl, tt
    
    Target.drawCanvas()
    
    for x = 0, numColumns - 1 do
        for y = 0, numRows - 1 do
            tl = xOffset + (x * (targetWidth))
            tt = 100 + (y * (targetHeight))
            self:addToBlockList(Target:new(self.world, tl, tt, targetWidth, targetHeight))
            count = count + 1
        end
    end 

    self.blockCount = count
end

function ingame:setupSides()
    Side.drawCanvas()
    self:addToBlockList(Side:new(self.world, 0,       0, 800,       32))
    self:addToBlockList(Side:new(self.world, 0,      32,  32, 600-((32*2)+8)))
    self:addToBlockList(Side:new(self.world, 800-32, 32,  32, 600-((32*2)+8)))
end

function ingame:enteredState()
    math.randomseed(love.timer.getTime())
    
    self.world = bump.newWorld()
    
    self.blocks = {}
    
    self:setupSides()
    
    self.paddle = Paddle:new(self)

    self.goal = Side:new(self.world, 0, 600-24, 800, 24)
    self:addToBlockList(self.goal)

    self:setupTargets()
    
    self.timer = timer:new()
    
    self.ready = false
    self.timer:add(1, function() self.ready = true end)

    self.ball = Ball:new(self.world, self.timer)
    
    self.myScorer = scorer:new(self)
    
    love.graphics.setBackgroundColor(36, 36, 39)
    
    self.drawTime = 0
    self.updateTime = 0
end

function ingame:update(dt)
    local startTime = love.timer.getTime()
    self.timer:update(dt)
    self.paddle:update(dt)
    self.ball:update(dt, self)
    local endTime = love.timer.getTime()
    self.updateTime = endTime - startTime
end

function ingame:draw()
    local startTime = love.timer.getTime()
    self:drawBlocks()
    self.ball:draw()
    self.paddle:draw()
    if shouldDrawDebug then self:drawDebug() end
    self:drawMessage()
    local endTime = love.timer.getTime()
    self.drawTime = endTime - startTime
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame