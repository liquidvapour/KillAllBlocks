local Utils = {}

function Utils.getDrawableFromTileMap(resourceName, tl, tt, tw, th)
    local image = love.graphics.newImage(resourceName)
    local quad = love.graphics.newQuad(tl, tt, tw, th, image:getWidth(), image:getHeight())
    local canvas = love.graphics.newCanvas(tw, th)
    canvas:setWrap("repeat", "repeat")
    love.graphics.setCanvas(canvas)
    canvas:clear()
    love.graphics.push()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(image, quad, 0, 0)
    love.graphics.setCanvas()
    love.graphics.pop()
    return canvas
end



return Utils