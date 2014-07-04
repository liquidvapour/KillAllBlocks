local bump       = require 'bump'
local bump_debug = require 'bump_debug'
local vector     = require 'hump.vector'

local instructions = [[
  bump.lua simple demo

    arrows: move
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


-- Player functions
local player = { l=50,t=50,w=20,h=20, velocity = vector(260, 70), acceleration = 80 }
local blocks = {}

local function updatePlayer(dt)
  
  --player.velocity = player.velocity * player.acceleration * dt
  
  
  local dx = player.velocity.x * dt
  local dy = player.velocity.y * dt
  
  if dx ~= 0 or dy ~= 0 then
    local future_l, future_t = player.l + dx, player.t + dy
    local cols, len = world:check(player, future_l, future_t)
    if len == 0 then
      player.l, player.t = future_l, future_t
      world:move(player, future_l, future_t)
    else
      local col, tl, tt, bl, bt
      while len > 0 do
        col = cols[1]
        tl,tt,_,_,bl,bt = col:getBounce()
        player.l, player.t = tl, tt
        world:move(player, tl, tt)
        cols, len = world:check(player, bl, bt)
        if len == 0 then
          player.l, player.t = bl, bt
          world:move(player, bl, bt)
        end
        
        a = vector(tl, tt)
        b = vector(bl, bt)
        dir = b - a
        player.velocity = dir:normalized() * player.velocity:len()
        
        if col.other and col.other.tag ~= "side" then
            for key, value in pairs(blocks) do
                if value == col.other then
                    table.remove(blocks, key)
                end 
            end
            
            world:remove(col.other)
            
        end
      end
    end
  end
end

local function drawPlayer()
  drawBox(player, 0, 255, 0)
end

-- Block functions


local function addBlock(l,t,w,h, tag)
  local block = {l=l,t=t,w=w,h=h,tag=tag}
  blocks[#blocks+1] = block
  world:add(block, l,t,w,h)
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


function love.load()
  world:add(player, player.l, player.t, player.w, player.h)

  addBlock(0,       0,     800, 32, "side")
  addBlock(0,      32,      32, 600-32*2, "side")
  addBlock(800-32, 32,      32, 600-32*2, "side")
  addBlock(0,      600-32, 800, 32, "side")

  for i=1,30 do
    addBlock( math.random(100, 600),
              math.random(100, 400),
              math.random(10, 100),
              math.random(10, 100)
    )
  end
end

function love.update(dt)
  updatePlayer(dt)
end

function love.draw()
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
