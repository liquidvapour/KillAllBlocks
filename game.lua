local Class = require "lib.middleclass"
local Stateful = require "lib.stateful"

local Game = Class("Game"):include(Stateful)

function Game:initialise()
end

function Game:draw()
end

function Game:update(dt)
end

return Game