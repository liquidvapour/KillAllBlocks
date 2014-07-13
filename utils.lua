local Utils = {}
function Utils.printCenter(message, cx, cy, width, height)
    
    height = height or 0
    
    local windowCenter = width / 2
    
    local textl = cx - (width / 2)
    local textt = cy - (height / 2)
    
    love.graphics.printf(message, textl, textt, width, "center")
    
end    

function Utils.newList()
    local result = {}
    function result:add(item)
        table.insert(self, item)
    end
    
    function result:iterate()
        local i = 0
        local n = table.getn(self)
        return function()
                    i = i + 1
                    if i <= n then return self[i] end
               end
    end
    return result
end

return Utils