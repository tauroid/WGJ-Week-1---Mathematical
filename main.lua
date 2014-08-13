require 'equation'
require 'queuebox'

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    fp = Equation.generateFactorPairs(54)
    Equation.cleanFactorPairs(fp)
    for k,v in pairs(fp) do
        print(k.." "..v)
    end
    print(Utils.getTableLength(fp))
    for i=1,20 do
        eq = Equation.generate(50,2,20)
        if eq ~= false then eq:print()
        else print("Equation failed to generate") end
    end
end

function love.update()
    
end

function love.draw()

end