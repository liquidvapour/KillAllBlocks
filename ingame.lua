local Game = require "game"
local Ball = require "ball"
local Paddle = require "paddle"
local Side = require "side"
local Target = require "target"

local bump = require "bump"
local bump_debug = require "bump_debug"
local vector = require "hump.vector"
local timer = require "hump.timer"
local scorer = require "scorer"

local NumberBox = require "ui.numberbox"
local utils = require "utils"
local GraphicsUtils = require "lib.utils"
local Tween = require "lib.tween"

local Particulator = require "particulator"
local BallCallbacks = require "ballCallbacks"
local ingame = Game:addState("ingame")

local instructions = [[
  pong simple game

    arrows: move
    space: release ball
    tab: toggle debug info
    delete: run garbage collector
]]

local blockBurnTime = 0.25

local playerStates = {}

local function removeItemFrom(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then
            table.remove(tbl, key)
        end 
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function ingame:gotoGameOver()
    self.soundbox:gameover()
    self:gotoState("gameover", self.myScorer:getScore())
end

function ingame:hitBlock(block)
    self.world:remove(block)
    self.blockCount = self.blockCount - 1
    self:hitTarget()
  
    self.particulator:hitBlock(block)
    self.timer:add(blockBurnTime, function() removeItemFrom(self.blocks, block) end)
    
    block:hit()
    
    if self.blockCount == 0 then
        self:startGameOverBanner()
        self.timer:add(1, function() self:gotoGameOver() end)
    end
end

function ingame:startGameOverBanner()
    self.gameOverBanner = self:createItem("resources/gameOver.png", 400)
end

function ingame:createItem(resource, x, onSelected, r, g, b)
    local image = love.graphics.newImage(resource)
    local menuItem = {
        image = image, 
        x = -256, w = 512, h = 256, 
        onSelected = onSelected,
        r = r or 255, g = g or 255, b = b or 255, a = 0}
    
    menuItem.tween = Tween.new(0.5, menuItem, {x = x}, "linear") 
    return menuItem
end


function ingame:hitPaddle(x, y, bounceAngleInRadians)
    print(("hitPaddle (%0.3f, %0.3f)."):format(x, y))
    self.myScorer:hitPaddle()
    self:updateUiScores()
    self.soundbox:hitPaddle()
    
    self.particulator:hitPaddle(self.paddle, x, bounceAngleInRadians)
end

function ingame:hitGoal()
    print("hitGoal")
    self.myScorer:hitGoal()
    self:updateUiScores()
    self.soundbox:hitGoal()
end

function ingame:hitTarget()
    print("hitTarget")
    self.myScorer:hitTarget()
    self:updateUiScores()
    self.soundbox:hitTarget()
end

function ingame:hitSide()
    print("hitSide")
    self.myScorer:hitSide()
    self:updateUiScores()
    self.soundbox:hitSide()
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

function ingame:updateUiScores()
    self.scoreBox:setValue(self.myScorer:getScore())
    self.comboBox:setValue(self.myScorer:getCombo())
end

function ingame:addToBlockList(block)
  self.blocks[#self.blocks+1] = block
end

function ingame:drawBlocks()
    for _,block in ipairs(self.blocks) do
        block:draw(255,0,0)
    end
end

-- Message/debug functions
function ingame:drawMessage()
  love.graphics.setColor(0, 0, 0, 170)
  love.graphics.rectangle("fill", 95, 0, 310, 32)
  love.graphics.setColor(255, 255, 255)
  --local msg = instructions:format(tostring(shouldDrawDebug))
  -- RP 2014-12-31: this is s..l..o..w! so I commented it out.
  --love.graphics.print(msg, 550, 10)
  
  love.graphics.print(("draw time: %.3fms"):format(self.drawTime * 1000), 630, 540)
  love.graphics.print(("update time: %.3fms"):format(self.updateTime * 1000), 630, 510)
end

function ingame:drawDebug()
  bump_debug.draw(self.world)

  local statistics = ("fps: %d, mem: %dKB"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(statistics, 630, 580)
end

function ingame:setupTargets()

    local targetWidth = 128
    local targetHeight = 32
    local numRows = 6
    local numColumns = 4
    local count = 0
    
    local totalWidth = numColumns * targetWidth
    local screenWidth = 800--love.window.getWidth()
    
    local xOffset = (screenWidth - totalWidth) / 2
    
    local tl, tt
    
    Target.drawCanvas()
    
    for x = 0, numColumns - 1 do
        for y = 0, numRows - 1 do
            tl = xOffset + (x * (targetWidth))
            tt = 100 + (y * (targetHeight))
            self:addToBlockList(Target:new(self.world, tl, tt, targetWidth, targetHeight, nil, self.timer))
            count = count + 1
        end
    end 

    self.blockCount = count
end

function ingame:setupSides()
    Side.drawCanvas()
    self:addToBlockList(Side:new(self.world, 0,       0, 800,       32))
    self:addToBlockList(Side:new(self.world, 0,      32,  32, 600-((32*2)+8)))
    self:addToBlockList(Side:new(self.world, 800-32, 32,  32, 600-((32*2)+8)))
end

function ingame:enteredState()
    math.randomseed(love.timer.getTime())
    
    self.world = bump.newWorld()
    
    self.blocks = {}
    self:setupSides()
    
    self.paddle = Paddle:new(self)

    self.goal = Side:new(self.world, 0, 600-24, 800, 24)
    self:addToBlockList(self.goal)

    self.timer = timer:new()

    self:setupTargets()

    self.soundbox:startBackingTrack()
    
    self.ready = false
    self.timer:add(1, function() self.ready = true end)

    self.ballCallbacks = BallCallbacks:new(self)
    
    self.ballCallbacks:registerAll(
        function(bl, bt, bounceAngleInRadians) self:hitPaddle(bl, bt, bounceAngleInRadians) end,
        function() self:hitSide() end, 
        function(block) self:hitBlock(block) end,
        function() self:hitGoal() end)
        
    self.ball = Ball:new(self.world, self.timer, self.ballCallbacks)
    
    self.myScorer = scorer:new(self)
    
    love.graphics.setBackgroundColor(36, 36, 39)
    
    self.scoreFont = love.graphics.newImageFont("resources/shwingItalic.png", "0123456789")
    
    self.scoreBox = NumberBox(100, 0, 150, self.scoreFont)
    self.comboBox = NumberBox(250, 0, 150, self.scoreFont)
    
    self.drawTime = 0
    self.updateTime = 0
    
    self.particulator = Particulator:new(self.timer, blockBurnTime)
    
    self.thingsToUpdate = utils.newList()
    self.thingsToUpdate:add(self.timer)
    self.thingsToUpdate:add(self.paddle)
    self.thingsToUpdate:add(self.ball)
    self.thingsToUpdate:add(self.scoreBox)
    self.thingsToUpdate:add(self.comboBox)
    self.thingsToUpdate:add(self.particulator)
    
    --self:startGameOverBanner()

end

function ingame:exitedState(oldState)
    self.soundbox:stopBackingTrack()
    self.ballCallbacks:unregisterAll()
    self.ballCallbacks = nil
    self.paddleParticleSystem = nil
    self.targetParticleSystem = nil
    self.gameOverBanner = nil
end


function ingame:updateAllTheThings(dt)
    for t in self.thingsToUpdate:iterate() do
        t:update(dt)
    end
end

function ingame:update(dt)
    local startTime = love.timer.getTime()
        
    self:updateAllTheThings(dt)
    
    local endTime = love.timer.getTime()
    self.updateTime = endTime - startTime    
    if self.gameOverBanner and self.gameOverBanner.tween then
        self.gameOverBanner.tween:update(dt)
    end
end

function ingame:draw()
    local startTime = love.timer.getTime()
    self.ball:draw()
    self.paddle:draw()
    self:drawBlocks()
    
    self.particulator:draw()
    
    if shouldDrawDebug then self:drawDebug() end
    self:drawMessage()
    local endTime = love.timer.getTime()
    self.drawTime = endTime - startTime
    
    self.scoreBox:draw()
    self.comboBox:draw()
    
    if self.gameOverBanner then
        love.graphics.draw(self.gameOverBanner.image, self.gameOverBanner.x - (self.gameOverBanner.w/2), (600/2)-128)
    end
end

function ingame:escPressed()
    self:gotoState("menu")
end

return ingame