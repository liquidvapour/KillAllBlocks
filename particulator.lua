local Class = require "lib.middleclass"
local GraphicsUtils = require "lib.utils"

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

    return particleSystem
end

local function getTargetParticleSystem()
    local image = GraphicsUtils.getDrawableFromTileMap("resources/simpleGraphics_tiles32x32_0.png", 64, 128, 32, 32)
    local particleSystem = love.graphics.newParticleSystem(image, 1000)
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

    return particleSystem
end

function Particulator:initialize()
    self.paddleParticles = getPaddleParticleSystem()
    self.targetParticles = getTargetParticleSystem()
end

function Particulator:hitBlock(block)
    self.targetParticles:setPosition((block.w/2) + block.l, (block.h/2) + block.t)
    self.targetParticles:emit(4)
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
end

function Particulator:draw()
    love.graphics.draw(self.paddleParticles, 0, 0)
    love.graphics.draw(self.targetParticles, 0, 0)
end

return Particulator
