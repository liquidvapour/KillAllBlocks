local Class = require "lib.middleclass"
local GraphicsUtils = require "lib.utils"
local timer = require "hump.timer"

local Particulator = Class("Particulator")

local function getPaddleParticleSystem()
    local image = GraphicsUtils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 32, 96, 32, 32)
    local particleSystem = love.graphics.newParticleSystem(image, 100)
    particleSystem:setEmissionRate(30)
    particleSystem:setEmitterLifetime(0.15)
    particleSystem:setParticleLifetime(2, 2)
    particleSystem:setSizes(1)
    particleSystem:setDirection(1.25 * (math.pi))
    particleSystem:setLinearAcceleration(0, 800, 0, 800)
    particleSystem:setColors(255, 255, 255, 255, 255, 255, 255, 255)
    particleSystem:setSpeed(200, 300)
    local twoPi = 2 * math.pi
    particleSystem:setRotation(0, twoPi)
    particleSystem:setSpin(-twoPi, 0)
    particleSystem:stop()

    return particleSystem
end

local function getTargetParticleSystem()
    local image = GraphicsUtils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 128, 32, 32)
    local particleSystem = love.graphics.newParticleSystem(image, 20)
    particleSystem:setEmissionRate(0)
    particleSystem:setEmitterLifetime(-1)
    particleSystem:setParticleLifetime(2, 2)
    particleSystem:setSizes(1, 1.2)
    particleSystem:setDirection(1.5 * (math.pi))
    particleSystem:setLinearAcceleration(0, 800, 0, 800)
    particleSystem:setColors(255, 255, 255, 255, 255, 255, 255, 255)
    particleSystem:setSpeed(0, 100)
    particleSystem:setAreaSpread("uniform", 58, 0)
    local twoPi = 2 * math.pi
    particleSystem:setRotation(0, twoPi)
    particleSystem:setSpin(twoPi, 0)
    particleSystem:stop()

    return particleSystem
end

local function getGlowParticleSystem(blockBurnTime)
    local image = love.graphics.newImage("resources/particle.png")
    local particleSystem = love.graphics.newParticleSystem(image, 10000)
    particleSystem:setEmissionRate(350)
    particleSystem:setEmitterLifetime(blockBurnTime + 0.1)
    particleSystem:setParticleLifetime(0.25, 0.25)
    particleSystem:setSizes(0.2, 1)
    particleSystem:setDirection(1.5 * math.pi)
    particleSystem:setLinearAcceleration(0, 0, 0, -10)
    particleSystem:setColors(246, 232, 8, 255, 246, 97, 8, 0)
    particleSystem:setSpeed(0, 100)
    particleSystem:setAreaSpread("uniform", 64, 16)
    particleSystem:stop()

    return particleSystem
end

function Particulator:initialize(timer, blockBurnTime)
    self.paddleParticles = getPaddleParticleSystem()
    self.targetParticles = getTargetParticleSystem()
    self.glowParticles = getGlowParticleSystem(blockBurnTime)
    self.timer = timer
    self.blockBurnTime = blockBurnTime
end


function Particulator:hitBlock(block)
    self.timer:add(
        self.blockBurnTime, 
        function() 
            self.targetParticles:setPosition((block.w/2) + block.l, (block.h/2) + block.t) 
            self.targetParticles:emit(4)
        end)
    self.glowParticles:setPosition((block.w/2) + block.l, (block.h/2) + block.t)
    self.glowParticles:start()
end

local particleSystemDirectionOffset = 1.5 * (math.pi)

function Particulator:hitPaddle(paddle, x, bounceAngleInRadians)
    self.paddleParticles:setDirection(bounceAngleInRadians + particleSystemDirectionOffset)
    self.paddleParticles:setPosition(x + 16, paddle.t - 16)
    self.paddleParticles:start()
end

function Particulator:update(dt)
    self.paddleParticles:update(dt)
    self.targetParticles:update(dt)
    self.glowParticles:update(dt)    
end

function Particulator:draw()
    love.graphics.draw(self.paddleParticles, 0, 0)
    love.graphics.draw(self.targetParticles, 0, 0)
    love.graphics.draw(self.glowParticles, 0, 0)
end

return Particulator
