
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

local dd = "123"
print("string.format", string.format("0x%x", string.sub(dd, 2, 2)))


local aa = "ab.com.cde"
print("string.sub", string.sub(aa, 2, 4))

print("string.find", string.find(aa, ".com"))















--[[
local overwrite_function_names = {"setVisible", "removeFromParent"}
local function overwrite_node_function(funcName)
    if Node[funcName] then
        Node["_" .. funcName] = Node[funcName]
        Node[funcName] = function(self, visible)
            if tolua.isnull(self) then
                return
            end
            Node["_" .. funcName](self, visible)
        end
    end
end
for _, func_name in ipairs(overwrite_function_names) do
    overwrite_node_function(func_name)
end
]]




--[[

local TableViewTestLayer = class("TableViewTestLayer")
TableViewTestLayer.__index = TableViewTestLayer

function TableViewTestLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, TableViewTestLayer)
    return target
end

function TableViewTestLayer.cellSizeForTable(table,idx) 
    return 60,60
end

function TableViewTestLayer.tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    print("new index",idx)
    if idx == TableViewTestLayer.page_index-1 then
        performWithDelay(TableViewTestLayer.tableView, function()
            TableViewTestLayer.test()
        end, 1)
    end
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        local sprite = cc.Sprite:create("public/public_fish_toast.png")
        sprite:setAnchorPoint(cc.p(0,0))
        sprite:setPosition(cc.p(0, 0))
        cell:addChild(sprite)

        label = cc.Label:createWithSystemFont(strValue, "Helvetica", 20.0)
        label:setPosition(cc.p(0,0))
        label:setAnchorPoint(cc.p(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = cell:getChildByTag(123)
        if nil ~= label then
            label:setString(strValue)
        end
    end

    return cell
end

function TableViewTestLayer.numberOfCellsInTableView(table)
   return TableViewTestLayer.page_index
end

function TableViewTestLayer.next_page_data()

end

function TableViewTestLayer.prev_page_data()

end

function TableViewTestLayer:init()
    local winSize = cc.Director:getInstance():getWinSize()

    TableViewTestLayer.all_page_data = {}
    TableViewTestLayer.page_index = 20

    local tableView = cc.TableView:create(cc.size(60, 350))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(display.cx,200)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(tableView)
    tableView:registerScriptHandler(TableViewTestLayer.cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(TableViewTestLayer.tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(TableViewTestLayer.numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(function(a,cell)
        print("recycke",cell:getIdx())
    end, cc.TABLECELL_WILL_RECYCLE)
    tableView:reloadData()
    TableViewTestLayer.tableView = tableView

    local btn = ccui.Button:create("public/public_BtnStyle_4.png")
    btn:setPosition(cc.p(display.cx-200, display.cy))
    btn:addTo(self)
    btn:addClickEventListener(function()
        TableViewTestLayer.test()
    end)

    return true
end

function TableViewTestLayer.test()
    local tableView = TableViewTestLayer.tableView
    TableViewTestLayer.page_index = TableViewTestLayer.page_index +10
    local lastOffset = tableView:minContainerOffset()
    tableView:reloadData()
    local newOffset = tableView:minContainerOffset()
    local hopeOffset = cc.pSub(newOffset,lastOffset)
    -- local half = math.abs(newOffset.y) / TableViewTestLayer.page_index / 2
    -- hopeOffset.y = hopeOffset.y + half
    tableView:setContentOffset(hopeOffset)
end

function TableViewTestLayer.create()
    local layer = TableViewTestLayer.extend(cc.Layer:create())
    if nil ~= layer then
        layer:init()
    end

    return layer
end

local function runTableViewTest()
    local newScene = cc.Scene:create()
    local newLayer = TableViewTestLayer.create()
    newScene:addChild(newLayer)
    return newScene
end

cc.Director:getInstance():runWithScene(runTableViewTest())

]]
