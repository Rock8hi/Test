local str = "12ab34,eed,56"
local num = ""
for w in string.gmatch(str, "[,%d+]") do
    print("xxx= ", w)
    num = num .. w
end
print(tonumber(num))

print(os.date("!%x", os.time()+24*3600))

-- S.o8M.q-_ZMQRhRC


--[[
local function test(...)
    local file = io.open("E:/test/github/Test/test/log.txt", "a")
    file:write("[" .. os.date("%c", os.time()) .. "]\t")
    for _, v in ipairs{...} do
        file:write(tostring(v) .. "\t")
    end
    file:write("\n")
    io.close(file)
end

print = test
print("123","sfas",7897,false,888)
print("123","sfas",7897,false,887)
print("123","sfas",7897,false,880)


local function hello(cdef, cstr, msg)
    local ffi = require("ffi")
    ffi.cdef(cdef)
    local st = ffi.new(cstr)
    ffi.copy(st, msg, ffi.sizeof(st))
    return st
end
]]


local ffi = require("ffi")

print(ffi.os)
print(ffi.arch)

print(ffi.abi("win8ii"))

ffi.cdef[[
int MessageBoxA(void *w, const char *txt, const char *cap, int type);
]]
--ffi.C.MessageBoxA(nil, "Hello world!", "Test", 0)

ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]

local sleep
if ffi.os == "Windows" then
  function sleep(s)
    ffi.C.Sleep(s*1000)
  end
else
  function sleep(s)
    ffi.C.poll(nil, 0, s*1000)
  end
end

--[[for i=1,160 do
  io.write(".")
  io.flush()
  sleep(0.01)
end
io.write("\n")]]


--
-- lua
-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len
end

-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

-- 自测
function test()
    -- test utf8len
    assert(utf8len("你好1世界哈哈") == 7)
    assert(utf8len("你好世界1哈哈 ") == 8)
    assert(utf8len(" 你好世 界1哈哈") == 9)
    assert(utf8len("12345678") == 8)
    assert(utf8len("øpø你好pix") == 8)

    -- test utf8sub
    assert(utf8sub("你好1世界哈哈",2,5) == "好1世界哈")
    assert(utf8sub("1你好1世界哈哈",2,5) == "你好1世界")
    assert(utf8sub(" 你好1世界 哈哈",2,6) == "你好1世界 ")
    assert(utf8sub("你好世界1哈哈",1,5) == "你好世界1")
    assert(utf8sub("12345678",3,5) == "34567")
    assert(utf8sub("øpø你好pix",2,5) == "pø你好p")

    print("all test succ")
end

--test()



print(debug.getinfo (2))
print("hello")
























