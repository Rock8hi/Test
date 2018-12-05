print("VER=", _VERSION)
--[[
local tab = {}
for k, v in pairs(string) do
    table.insert(tab, k)
end
table.sort(tab)
print(table.concat(tab, ", "))]]

local tab = {}
for k, v in pairs(table) do
    table.insert(tab, k)
end
print(table.concat(tab, ", "))

print(table.concat({76,a=12,1,3,4,5,6,9,[112]=90}, ', '))

local s = {1,2,3,4}
print("xxx",table.remove(s))
table.remove(s)
print(table.concat(s, ", "))

print(table.pack(1,23,45,6,6))
print(table.unpack({1,23,43,4,5,89}))

local ss = "629800"
local a,b,c = string.match(ss, "^(%d*)(%d)(%d)%d$")
print("a=",a)
print("b=",b)
print("c=",c)
print(string.match("00", "^([1-9]*)0*$"))





--[[
function sortScore(score, is_adjust)
    if score < 10 then
        return "0"
    end
    score = math.floor(score / 10) / 100
    local ret = string.format("%.02f", score)
    print(">>>A",ret)
    local x, c = string.gsub(ret, "^[%d]*.(00)$", "%1")
    if x == "00" and c == 1 then
        print(">>>B",ret, score, string.format("%d", score))
        return string.format("%d", score)
    end
    print(">>>C",ret)
    return ret
end

print(sortScore(123456))
print(sortScore(123000))
print(sortScore(123999))
print(sortScore(123099))
print(sortScore(123990))
print(sortScore(123900))
print(sortScore(900))
print(sortScore(900000))]]

for s in string.gmatch(
"强中自有强中手！玩家#1shou_mucang#2在水果机#3普通#4场赢得#59999#6金币，真棒！",
"#%d") do
    print(s)
end


local function hello(a)
    return math.floor((a % 10000) / 1000), 10000 + a % 1000
end

print(hello(13500))

print(string.gsub("你是啥东西，在大话西游中赢了345344000金币，太厉害了", 
"(.-)，在大话西游中赢了(.-)金币，太厉害了", "%1 = %2"))




local sb = {"hello","ABc","你好","!Air"}
table.sort(sb)
print(table.concat(sb, ","))





