print("hello lua")

local ffi = require("ffi")

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

ffi.cdef [[
    typedef int rock;
    typedef struct {
        int a;
        unsigned short b;
        char c[5];
        int d[5];
        uint64_t ss[17];
        long long e[7][8][87][98];
        long f;
        double g;
        float h;
    } Test;
]]

local c = ffi.new("Test")
ffi.fill(c, ffi.sizeof(c), 127)


-- 分析C结构体中定义的一维或多维数组中定义的具体维数
-- 返回格式为逗号分隔符隔开的字符串，例如: 2,3,15,8
local function analyze_array_cdata(array_cdata)
    local ctype_string = tostring(ffi.typeof(array_cdata))
    
    local tmp, count = string.gsub(ctype_string, "%[%d+%]", "")
    assert(tmp ~= ctype_string)
    
    local pat = "^ctype<[%w _]+ %(&%)"
    local rep = ""
    for i = 1, count do
        pat = pat .. "%[(%d+)%]"
        if i ~= 1 then
            rep = rep .. string.format(",%%%d", i)
        else
            rep = rep .. string.format("%%%d", i)
        end
    end
    pat = pat .. ">$"
    local typedef = string.gsub(ctype_string, pat, rep)
    assert(typedef ~= ctype_string, typedef)
    
    return typedef
end

-- 分析C结构体中定义的一维或多维数组中定义的数据类型和具体维数
-- 返回格式为逗号分隔符隔开的字符串，例如: int,2,3,8 或 int64_t,2,8
local function analyze_array_cdata_ex(array_cdata)
    local ctype_string = tostring(ffi.typeof(array_cdata))
    
    local tmp, count = string.gsub(ctype_string, "%[%d+%]", "")
    assert(tmp ~= ctype_string)
    
    local pat = "^ctype<([%w _]+) %(&%)"
    local rep = "%1"
    for i = 1, count do
        pat = pat .. "%[(%d+)%]"
        rep = rep .. string.format(",%%%d", i+1)
    end
    pat = pat .. ">$"
    local typedef = string.gsub(ctype_string, pat, rep)
    assert(typedef ~= ctype_string, typedef)
    
    return typedef
end

dump(string.split(analyze_array_cdata(c.e), ","))
dump(string.split(analyze_array_cdata_ex(c.e), ","))

-- 分析C结构体中定义的一维或多维数组中定义的数据类型
local function get_array_width(array_cdata)
    local typeof = tostring(ffi.typeof(array_cdata))
    local typedef = string.gsub(typeof, "^ctype<([%w _]+) %(&%)[%d%[%]]+>$", "%1")
    assert(typeof ~= typedef, typedef)
    return ffi.sizeof(typedef)
end

-- 测量C结构体中定义的一维或多维数组的总长度
local function get_array_length(array_cdata)
    return ffi.sizeof(array_cdata) / get_array_width(array_cdata)
end

--print("---->>", ffi.sizeof(c.ss))
--print("====>>", get_array_width(c.ss))
--print("****>>", get_array_length(c.ss))









