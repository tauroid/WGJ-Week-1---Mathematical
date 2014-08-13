QueueBoxBundle = {}
QueueBoxBundle.__index = QueueBoxBundle

function QueueBoxBundle.create()

end

QueueBox = {}
QueueBox.__index = QueueBox

function QueueBox.create()
    local qb = {}
    setmetatable(qb,QueueBox)
    qb.punchqueue = {}
    qb.block = nil
    return qb
end

QueueBoxDecorator = {}
QueueBoxDecorator.__index = QueueBoxDecorator

function QueueBoxDecorator.create(qb)
    local qbd = {}
    setmetatable(qbm,QueueBoxDecorator)
    qbd.qb = qb
    return qbd
end

QueueBoxView = {}
QueueBoxView.__index = QueueBoxView

function QueueBoxView.create(qbd)
    local qbv = {}
    setmetatable(qbv,QueueBoxView)
    qbv.qbd = qbd
    return qbv
end

function QueueBoxView:render()
    
end