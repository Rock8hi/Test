
package.path = package.path .. "E:\\test\\github\\Test\\test\\?.lua;"
print(package.path)

require "print_table"

local bb = {123,43,56,4567,4576,58,6}
printTable(bb)


