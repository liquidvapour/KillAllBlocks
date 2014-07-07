local Game = require "game"

local bump = require 'bump'
local bump_debug = require 'bump_debug'
local vector = require 'hump.vector'

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
local world = bump.newWorld()


-- ball functions
local ball = { l=50,t=50,w=20,h=20, velocity = vector(50, 267), speed = 300, inplay = true, currentState = "onGoal" }

function ball:moveTo(l, t)
    self.l, self.t = l, t
    world:move(self, l, t)
end

local blocks = {}
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



local function updatePaddle(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown('right') then
        dx = paddle.speed * dt
    elseif love.keyboard.isDown('left') then
        dx = -paddle.speed * dt
    end

    if ball.currentState == "onGoal" and love.keyboard.isDown(' ') then        
        ball.currentState = "playing"
        --ball.velocity.x, ball.velocity.y = 50, -267
        local dir = vector(0 + (math.random() *0.2), 1):normalized()
        ball.velocity = dir * ball.speed
    end

    
    paddle.l = paddle.l + dx
    world:move(paddle, paddle.l, paddle.t)
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

local function updatePlayer(dt)
  
  --ball.velocity = ball.velocity * ball.acceleration * dt
     
  local dx = ball.velocity.x * dt
  local dy = ball.velocity.y * dt
  
  if dx ~= 0 or dy ~= 0 then
    local future_l, future_t = ball.l + dx, ball.t + dy
    local cols, len = world:check(ball, future_l, future_t)
    if len == 0 then
      ball.l, ball.t = future_l, future_t
      world:move(ball, future_l, future_t)
    else
      local col, tl, tt, bl, bt
      while len > 0 do
        col = cols[1]
        
        
        local hitPaddle = col.other == paddle
        
        tl,tt,_,_,bl,bt = col:getBounce()
        ball:moveTo(tl, tt)
        
        cols, len = world:check(ball, bl, bt)
        if len == 0 then
          ball.l, ball.t = bl, bt
          world:move(ball, bl, bt)
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
            ball.currentState = "onGoal"
        end
        
        if col.other.tag ~= "side" then
            removeItemFrom(blocks, col.other)
            world:remove(col.other)
        end
      end
    end
  end
end

local function updatePlayerOnPaddle(dt)
    local pl, pt = paddle.l, paddle.t
    ball:moveTo(pl + (paddle.w / 2) - (ball.w / 2), pt - (ball.h + 1))
end


local function drawPlayer()
    drawBox(ball, 0, 255, 0)
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
local function drawMessage()
  local msg = instructions:format(tostring(shouldDrawDebug))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(msg, 550, 10)
end

local function drawDebug()
  bump_debug.draw(world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580 )
end


function ingame:enteredState()
  world:add(ball, ball.l, ball.t, ball.w, ball.h)

  addBlock(0,       0,     800, 32, "side")
  addBlock(0,      32,      32, 600-32*2, "side")
  addBlock(800-32, 32,      32, 600-32*2, "side")
  
  paddle = addBlock(350,      600-32, 100, 16, "side")
  paddle.velocityX = 0;
  paddle.speed = 700;
  
  goal = addBlock(0, 600-16, 800, 16, "side")

  math.randomseed(os.time())
  
  for i=1,30 do
    addBlock( math.random(100, 600),
              math.random(100, 400),
              math.random(10, 100),
              math.random(10, 100)
    )
  end
  
  playerStates.playing = updatePlayer
  playerStates.onGoal = updatePlayerOnPaddle
  
  ball.currentState = "onGoal"
  
  print("entered ingame state: "..ball.currentState)
end

function ingame:update(dt)
    updatePaddle(dt)
    print("currnetState: "..ball.currentState)
    playerStates[ball.currentState](dt)
end

function ingame:draw()
  drawBlocks()
  drawPlayer()
  if shouldDrawDebug then drawDebug() end
  drawMessage()
end

-- Non-player keypresses
function love.keypressed(k)
  if k=="escape" then love.event.quit() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
  if k=="delete" then collectgarbage("collect") end
end


return ingame