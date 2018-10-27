
package.path = package.path .. "E:\\test\\github\\Test\\test\\?.lua;"
print("package.path=", package.path)

require "print_table"

--local bb = {123,43,56,4567,4576,58,6}
--printTable(bb)

local ffi = require "ffi"

printTable(ffi)

ffi.cdef [[
		#pragma pack(4)
		typedef struct {
			unsigned short KindId;
			unsigned char TestBuf[32];
		} st_Regist;
	]]
    
local str = ffi.new("st_Regist")
str.KindId = 5
str.TestBuf = "helloÄãºÃ"
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





















