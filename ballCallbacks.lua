local Class = require "lib.middleclass"

local BallCallbacks = Class("BallCallbacks")

function BallCallbacks:initialize(ingame)
    self.ingame = ingame
end

function BallCallbacks:isReady()
    return self.ingame.ready
end

function BallCallbacks:getPaddle()
    return self.ingame.paddle
end

function BallCallbacks:getGoal()
    return self.ingame.goal
end

function BallCallbacks:registerAll(hitPaddle, hitSide, hitBlock, hitGoal)
    self.hitPaddleCallback = hitPaddle
    self.hitSideCallback = hitSide
    self.hitBlockCallback = hitBlock
    self.hitGoalCallback = hitGoal
end

function BallCallbacks:unregisterAll()
    self.hitPaddleCallback = nil
    self.hitSideCallback = nil
    self.hitBlockCallback = nil
    self.hitGoalCallback = nil
end

function BallCallbacks:hitPaddle(bl, bt, bounceAngleInRadians)
    print("ballCallbacks:hitPaddle called.")
    if self.hitPaddleCallback then
        self.hitPaddleCallback(bl, bt, bounceAngleInRadians)
    end
end

function BallCallbacks:hitSide()
    if self.hitSideCallback then
        self.hitSideCallback()
    end
end

function BallCallbacks:hitBlock(block)
    print("ballCallbacks:hitBlock called.")
    if self.hitBlockCallback then
        print("callback registered for hitBlock.")
        self.hitBlockCallback(block)
    end
end

function BallCallbacks:hitGoal()
    if self.hitGoalCallback then
        self.hitGoalCallback()
    end
end

return BallCallbacks
