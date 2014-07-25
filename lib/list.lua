local Class = require "lib.middleclass"

local List = Class("List")

function List:initialize(initialList)
    self.items = initialList or {}
end

function List:add(item)
    self.items[#self.items + 1] = item
end

function List:sort(comp)
    table.sort(self.items, comp)
end

function List:getIterator()
    local i = 0
    return 
        function() 
            i = i + 1
            return self.items[i] 
        end
end

function List:removeTail()
    table.remove(self.items)
end

return List
