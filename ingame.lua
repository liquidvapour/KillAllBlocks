local Game = require "game"
local Ball = require "ball"
local Paddle = require "paddle"

local bump = require "bump"
local bump_debug = require "bump_debug"
local vector = require "hump.vector"
local timer = require "hump.timer"
local scorer = require "scorer"
local Side = require "side"

local ingame = Game:addState("ingame")

local instructions = [[
  pong simple game

    arrows: move
    space: release ball
    tab: toggle debug info
    delete: run garbage collector
]]

-- helper function
local function drawBox(box, r,g,b)
  love.graphics.setColor(r,g,b,70)
  love.graphics.rectangle("fill", box.l, box.t, box.w, box.h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("line", box.l, box.t, box.w, box.h)
end

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

-- Block functions
function ingame:addToBlockList(block)
  self.blocks[#self.blocks+1] = block
end

local function newBlock(world, l,t,w,h, tag)
    local block = {l = l, t = t, w = w, h = h, tag = tag}
    world:add(block, l, t, w, h)

    function block:draw(r,g,b)
        love.graphics.setColor(r,g,b,70)
        love.graphics.rectangle("fill", self.l, self.t, self.w, self.h)
        love.graphics.setColor(r,g,b)
        love.graphics.rectangle("line", self.l, self.t, self.w, self.h)
    end

    return block
end

function ingame:addBlock(l,t,w,h, tag)
    local block = {l=l,t=t,w=w,h=h,tag=tag}
    self:addToBlockList(block)
    self.world:add(block, l,t,w,h)

    return block
end


function ingame:drawBlocks()
    for _,block in ipairs(self.blocks) do
        block:draw(255,0,0)
    end
end

-- Message/debug functions
function ingame:drawMessage()
  local msg = instructions:format(tostring(shouldDrawDebug))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(msg, 550, 10)
  love.graphics.print("score: "..self:getScore()..", combo: "..self:getCombo(), 100, 10)
end

function ingame:drawDebug()
  bump_debug.draw(self.world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580)
end


function ingame:buildTargets()
    math.randomseed(love.timer.getTime())

    local targetWidth = 100
    local targetHeight = 20
    local numRows = 6
    local numColumns = 6
    local count = 0
    
    local tl, tr
    for x = 0, numColumns - 1 do
        for y = 0, numRows - 1 do
            tl = 100 + (x * (targetWidth))
            tr = 100 + (y * (targetHeight))
            self:addToBlockList(newBlock(self.world, tl, tr, targetWidth - 1, targetHeight - 1))
            count = count + 1
        end
    end 

    self.blockCount = count
end


function ingame:enteredState()
    
    self.world = bump.newWorld()
    
    self.blocks = {}
    
    self:addToBlockList(Side:new(self.world, 0,       0, 800,       32))
    self:addToBlockList(Side:new(self.world, 0,      32,  32, 600-32*2))
    self:addToBlockList(Side:new(self.world, 800-32, 32,  32, 600-32*2))

    self.paddle = Paddle:new(self)

    self.goal = Side:new(self.world, 0, 600-16, 800, 16)
    self:addToBlockList(self.goal)

    self:buildTargets()
    
    self.timer = timer:new()
    
    self.ready = false
    self.timer:add(1, function() self.ready = true end)

    self.ball = Ball:new(self.world, self.timer)
    
    self.myScorer = scorer:new(self)
    
    love.graphics.setBackgroundColor(36, 36, 39)
end

function ingame:update(dt)
    self.timer:update(dt)
    self.paddle:update(dt)
    self.ball:update(dt, self)
end

function ingame:draw()
  self:drawBlocks()
  self.ball:draw()
  self.paddle:draw()
  if shouldDrawDebug then self:drawDebug() end
  self:drawMessage()
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame