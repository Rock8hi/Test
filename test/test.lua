
local paixing = {}
local table_remove = table.remove
local constZiPai = {0x31, 0x32, 0x33, 0x34, 0x41, 0x42, 0x43}
-- 十三不靠，最牛逼的烂牌
paixing.checkMostCluttered = function (self, cards)
    local function isSameColorGroup(colors, values)
        for i, color in ipairs(colors) do
            local bingo, card = true, 0
            for _, value in ipairs(values) do
                card = color * 16 + value
                if cards.matrix[card] ~= 1 and cards.lz_matrix[card] ~= 1 then
                    bingo = false
                    break
                end
            end
            if bingo then
                table_remove(colors, i)
                return color, colors
            end
        end
    end
	
	local function print_array(tab)
		print("colors = {" .. table.concat(tab, ",") .. "}")
	end

    local color, colors = nil, {0,1,2}
	print_array(colors)
	
    color, colors = isSameColorGroup(colors, {1,4,7})
    if not color then
        return false
    end
	print_array(colors)
	
    color, colors = isSameColorGroup(colors, {2,5,8})
    if not color then
        return false
    end
	print_array(colors)
	
    color, colors = isSameColorGroup(colors, {3,6,9})
    if not color then
        return false
    end
	print_array(colors)
	
    local count = 0
    for i, v in ipairs(constZiPai) do
        if cards.matrix[v] > 1 or cards.lz_matrix[v] > 1 then
            return false
        elseif cards.matrix[v] == 1 or cards.lz_matrix[v] == 1 then
            count = count + 1
        end
    end
    if count ~= 5 then -- 5张不同的风牌
        return false
    end

    return true
end

paixing.checkQiDui = function (self, cards, blaizi)
 

    if not blaizi then
        for _,v in pairs(cards.matrix) do
            if v ~= nil and (v > 4 or v % 2 ~= 0) then
                return false
            end
        end
    else
        local need_laizi_count = 0
        local laizi_count = 0
        for k,v in pairs(cards.matrix) do
            if v ~= nil and v <= 4 then
                if cards.lz_matrix[k] ~= 0 then
                    laizi_count = laizi_count + cards.lz_matrix[k]
                end

--                need_laizi_count = need_laizi_count + math_mod((v-cards.lz_matrix[k]), 2)
                local sss = (v-cards.lz_matrix[k]) % 2
                need_laizi_count = need_laizi_count + sss
            end
        end

        if laizi_count < need_laizi_count then
            return false
        end
    end

    return true
end




local gameConst = {}
gameConst.CardType =
{
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,   --万
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,   --筒
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,   --条
    0x31, 0x32, 0x33, 0x34,                                 --东南西北
    0x41, 0x42, 0x43,                                       --中发白
    0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58          --春夏秋冬梅兰竹菊
}




local function initMatrix()
    local mt = {}
    for _,v in ipairs(gameConst.CardType) do
        mt[v] = 0
    end
    return mt
end


local cards = {}
cards.matrix = initMatrix()
cards.lz_matrix = initMatrix()
cards.matrix[0x11] = 1
cards.matrix[0x14] = 1
cards.matrix[0x17] = 1
cards.matrix[0x02] = 1
cards.matrix[0x05] = 1
cards.matrix[0x08] = 1
cards.matrix[0x23] = 1
cards.lz_matrix[0x26] = 1
cards.matrix[0x29] = 1
cards.matrix[0x31] = 1
cards.matrix[0x32] = 1
cards.matrix[0x43] = 1
cards.matrix[0x34] = 1
cards.matrix[0x42] = 1

print("shi san bu kao:", paixing:checkMostCluttered(cards))

local cards2 = {}
cards2.matrix = initMatrix()
cards2.lz_matrix = initMatrix()
cards2.matrix[0x11] = 2
cards2.matrix[0x12] = 2
cards2.matrix[0x03] = 2
cards2.matrix[0x14] = 4
cards2.matrix[0x25] = 0
cards2.lz_matrix[0x16] = 2
cards2.matrix[0x17] = 2

print("checkQiDui:", paixing:checkQiDui(cards2, false))

print(math.floor(2^3))
--for k,v in pairs(_G) do print(k,v) end




local dump = require("dump")

local function cell_mul(a, b, m, n)
	local total
	for i = 1, #a[m] do
		if a[m][i] and b[i][n] then
			total = total or 0
			total = total + a[m][i] * b[i][n]
		end
	end
	return total
end

local function matrix_mul(a, b)
	local result = {}
	for m = 1, #a do
		result[m] = {}
		for n = 1, #a[m] do
			local x = cell_mul(a, b, m, n)
			if x then
				result[m][n] = x
			end
		end
	end
	return result
end

local matrix_a =
{
	{1,4,7},
	{2,5,8},
	{3,6,9},
}
local matrix_b =
{
	{9,6,3},
	{8,5,2},
	{7,4,1},
}

local result = matrix_mul(matrix_a, matrix_b)

dump(result, "matrix 3*3")


-- OpenGL 矩阵变换
local matrix_no_change =
{
	{1,0,0},
	{0,1,0},
	{0,0,1},
}
local x, y = 3, 5
local matrix_translate =
{
	{1,0,x},
	{0,1,y},
	{0,0,1},
}
local w, h = 2, 5
local matrix_scale =
{
	{w,0,0},
	{0,h,0},
	{0,0,1},
}
local theta = math.rad(45)
local matrix_rotate =
{
	{ math.cos(theta), math.sin(theta), 0},
	{-math.sin(theta), math.cos(theta), 0},
	{               0,               0, 1},
}
local A = 2
local matrix_shear_x =
{
	{1,A,0},
	{0,1,0},
	{0,0,1},
}
local B = 2
local matrix_shear_y =
{
	{1,0,0},
	{B,1,0},
	{0,0,1},
}
local matrix_reflect =
{
	{-1, 0, 0},
	{ 0,-1, 0},
	{ 0, 0, 1},
}

local matrix_2d =
{
	{2},
	{2},
	{1},
}

dump(matrix_mul(matrix_no_change, matrix_2d), "no change")
dump(matrix_mul(matrix_translate, matrix_2d), "translate")
dump(matrix_mul(matrix_scale, matrix_2d), "scale")
dump(matrix_mul(matrix_rotate, matrix_2d), "rotate")
dump(matrix_mul(matrix_reflect, matrix_2d), "reflect")
dump(matrix_mul(matrix_shear_x, matrix_2d), "shear_x")

local matrix_tra =
{
	{1.0,   0,   0, 0.1},
	{  0, 1.0,   0,   0},
	{  0,   0, 1.0,   0},
	{  0,   0,   0, 1.0}
}

local bb =
{
	{100},
	{0},
	{0},
	{1},
}
dump(matrix_mul(matrix_tra, bb), "SSSSSSSSSSSSSS")





local matrix_rotate = function(theta)
	theta = math.rad(theta)
	return
	{
		{ math.cos(theta), math.sin(theta), 0},
		{-math.sin(theta), math.cos(theta), 0},
		{               0,               0, 1},
	}
end
--[[
for i = 0, 90 do
	local matrix = matrix_mul(matrix_rotate(i), matrix_2d)
	print(string.format("%02d: (%.03f,%.03f)",i,matrix[1][1],matrix[2][1]))
end
]]


local function concat_string(delimiter, ...)
	local result = ""
	for _, v in pairs{...} do
		if v and string.len(v) ~= 0 then
			if string.len(result) ~= 0 then
				result = result .. delimiter .. v
			else
				result = result .. v
			end
		end
	end
	return result
end

print(concat_string(", ", 'abc', "234", nil, "po8uo",'END'))










--[[
local function readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

local function writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

local strstr = readfile("D:/server/test/origin.json")

local str2 = string.gsub(strstr, "\n", "")

print(writefile("D:/server/test/format.json", str2))

]]

local aaa = {11,12,13,14,15,16}
local tmp = aaa[4]
table.remove(aaa, 4)
table.insert(aaa, 1, tmp)
dump(aaa)


local test = "abc"
print(string.sub(test, 1, 1))
print(test:sub(1, 2))



local t1 = {aa=12, func = function() print("func111") end}
t1.__index = t1
local t2 = setmetatable({}, t1)
print(t2.aa)
t2.func()





local Base = {}

function Base:new()
	print("Base:new")
end

function Base:test()
	print("Base:test")
end

local MyClas = {}

function MyClas:new()
	Base.__index = Base
	return setmetatable(MyClas, Base)
end

local instance = MyClas:new()
instance:test()


local AA = {a=123}
local BB
BB = setmetatable({}, {__index = function(tab, key) return getmetatable(tab)[key] end, a=456})
print("mmmmmmmm",BB.a)





local myIndex = function(t, key)
    return getmetatable(t)[key]
end


local Class1 = {}
function Class1:test()
    print('test')
end
Class1.__index = myIndex


local Class2 = {}
function Class2:new()
    local o = {}
    local t  = {__index = myIndex}
    setmetatable(o, t)
    local t1  = {__index = myIndex}
    setmetatable(t, t1)
    setmetatable(t1, Class1)
    return o
end

local ta = Class2.new()
ta:test()


print("9999", require("testlib"))







