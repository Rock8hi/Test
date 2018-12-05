
package.path = package.path .. "E:\\test\\github\\Test\\test\\?.lua;"
print("package.path=", package.path)

require "print_table"

--local bb = {123,43,56,4567,4576,58,6}
--printTable(bb)

local ffi = require "ffi"

printTable(ffi)

<<<<<<< HEAD
=======
ffi.cdef [[
		#pragma pack(4)
		typedef struct {
			unsigned short KindId;
			unsigned char TestBuf[32];
		} st_Regist;
	]]
    
local str = ffi.new("st_Regist")
str.KindId = 5
str.TestBuf = "hello脛茫潞脙"
print("ffi test", str.KindId, ffi.string(str.TestBuf, 32))


ffi.cdef [[
    typedef struct {
        int a;
        unsigned short b;
        char c[5];
        int d[5];
        uint64_t ss[7][8];
        long long e[7][8];
        long f;
        double g;
        float h;
    } Test;
]]

local c = ffi.new("Test")
ffi.fill(c, ffi.sizeof(c), 0)
--[[c.a = 13
c.b = 78
c.c[0] = 12
c.c[1] = 13
c.d[0] = 56]]


local function get_array_width(array_cdata)
    local typeof = tostring(ffi.typeof(array_cdata))
    local typedef = string.gsub(typeof, "^ctype<([%w _]+) %(&%)[%d%[%]]+>$", "%1")
    assert(typeof ~= typedef, typedef)
    return ffi.sizeof(typedef)
end

local function get_array_length(array_cdata)
    return ffi.sizeof(array_cdata) / get_array_width(array_cdata)
end

print("---->>", ffi.sizeof(c.ss))
print("====>>", get_array_width(c.ss))

print("****>>", get_array_length(c.ss))



>>>>>>> d394acc43a46380a031aef29afcaad7698c71a36

print(math.floor(123.45))


local s = {1,2,234,5,45,8,8,8,8}
print(table.concat(s, ";"))


local ss = "这里是银子测试银库测试"
local function check(ss)
    local ss = string.gsub(ss, "银子", "金子")
    local ss = string.gsub(ss, "银库", "金库")
    return ss
end

print(check(ss))

print(string.match("asdfas", "^[a-z0-9_-]+$"))

print(string.match("ldflkajl%fjwejfbaij", "%bab"))



local ss = {}
ss[2] = 789
ss[4] = 789
print(">>----", next(ss))







