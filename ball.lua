local Class = require "lib.middleclass"
local vector = require "hump.vector"

local Ball = Class("Ball")

function Ball:initialize(world, timer)
    self.l = 50
    self.t = 50
    self.w = 32
    self.h = 32
    self.velocity = vector(50, 267)
    self.speed = 300
    self.inplay = true
    
    self.r = 255
    self.g = 0
    self.b = 0
    self.states = {updateInFlight = self.updateInFlight, updateOnPaddle = self.updateOnPaddle}
    self.world = world
    self.world:add(self, self.l, self.t, self.w, self.h)
    
    self.image = love.graphics.newImage("resources/simpleGraphics_tiles32x32_0.png")
    self.image:setFilter("nearest", "nearest")
    self.quad = love.graphics.newQuad(64, 96, self.w, self.h, self.image:getWidth(), self.image:getHeight())

    local target = {r = 0, g = 255}
    timer:tween(1, self, target, "in-quint")
    self:setCurrentState("updateOnPaddle")
end

function Ball:setCurrentState(state)
    self.currentState = self.states[state]
end

function Ball:moveTo(l, t)
    self.l, self.t = l, t
    self.world:move(self, l, t)
end

function Ball:update(dt, context)
    self:currentState(context, dt)
end

function Ball:draw()
    self:drawBox(self.r, self.g, self.b)
end

function Ball:updateInFlight(context, dt)
  local dx = self.velocity.x * dt
  local dy = self.velocity.y * dt
  
  if dx ~= 0 or dy ~= 0 then
    local future_l, future_t = self.l + dx, self.t + dy
    local cols, len = self.world:check(self, future_l, future_t)
    if len == 0 then
        self:moveTo(future_l, future_t)
    else
      local col, tl, tt, bl, bt
      while len > 0 do
        col = cols[1]
        
        local hitPaddle = col.other == context.paddle
        
        tl,tt,_,_,bl,bt = col:getBounce()
        self:moveTo(tl, tt)
        
        cols, len = self.world:check(self, bl, bt)
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
       
        if col.other == context.goal then
            self:setCurrentState("updateOnPaddle")
        end
        
        if col.other.tag == "side" then
            context:hitSide()
        else
            context:hitBlock(col.other)
        end
      end
    end
  end
end

function Ball:updateOnPaddle(context, dt)
    local pl, pt = context.paddle.l, context.paddle.t
    self:moveTo(pl + (context.paddle.w / 2) - (self.w / 2), pt - (self.h + 1))
    
    if context.ready and love.keyboard.isDown(" ") then        
        self:setCurrentState("updateInFlight")
        local dir = vector(0 + (math.random() *0.2), 1):normalized()
        self.velocity = dir * self.speed
    end
end

function Ball:drawBox(r,g,b)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.quad, self.l, self.t)
end

return Ball
