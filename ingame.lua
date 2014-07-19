local Game = require "game"
local Ball = require "ball"

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
function ingame:addBlock(l,t,w,h, tag)
  local block = {l=l,t=t,w=w,h=h,tag=tag}
  self.blocks[#self.blocks+1] = block
  self.world:add(block, l,t,w,h)
  return block
end

function ingame:drawBlocks()
  for _,block in ipairs(self.blocks) do
    drawBox(block, 255,0,0)
  end
end

-- Message/debug functions
function ingame:drawMessage()
  local msg = instructions:format(tostring(shouldDrawDebug))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(msg, 550, 10)
  love.graphics.print("score: "..self:getScore()..", combo: "..self:getCombo(), 100, 10)
end

local function drawDebug()
  bump_debug.draw(world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580)
end


function ingame:buildTargets()
    math.randomseed(love.timer.getTime())

    self.blockCount = 30

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
            self:addBlock(tl,
                     tr,
                     targetWidth - 1,
                     targetHeight - 1)
            count = count + 1
        end
    end 

    self.blockCount = count
end

local function newPaddle(context)

    local paddle = {l = 350, t = 600-32, w = 100, h = 16, tag = "side", velocityX = 0, speed = 700}
    context.world:add(paddle, paddle.l, paddle.t, paddle.w, paddle.h)
    
    function paddle:update(dt)
        if not context.ready then return end

        local dx, dy = 0, 0
        if context.useMouse then
            self.l = love.mouse.getX() - (self.w/2)
        else
            if love.keyboard.isDown("right") then
                dx = self.speed * dt
            elseif love.keyboard.isDown("left") then
                dx = -self.speed * dt
            end
            self.l = self.l + dx
        end
        context.world:move(self, self.l, self.t)
    end

    function paddle:draw()
        drawBox(paddle, 255, 0, 0)
    end
    
    return paddle
    
end

function ingame:enteredState()
    
    self.world = bump.newWorld()
    
    self.blocks = {}
    
    self:addBlock(0,       0, 800,       32, "side")
    self:addBlock(0,      32,  32, 600-32*2, "side")
    self:addBlock(800-32, 32,  32, 600-32*2, "side")

    self.paddle = newPaddle(self)

    self.goal = self:addBlock(0, 600-16, 800, 16, "side")

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
  if shouldDrawDebug then drawDebug() end
  self:drawMessage()
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame