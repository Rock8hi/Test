
package.path = package.path .. "E:\\test\\github\\Test\\test\\?.lua;"
print("package.path=", package.path)

require "print_table"

--local bb = {123,43,56,4567,4576,58,6}
--printTable(bb)

local ffi = require "ffi"

printTable(ffi)


print(math.floor(123.45))


local s = {1,2,234,5,45,8,8,8,8}
print(table.concat(s, ";"))


local ss = "���������Ӳ����������"
local function check(ss)
    local ss = string.gsub(ss, "����", "����")
    local ss = string.gsub(ss, "����", "���")
    return ss
end

print(check(ss))

print(string.match("asdfas", "^[a-z0-9_-]+$"))

print(string.match("ldflkajl%fjwejfbaij", "%bab"))



local ss = {}
ss[2] = 789
ss[4] = 789
print(">>----", next(ss))







