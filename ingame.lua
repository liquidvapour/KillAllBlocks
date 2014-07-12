local Game = require "game"

local bump = require "bump"
local bump_debug = require "bump_debug"
local vector = require "hump.vector"
local timer = require "hump.timer"

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
local paddle 
local goal
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

local ready = false

local function updatePaddle(dt)
    if not ready then return end

    local dx, dy = 0, 0
    if love.keyboard.isDown("right") then
        dx = paddle.speed * dt
    elseif love.keyboard.isDown("left") then
        dx = -paddle.speed * dt
    end

    if ball.currentState == "onGoal" and love.keyboard.isDown(" ") then        
        ball:setCurrentState("playing")
        --ball.velocity.x, ball.velocity.y = 50, -267
        local dir = vector(0 + (math.random() *0.2), 1):normalized()
        ball.velocity = dir * ball.speed
    end

    paddle.l = paddle.l + dx
    world:move(paddle, paddle.l, paddle.t)
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

local function updatePlayer(self, dt)
  local dx = ball.velocity.x * dt
  local dy = ball.velocity.y * dt
  
  if dx ~= 0 or dy ~= 0 then
    local future_l, future_t = ball.l + dx, ball.t + dy
    local cols, len = world:check(ball, future_l, future_t)
    if len == 0 then
        ball:moveTo(future_l, future_t)
    else
      local col, tl, tt, bl, bt
      while len > 0 do
        col = cols[1]
        
        
        local hitPaddle = col.other == paddle
        
        tl,tt,_,_,bl,bt = col:getBounce()
        ball:moveTo(tl, tt)
        
        cols, len = world:check(ball, bl, bt)
        if len == 0 then
            ball:moveTo(bl, bt)
        end
        
        a = vector(tl, tt)
        b = vector(bl, bt)
        dir = b - a
        dir = dir:normalized()
        
        if hitPaddle then
            local playerCenterX = tl + (ball.w / 2)
            local paddleCenterX = paddle.l + (paddle.w / 2)            
            local collisionCenter = paddleCenterX - playerCenterX
            local offset = -(collisionCenter / (paddle.w/2))
            offset = math.clamp(-1, offset, 1)
            dir = vector(offset, -1.0):normalized()
        end
        
        ball.velocity = dir * ball.velocity:len()
       
        if col.other == goal then
            ball:setCurrentState("onGoal")
        end
        
        if col.other.tag ~= "side" then
            removeItemFrom(blocks, col.other)
            world:remove(col.other)
            self.blockCount = self.blockCount - 1
            self:hitTarget()
            if self.blockCount == 0 then
                self:gotoState("gameover")
            end
        end
      end
    end
  end
end

function ingame:hitTarget()
    self:setScore(self:getScore() + 1)
end

local function updatePlayerOnPaddle(self, dt)
    local pl, pt = paddle.l, paddle.t
    ball:moveTo(pl + (paddle.w / 2) - (ball.w / 2), pt - (ball.h + 1))
end

local function drawPlayer()
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
  love.graphics.print("score: "..self.score, 100, 10)
end

local function drawDebug()
  bump_debug.draw(world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580 )
end

local function newBall()
    local result = {
        l = 50, t = 50, w = 20, h = 20, 
        velocity = vector(50, 267), speed = 300, inplay = true, currentState = "onGoal",
        r = 255, g = 0, b = 0}

    function result:setCurrentState(state)
        self.currentState = state
        print("entered ball state: "..self.currentState)
    end
    
    function result:moveTo(l, t)
        self.l, self.t = l, t
        world:move(self, l, t)
    end

    return result
end

function ingame:buildTargets()
    math.randomseed(os.time())

    self.blockCount = 30

    local targetWidth = 50
    local targetHeight = 10
    local numRows = 10
    local numColumns = 12
    local count = 0
    
    local tl, tr
    for x = 0, numColumns - 1 do
        for y = 0, numRows - 1 do
            tl = 100 + (x * (targetWidth))
            tr = 100 + (y * (targetHeight))
            addBlock(tl,
                     tr,
                     targetWidth,
                     targetHeight)
            count = count + 1
        end
    end 

    self.blockCount = count
end

function ingame:enteredState()
    ball = newBall()

    world = bump.newWorld()
    world:add(ball, ball.l, ball.t, ball.w, ball.h)

    blocks = {}
    
    addBlock(0,       0, 800,       32, "side")
    addBlock(0,      32,  32, 600-32*2, "side")
    addBlock(800-32, 32,  32, 600-32*2, "side")

    paddle = addBlock(350, 600-32, 100, 16, "side")
    paddle.velocityX = 0;
    paddle.speed = 700;

    goal = addBlock(0, 600-16, 800, 16, "side")

    self:buildTargets()
    
    playerStates.playing = updatePlayer
    playerStates.onGoal = updatePlayerOnPaddle
    print("playerStates length just after adding methods: "..#playerStates)
    ball:setCurrentState("onGoal")

    
    self.timer = timer:new()
    
    ready = false
    self.timer:add(1, function() ready = true end)

    local target = {r = 0, g = 255}
    self.timer:tween(1, ball, target, "in-quint")
    print("Entered ingame state.")
end

function ingame:update(dt)
    self.timer:update(dt)
    updatePaddle(dt)
    print("playerStates length: "..#playerStates)
    print("currnetState: "..ball.currentState)    
    print("ball.currentState: "..ball.currentState)    
    playerStates[ball.currentState](self, dt)
end

function ingame:draw()
  drawBlocks()
  drawPlayer()
  if shouldDrawDebug then drawDebug() end
  self:drawMessage()
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame