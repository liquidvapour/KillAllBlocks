local Class = require "lib.middleclass"

local ResourceManager = Class("ResourceManager")

function ResourceManager:initialize()
    self.resources = {
        NovaMono40 = love.graphics.newFont("resources/nova mono.ttf", 40),
        NovaMono20 = love.graphics.newFont("resources/nova mono.ttf", 20)
   }
end

function ResourceManager:getResource(name)
    return self.resources[name]
end

return ResourceManager