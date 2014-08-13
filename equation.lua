require 'utils'

Equation = {}
Equation.__index = Equation
Equation.primes = {2,3,5,7,11,13,17,19,23}
Equation.opsymbols = {"+","-","*","/"}

function Equation.add(l,r) return l+r end
function Equation.subtract(l,r) return l-r end
function Equation.multiply(l,r) return l*r end
function Equation.divide(l,r) return l/r end

Equation.operators = {}
Equation.operators["+"] = Equation.add
Equation.operators["-"] = Equation.subtract
Equation.operators["*"] = Equation.multiply
Equation.operators["/"] = Equation.divide
Equation.precedence = {"*","/"}

function Equation.generate(upperbound,maxops,uppercomponentbound)
    local equation = {}
    setmetatable(equation,Equation)
    equation.result = math.random(upperbound)
    equation.ops = {}
    equation.values = {}
    
    local nops = math.random(maxops)
    local maxtries = 8
    local tries = 0
    
    local remaining = equation.result
    local lr = {}
    while table.getn(equation.ops) < nops and tries < maxtries do
        local op = Equation.getRandomOperator(false)
        lr = Equation.split(remaining,op,uppercomponentbound)
        if not lr == false then
            table.insert(equation.values,lr[2])
            table.insert(equation.ops,op)
            remaining = lr[1]
            tries = 0
        else
            tries = tries+1
        end
    end
    if tries < maxtries then
        table.insert(equation.values,lr[1])
        return equation
    else
        return false
    end
end

function Equation.create(ops,values)
    local equation = {}
    setmetatable(equation,Equation)
    equation.result = Equation.evaluate(ops,values)
    equation.ops = ops
    equation.values = values
    return equation
end

function Equation.getRandomOperator(isincreasingonly)
    local symboltable
    if isincreasingonly then symboltable = Equation.opincr
    else symboltable = Equation.opsymbols end
    local n = math.random(table.getn(Equation.opsymbols))
    return Equation.opsymbols[n]
end

function Equation.split(value,op,limit)
    local r,l,rlset=false
    if op == "+" then
        if value/2 > limit then return false end
        l = math.random(value-limit,limit)
        r = value-l
        rlset=true
    elseif op == "-" then
        if value+1 > limit then return false end
        l = math.random(value+1,limit)
        r = l-value
        rlset=true
    end
    if rlset then return {l,r} end
    
    local fp = Equation.generateFactorPairs(value)
    Equation.cleanFactorPairs(fp)
    
    if op == "*" then
        fp = Equation.getPairsWithLimit(fp,limit)
        local fpl = Utils.getTableLength(fp)
        if fpl == 0 then return false end
        local i = 1
        local n = math.random(fpl)
        for k,v in pairs(fp) do
            if i == n then
                l = k
                r = v
                rlset=true
                break
            end
            i = i+1
        end
    elseif op == "/" then
        local ml = Equation.getMultiplesUnderLimit(fp,limit)
        local len = table.getn(ml)
        if len == 0 then return false end
        local n = math.random(len)
        l = ml[n]
        r = l/value
        rlset=true
    end
    if rlset then return {l,r} end
    
    return false
end

function Equation.generateFactorPairs(number)
    local fp = {}
    
    -- print("Starting on "..number)
    for i=1,table.getn(Equation.primes) do
        -- print("On "..number..":")
        -- print(Equation.primes[i])
        if Equation.primes[i] > number then break end
        local div = number/Equation.primes[i]
        if div-math.floor(div) == 0 and div ~= 1 then
            -- print("Found new pair "..div.." "..Equation.primes[i])
            fp[div] = Equation.primes[i]
            fpd = Equation.generateFactorPairs(div)
            for k,v in pairs(fpd) do
                fp[k] = v*Equation.primes[i]
            end
        end
    end
    return fp
end

function Equation.cleanFactorPairs(fp)
    for k1,v1 in pairs(fp) do
        for k2,v2 in pairs(fp) do
            if v1 == k2 then
                fp[k2] = nil
            end
        end
    end
end

function Equation.getPairsWithLimit(fp,limit)
    local fpl = {}
    for k,v in pairs(fp) do
        if k <= limit and v <= limit then fpl[k] = v end
    end
    return fpl
end

function Equation.getMultiplesUnderLimit(fp,limit)
    local ml = {}
    local res = 0
    for k,v in pairs(fp) do
        if res == 0 then res = k*v end
        local rk = res*k
        local rv = res*v
        if rk <= limit then table.insert(ml,rk) end
        if rv <= limit then table.insert(ml,rv) end
    end
    return ml
end

function Equation.evaluate(ops,values)
    local nops = table.getn(ops)
    local nvalues = table.getn(values)
    if nvalues ~= nops+1 then return 0 end
    if nvalues == 1 then return values[1] end
    return Equation.operators[ops[1]](Equation.evaluate(Utils.tail(ops),Utils.tail(values)),values[1])
end

function Equation:print()
    print(Equation.recurseRep(self,false).."="..self.result)
end

function Equation.recurseRep(eq,precedenceahead)
    local st = ""
    local nops = table.getn(eq.ops)
    if table.getn(eq.values) == 0 then return st end
    if nops == 0 then return tostring(eq.values[1]) end
    local s_val1,s_val2
    if eq.values[1] < 0 then s_val1 = "("..tostring(eq.values[1])..")" else s_val1 = tostring(eq.values[1]) end
    if eq.values[2] < 0 then s_val2 = "("..tostring(eq.values[2])..")" else s_val2 = tostring(eq.values[2]) end
    local s_op = tostring(eq.ops[1])
    local noprecedence = not Utils.isInIterable(eq.ops[1],Equation.precedence)
    --if noprecedence then print("No precedence with "..s_op) end
    --if precedenceahead then print("Precedence ahead with "..s_op) end
    
    st = Equation.recurseRep(Equation.create(Utils.tail(eq.ops),Utils.tail(eq.values)),not noprecedence)
    if noprecedence and precedenceahead then
        return "("..st..s_op..s_val1..")"
    else
        return st..s_op..s_val1
    end
end
