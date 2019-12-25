--[[
	文件名：PvpSelectHeroView.lua
	描述：跨服争霸选择英雄页面
	创建人：libowen
	创建时间：2019.10.21
--]]

PvpSelectHeroView = class("PvpSelectHeroView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpSelectHeroView.__index = PvpSelectHeroView

function PvpSelectHeroView:create(...)
    local layer = PvpSelectHeroView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end

-- 构造器
function PvpSelectHeroView:ctor()
    print("PvpSelectHeroView ctor")
end

-- 初始化
function PvpSelectHeroView:init()
    print("PvpSelectHeroView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.img_top = me.assignWidget(self.img_bg, "img_top")
    self.btn_close = me.assignWidget(self.img_top, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
        self:removeFromParent()
    end)
    -- 英雄table
    self.img_left = me.assignWidget(self.img_bg, "img_left")
    self.layout_table = me.assignWidget(self.img_left, "layout_table")
    -- 模板
    self.layout_item = me.assignWidget(self.img_left, "layout_item")
    self.layout_item:setVisible(false)
    -- 头像
    self.img_right = me.assignWidget(self.img_bg, "img_right")
    self.img_header = me.assignWidget(self.img_right, "img_header")
    self.img_header:setVisible(false)
    self.panel_star = me.assignWidget(self.img_right, "panel_star")
    -- 名字
    self.text_name = me.assignWidget(self.img_right, "text_name")
    -- 介绍
    self.text_desc = me.assignWidget(self.img_right, "text_desc")
    -- 上阵
    self.btn_select = me.assignWidget(self.img_right, "btn_select")
    me.registGuiClickEvent(self.btn_select, function()
    	if self.selCb then
    		self.selCb(self.showList[self.selIndex])
    	end
    	self:removeFromParent()
    end)
    
    return true
end

-- 设置可用英雄数据
function PvpSelectHeroView:setPvpHeroData(list)
	self.showList = list
	-- 列数
	self.colNum = 4
	-- 行数
	self.rowNum = math.ceil(#self.showList / self.colNum)
	-- 刷新table
	self:refreshTableView()
end

-- 刷新tableview
function PvpSelectHeroView:refreshTableView()
	local tableSize = self.layout_table:getContentSize()
	local function numberOfCellsInTableView(table)
        return self.rowNum
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 130
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        for i = 1, self.colNum do
        	local index = idx * self.colNum + i
        	local info = self.showList[index]
        	if info then
        		local node = self.layout_item:clone()
        		node:setVisible(true)
        		node:setAnchorPoint(cc.p(0, 0.5))
        		node:setPosition(cc.p(10 + 120 * (i - 1), 65))
        		cell:addChild(node)
        		node.index = index
        		me.registGuiClickEvent(node, function(sender)
			    	self:selectNodeByIndex(index)
			    end)
                node:setSwallowTouches(false)
        		-- 图标
        		local img_header = me.assignWidget(node, "img_header")
        		img_header:loadTexture(getItemIcon(info.defid))
                -- 星级
                local panel_star = me.assignWidget(node, "panel_star")
                local starLv = info.level
                panel_star:removeAllChildren()
                local starWidth = 15
                local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
                for i = 1, starLv do
                    local img_star = ccui.ImageView:create()
                    img_star:loadTexture("rune_star.png", me.localType)
                    local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
                    local y = 25
                    img_star:setPosition(cc.p(x, y))
                    img_star:setScale(0.5)
                    panel_star:addChild(img_star)
                end
        		-- 选中框
        		local img_select = me.assignWidget(node, "img_select")
        		img_select:setVisible(false)
        	end
        end

        return cell
    end
    self.layout_table:removeAllChildren()
    local tableView = cc.TableView:create(tableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.layout_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView = tableView
    -- 选中第一个
    if #self.showList > 0 then
    	self:selectNodeByIndex(1)
    	self.btn_select:setEnabled(true)
    else
    	self.btn_select:setEnabled(false)
    end
end

-- 选中某个英雄
function PvpSelectHeroView:selectNodeByIndex(index)
	self.selIndex = index
	for idx = 0, self.rowNum - 1 do
		local cell = self.tableView:cellAtIndex(idx)
		if cell then
			for i, node in ipairs(cell:getChildren()) do
				local img_select = me.assignWidget(node, "img_select")
        		img_select:setVisible(node.index == self.selIndex)
			end
		end
	end
	-- 刷新右侧展示
	self:refreshRightView()
end

-- 刷新右侧展示
function PvpSelectHeroView:refreshRightView()
	local info = self.showList[self.selIndex]
	local cfgItem = cfg[CfgType.ETC][me.toNum(info.defid)]
	self.img_header:loadTexture(getItemIcon(cfgItem.id))
	self.img_header:setVisible(true)
	self.text_name:setString(cfgItem.name)
    -- 星级
    local starLv = info.level
    self.panel_star:removeAllChildren()
    local starWidth = 15
    local startX = self.panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
    for i = 1, starLv do
        local img_star = ccui.ImageView:create()
        img_star:loadTexture("rune_star.png", me.localType)
        local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
        local y = 25
        img_star:setPosition(cc.p(x, y))
        img_star:setScale(0.5)
        self.panel_star:addChild(img_star)
    end
    local tempList = string.split(cfgItem.describe, "|")
    if tempList[info.level + 1] then
       self.text_desc:setString(tempList[info.level + 1])
    end
end

-- 选中回调
function PvpSelectHeroView:setSelectCallback(cb)
	self.selCb = cb
end

function PvpSelectHeroView:onEnter()
    print("PvpSelectHeroView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpSelectHeroView:onEnterTransitionDidFinish()
    print("PvpSelectHeroView onEnterTransitionDidFinish")
end

function PvpSelectHeroView:onExit()
    print("PvpSelectHeroView onExit")
end
