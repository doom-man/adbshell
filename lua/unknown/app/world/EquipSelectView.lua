--[[
	文件名：EquipSelectView.lua
	描述：个人信息选择装备 or 英雄页面
	创建人：libowen
	创建时间：2019.12.4
--]]

EquipSelectView = class("EquipSelectView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
EquipSelectView.__index = EquipSelectView

function EquipSelectView:create(...)
    local layer = EquipSelectView.new(...)
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
function EquipSelectView:ctor()
    print("EquipSelectView ctor")
end

-- 初始化
function EquipSelectView:init()
    print("EquipSelectView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 标题
    self.text_title = me.assignWidget(self, "text_title")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    self.box_mask_up = me.assignWidget(self.img_bg, "box_mask_up")
    -- table父节点
    self.panel_table = me.assignWidget(self.img_bg, "panel_table")
    -- 模板节点
    self.layout_item = me.assignWidget(self.img_bg, "layout_item")
    self.layout_item:setVisible(false)
    -- 空提示
    self.text_empty = me.assignWidget(self.img_bg, "text_empty")
    self.text_empty:setVisible(false)

    return true
end

-- 设置数据
--[[
	data
	{
		slotType 			-- 卡槽类型   10：英雄，6：头盔，7：衣服，8：盾牌，5：武器，9：戒指
		slotItemInfo 		-- 卡槽物品信息，如果已装备
		posId 				-- 位置id
	}
--]]
function EquipSelectView:setData(data)
	self.data = data
	local nameList = {
		[5] = "武器",
		[6] = "头盔",
		[7] = "衣服",
		[8] = "盾牌",
		[9] = "戒指",
		[10] = "副将",
	}
	local nameStr = nameList[self.data.slotType]
	self.text_title:setString(nameStr)
	self.text_empty:setString(string.format("尊敬的领主大人，您当前没有可用的%s", nameStr))
	-- 展示列表
	self.showList = {}
	for k, v in pairs(user.bookPkg) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == self.data.slotType then
            table.insert(self.showList, clone(v))
        end
    end
    if not self.data.slotItemInfo then
    	self.layout_item:setVisible(false)
    	self.panel_table:setContentSize(cc.size(738, 470 - 5))
    	self.box_mask_up:setContentSize(cc.size(759, 470))
    	self.text_empty:setPositionY(470 / 2)
    else
    	self.layout_item:setVisible(true)
    	-- 刷新
        self:refreshLayoutItem(self.layout_item, self.data.slotItemInfo, true)
    	self.panel_table:setContentSize(cc.size(738, 315 - 5))
    	self.box_mask_up:setContentSize(cc.size(759, 315))
    	self.text_empty:setPositionY(315 / 2)
    end
    self:refreshTableView()
end

-- 刷新table
function EquipSelectView:refreshTableView()
    if #self.showList > 0 then
        self.text_empty:setVisible(false)
    else
        self.text_empty:setVisible(true)
    end
    local function numberOfCellsInTableView(tableview)
        return #self.showList
    end
    local function cellSizeForTable(tableview, idx)
        return 738, 127 + 10
    end
    local function tableCellAtIndex(tableview, idx)
        local cell = tableview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        local layout_item = self.layout_item:clone()
        layout_item:setVisible(true)
        layout_item:setAnchorPoint(cc.p(0.5, 0.5))
        layout_item:setPosition(cc.p(369, 68.5))
        cell:addChild(layout_item)
        -- 刷新
        self:refreshLayoutItem(layout_item, self.showList[idx + 1], false)

        return cell
    end
    self.panel_table:removeAllChildren()
    local tableView = cc.TableView:create(self.panel_table:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.panel_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

-- 刷新单个cell
--[[
	layout 			-- 节点
	info 			-- 节点数据
	equiped 		-- 是否已装备
--]]
function EquipSelectView:refreshLayoutItem(layout, info, equiped)
	-- 配置信息
	local cfg_item = cfg[CfgType.ETC][info.defid]
	-- 背景框
	local img_bg = me.assignWidget(layout, "img_bg")
	img_bg:setVisible(not equiped)
	-- 当前装备
	local text_currEquip = me.assignWidget(layout, "text_currEquip")
	text_currEquip:setVisible(equiped)
	-- 底框、图标
	local img_quality = me.assignWidget(layout, "img_quality")
	img_quality:loadTexture(getArchQuility(cfg_item.id), me.localType)
   	local img_icon = me.assignWidget(layout, "img_icon")
   	img_icon:loadTexture(getItemIcon(cfg_item.id), me.plistType)
   	-- 星级
    local panel_star = me.assignWidget(layout, "panel_star")
	local starLv = info.level
    panel_star:removeAllChildren()
    local starWidth = 18
    local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
    for i = 1, starLv do
        local img_star = ccui.ImageView:create()
        img_star:loadTexture("yaosai_15.png", me.localType)
        local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
        local y = 12
        img_star:setPosition(cc.p(x, y))
        img_star:setScale(1.0)
        panel_star:addChild(img_star)
    end
    -- 名字
    local text_name = me.assignWidget(layout, "text_name")
    text_name:setString(cfg_item.name)
    -- 描述
    local text_desc = me.assignWidget(layout, "text_desc")
    local tempList = string.split(cfg_item.describe, "|")
    if tempList[info.level + 1] then
	   text_desc:setString(tempList[info.level + 1])
	else
		text_desc:setString("暂无描述")
    end
    -- 卸下/装备
    local btn_operate = me.assignWidget(layout, "btn_operate")
    local text_title_btn = me.assignWidget(btn_operate, "text_title_btn")
    if equiped then
    	btn_operate:loadTextures("ui_ty_button_hong_154x56.png", "", "", me.localType)
    	text_title_btn:setString("卸下")
    	me.registGuiClickEvent(btn_operate, function(sender)
    		NetMan:send(_MSG.bookUnEquip(info.uid))
    		self:removeFromParent()
    	end)
    else
    	btn_operate:loadTextures("ui_ty_button_lv154x56.png", "", "", me.localType)
    	text_title_btn:setString("装备")
    	me.registGuiClickEvent(btn_operate, function(sender)
    		NetMan:send(_MSG.bookEquip(info.uid, self.data.posId))
    		self:removeFromParent()
    	end)
    end
end

function EquipSelectView:onEnter()
    print("EquipSelectView onEnter")
    me.doLayout(self, me.winSize)
end

function EquipSelectView:onEnterTransitionDidFinish()
    print("EquipSelectView onEnterTransitionDidFinish")
end

function EquipSelectView:onExit()
    print("EquipSelectView onExit")
end
