local Utils = {}
function Utils.printCenter(message, cx, cy, width, height)
    
    height = height or 0
    
    local windowCenter = width / 2
    
    local textl = cx - (width / 2)
    local textt = cy - (height / 2)
    
    love.graphics.printf(message, textl, textt, width, "center")
    
end    

return Utils