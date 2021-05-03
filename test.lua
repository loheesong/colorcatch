function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end
  

for i=1,10 do
    print(i)
    wait(0.5)
end
--[[
math.randomseed(os.time())

repeat
    x = math.random(-100,100)
    print(x)
-- until true 
until x < -30 or x > 30


local function func(a,b,c) return a,b,c end
local a = {myfunc = func}
print(a.myfunc(3,4,5)) -- prints 3,4,5

-- testing a.a notation
a = {
    a = function()
        print("A")
    end, 
}
a.a()

-- testing insert function (like append) and ipairs funcion
foo = {}
table.insert(foo, "bar")
table.insert(foo, "baz")
for key, value in ipairs(foo) do
    print(key, value)
end

print(foo[1])

math.randomseed(os.time())
local Strings = {"a","b"}

local st = Strings[math.random(1, #Strings)]
for i = 0, 10 do
    st = Strings[math.random(1, #Strings)]
    print(st)
end

]]
