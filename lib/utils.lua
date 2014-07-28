local Utils = {}

function Utils.getDrawableFromTileMap(resourceName, l, t, w, h)
    local image = love.graphics.newImage(resourceName)
    local quad = love.graphics.newQuad(l, t, w, h, image:getWidth(), image:getHeight())
    local canvas = love.graphics.newCanvas(w, h)
    canvas:setWrap("repeat", "repeat")
    love.graphics.setCanvas(canvas)
    canvas:clear()
    love.graphics.setBlendMode('alpha')    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(image, quad, 0, 0)
    love.graphics.setCanvas()
    return canvas
end

return Utils