local Class = require "lib.middleclass"
local Vector = require "hump.vector"

local Ball = Class("Ball")

function Ball:initialize(world, timer, context)
    self.world = world
    self.timer = timer
    self.context = context

    self.l = 50
    self.t = 50
    self.w = 32
    self.h = 32
    self.vector = Vector(50, 267):normalized()
    self.speed = 300
    self.inplay = true
    
    self.r = 0
    self.g = 0
    self.b = 0
    self.a = 0
    self.states = {updateInFlight = self.updateInFlight, updateOnPaddle = self.updateOnPaddle}
    self.world:add(self, self.l, self.t, self.w, self.h)
        
    self.image = love.graphics.newImage("resources/simpleGraphics_tiles32x32_0.png")
    self.image:setFilter("nearest", "nearest")
    self.quad = love.graphics.newQuad(64, 96, self.w, self.h, self.image:getWidth(), self.image:getHeight())

    
    self:reset()
end

function Ball:reset()
    self.r = 255
    self.g = 255
    self.b = 255
    self.a = 0
    local target = {r = 255, g = 255, b = 255, a = 255}
    self.timer:tween(1, self, target, "in-elastic")
    self:setCurrentState("updateOnPaddle")
end

function Ball:setCurrentState(state)
    self.currentState = self.states[state]
end

function Ball:moveTo(l, t)
    self.l, self.t = l, t
    self.world:move(self, l, t)
end

function Ball:update(dt)
    self:currentState(self.context, dt)
end

function Ball:draw()
    self:drawBox(self.r, self.g, self.b, self.a)
end

local function reflect(l, n)
    print("reflect l: "..l.x..", "..l.y)
    print("reflect n: "..n.x..", "..n.y)
    return 2 * (l * n) * n - l
end

local function degToRad(deg)
    return deg * (math.pi / 180)
end

local function rotate(x, y, r)
    -- 45 deg = pi / 4 [radians]
    -- rotate x, y by r
    -- x' = x cos f - y sin f
    -- y' = y cos f + x sin f
    print(("rotate %0.3f, %0.3f by %0.3f"):format(x, y, r))
    local c = math.cos(r)
    local s = math.sin(r)
    local newX = c * x - s * y
    local newY = s * x + c * y
    print(("result %0.3f, %0.3f"):format(newX, newY))
    return Vector(newX, newY)
end

function Ball:bounceOfPaddle(tl, tt, bl, bt, context)
    local colPos = Vector(tl, tt)
    print("colPos: "..colPos.x..", "..colPos.y)
    
    local ballCenterX = tl + (self.w / 2)
    local paddleCenterX = context:getPaddle().l + (context:getPaddle().w / 2)            
    local collisionCenter = paddleCenterX - ballCenterX
    local xdif = 45
    local offset = -((collisionCenter / (context:getPaddle().w / 2)) * xdif)
    offset = math.clamp(-xdif, offset, xdif)
    print(("offset: %0.3f"):format(offset))
    local bounceAngleInRadians = degToRad(offset)
    local r = rotate(0, -1, bounceAngleInRadians)
    
    local bouncePos = Vector(bl, bt)
    
    local bounceDist = colPos:dist(bouncePos)
    
    print("bounceDist: "..bounceDist)
    
    local start = Vector(self.l, self.t)
    print("start: "..start.x..", "..start.y)
    local newLocation = start + (r * bounceDist)

    print("newLocation: "..newLocation.x..", "..newLocation.y)
    bl, bt = newLocation:unpack()
    dir = r
    
    context:hitPaddle(bl, bt, bounceAngleInRadians)

    return dir, bl, bt
end

function Ball:standardBounce(tl, tt, bl, bt)
    local a = Vector(tl, tt)
    local b = Vector(bl, bt)
    local dirtmp = b - a
    return dirtmp:normalized()        
end

function Ball:moveBallTo(context, l, t, vector, d)
    local recursionDepth = d or 0
    local cols, len = self.world:check(self, l, t)
    local newVector = vector

    if recursionDepth > 0 then
        print("ball bounce recursionDepth: "..recursionDepth)
    end
    
    if recursionDepth > 3 then
        print("ball bounce fail! pretend we hit the goal because we got the "..recursionDepth.." collisions in one frame.")
        self:hitGoal()
        return newVector
    end
    
    if len == 0 then
        self:moveTo(l, t)        
    else
        local col = cols[1]
        if col.other == context:getGoal() then
            self:hitGoal()
        else
            local tl, tt, nx, ny, bl, bt = col:getBounce()

            local dir

            if col.other == context:getPaddle() and ny == -1 then
                dir, bl, bt = self:bounceOfPaddle(tl, tt, bl, bt, context)
            else
                dir = self:standardBounce(tl, tt, bl, bt)
                if col.other.tag == "side" then
                    context:hitSide()
                else
                    context:hitBlock(col.other)
                end
            end

            newVector = self:moveBallTo(context, bl, bt, dir, recursionDepth + 1)
        end
    end
    return newVector
end

function Ball:updateInFlight(context, dt)
    local distanceThisFrame = self.speed * dt
    local dx = self.vector.x * distanceThisFrame
    local dy = self.vector.y * distanceThisFrame

    if dx ~= 0 or dy ~= 0 then
        local future_l, future_t = self.l + dx, self.t + dy
        self.vector = self:moveBallTo(context, future_l, future_t, self.vector)
    end
end

function Ball:hitGoal()
    self.context:hitGoal()
    self:reset()
end

function Ball:updateOnPaddle(context, dt)
    local paddle = context:getPaddle()
    local pl, pt = paddle.l, paddle.t
    self:moveTo(pl + (paddle.w / 2) - (self.w / 2), pt - (self.h + 10))
    
    if context:isReady() and love.keyboard.isDown("up") then        
        self:setCurrentState("updateInFlight")
        self.vector = Vector(math.random() * 0.2, -1):normalized()
    end
end

function Ball:drawBox(r, g, b, a)
    love.graphics.setColor(r, g, b, a)
    love.graphics.draw(self.image, self.quad, self.l, self.t)
end

return Ball
