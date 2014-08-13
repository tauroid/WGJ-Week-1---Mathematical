Utils = {}

function Utils.isInIterable(value,iter)
    for k,v in pairs(iter) do
        if v == value then return true end
    end
    return false
end

function Utils.getTableLength(t)
    i = 0
    for k,v in pairs(t) do i = i+1 end
    return i
end

function Utils.tail(t)
    local tail = {}
    local n = table.getn(t)
    if n <= 1 then return tail end
    for i=2,table.getn(t) do
        table.insert(tail,t[i])
    end
    return tail
end