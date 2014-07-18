local Game = require "game"

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
local world 


-- ball functions
local ball

local blocks 
local goal
local hitGoal = false
local playerStates = {}
local ready = false
--local currentState

local function removeItemFrom(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then
            table.remove(tbl, key)
        end 
    end
end

function ingame:updatePaddle(dt)
    if not ready then return end

    local dx, dy = 0, 0
    if self.useMouse then
        self.paddle.l = love.mouse.getX() - (self.paddle.w/2)
    else
        if love.keyboard.isDown("right") then
            dx = self.paddle.speed * dt
        elseif love.keyboard.isDown("left") then
            dx = -self.paddle.speed * dt
        end
        self.paddle.l = self.paddle.l + dx
    end
    
    world:move(self.paddle, self.paddle.l, self.paddle.t)
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


function ingame:hitTarget()
    self.myScorer:hitTarget()
end

function ingame:hitSide()
    self.myScorer:hitSide()
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

local function drawBall()
    drawBox(ball, ball.r, ball.g, ball.b)
end

-- Block functions
local function addBlock(l,t,w,h, tag)
  local block = {l=l,t=t,w=w,h=h,tag=tag}
  blocks[#blocks+1] = block
  world:add(block, l,t,w,h)
  return block
end

local function drawBlocks()
  for _,block in ipairs(blocks) do
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

local function newBall()
    local result = {
        l = 50, t = 50, w = 20, h = 20, 
        velocity = vector(50, 267), 
        speed = 300, 
        inplay = true, 
        currentState = "onGoal",
        r = 255, g = 0, b = 0}

    function result:setCurrentState(state)
        self.currentState = state
    end
    
    function result:moveTo(l, t)
        self.l, self.t = l, t
        world:move(self, l, t)
    end

    function result:update(dt, context)
        self.states[self.currentState](self, context, dt)
    end

    function result.updatePlayer(self, context, dt)
      local dx = self.velocity.x * dt
      local dy = self.velocity.y * dt
      
      if dx ~= 0 or dy ~= 0 then
        local future_l, future_t = self.l + dx, self.t + dy
        local cols, len = world:check(self, future_l, future_t)
        if len == 0 then
            self:moveTo(future_l, future_t)
        else
          local col, tl, tt, bl, bt
          while len > 0 do
            col = cols[1]
            
            
            local hitPaddle = col.other == context.paddle
            
            tl,tt,_,_,bl,bt = col:getBounce()
            self:moveTo(tl, tt)
            
            cols, len = world:check(self, bl, bt)
            if len == 0 then
                self:moveTo(bl, bt)
            end
            
            a = vector(tl, tt)
            b = vector(bl, bt)
            dir = b - a
            dir = dir:normalized()
            
            if hitPaddle then
                local playerCenterX = tl + (self.w / 2)
                local paddleCenterX = context.paddle.l + (context.paddle.w / 2)            
                local collisionCenter = paddleCenterX - playerCenterX
                local offset = -(collisionCenter / (context.paddle.w / 2))
                offset = math.clamp(-1, offset, 1)
                dir = vector(offset, -1.0):normalized()
                context:hitPaddle()
            end
            
            self.velocity = dir * self.velocity:len()
           
            if col.other == goal then
                self:setCurrentState("onGoal")
            end
            
            if col.other.tag == "side" then
                context:hitSide()
            else
                removeItemFrom(blocks, col.other)
                world:remove(col.other)
                context.blockCount = context.blockCount - 1
                context:hitTarget()
                if context.blockCount == 0 then
                    context:gotoState("gameover", context.myScorer:getScore())
                end
            end
          end
        end
      end
    end

    function result.updatePlayerOnPaddle(self, context, dt)
        local pl, pt = context.paddle.l, context.paddle.t
        self:moveTo(pl + (context.paddle.w / 2) - (self.w / 2), pt - (self.h + 1))
        
        if love.keyboard.isDown(" ") then        
            self:setCurrentState("playing")
            local dir = vector(0 + (math.random() *0.2), 1):normalized()
            self.velocity = dir * self.speed
        end
    end
    
    result.states = {playing = result.updatePlayer, onGoal = result.updatePlayerOnPaddle}
    
    return result
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
            addBlock(tl,
                     tr,
                     targetWidth - 1,
                     targetHeight - 1)
            count = count + 1
        end
    end 

    self.blockCount = count
end

local function newPaddle()
    local paddle = addBlock(350, 600-32, 100, 16, "side")
    paddle.velocityX = 0;
    paddle.speed = 700;
    return paddle
end

function ingame:enteredState()
    ball = newBall()

    world = bump.newWorld()
    world:add(ball, ball.l, ball.t, ball.w, ball.h)

    blocks = {}
    
    addBlock(0,       0, 800,       32, "side")
    addBlock(0,      32,  32, 600-32*2, "side")
    addBlock(800-32, 32,  32, 600-32*2, "side")

    self.paddle = newPaddle()

    goal = addBlock(0, 600-16, 800, 16, "side")

    self:buildTargets()
    

    
    self.timer = timer:new()
    
    ready = false
    self.timer:add(1, function() ready = true end)

    local target = {r = 0, g = 255}
    self.timer:tween(1, ball, target, "in-quint")
    
    self.myScorer = scorer:new(self)
end

function ingame:update(dt)
    self.timer:update(dt)
    self:updatePaddle(dt)
    ball:update(dt, self)
end

function ingame:draw()
  drawBlocks()
  drawBall()
  if shouldDrawDebug then drawDebug() end
  self:drawMessage()
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame