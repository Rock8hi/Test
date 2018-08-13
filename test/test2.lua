
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
























