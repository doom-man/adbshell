--[[
	文件名：PvpRewardView.lua
	描述：跨服争霸奖励页面
	创建人：libowen
	创建时间：2019.10.29
--]]

PvpRewardView = class("PvpRewardView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpRewardView.__index = PvpRewardView

function PvpRewardView:create(...)
    local layer = PvpRewardView.new(...)
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
function PvpRewardView:ctor()
    print("PvpRewardView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_LIMIT_REWARDS) then
            self.info = msg.c
            -- 刷新列表
            self:refreshTableView()
        end
    end)
    -- 默认天阶
    NetMan:send(_MSG.CheckActivity_Limit_Reward(21))
end

-- 初始化
function PvpRewardView:init()
    print("PvpRewardView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 天阶
    self.btn_tianjie = me.assignWidget(self.img_bg, "btn_tianjie")
    self.btn_tianjie.tag = PvpMainView.GroupType.TIAN
    self.btn_tianjie:setEnabled(false)
    me.registGuiClickEvent(self.btn_tianjie, function(sender)
        self:tabBtnClicked(sender.tag)
    	NetMan:send(_MSG.CheckActivity_Limit_Reward(21))
    end)
    -- 人阶
    self.btn_renjie = me.assignWidget(self.img_bg, "btn_renjie")
    self.btn_renjie.tag = PvpMainView.GroupType.REN
    me.registGuiClickEvent(self.btn_renjie, function(sender)
        self:tabBtnClicked(sender.tag)
    	NetMan:send(_MSG.CheckActivity_Limit_Reward(22))
    end)
    -- 地阶
    self.btn_dijie = me.assignWidget(self.img_bg, "btn_dijie")
    self.btn_dijie.tag = PvpMainView.GroupType.DI
    me.registGuiClickEvent(self.btn_dijie, function(sender)
        self:tabBtnClicked(sender.tag)
    	NetMan:send(_MSG.CheckActivity_Limit_Reward(23))
    end)
    self.layout_table = me.assignWidget(self.img_bg, "layout_table")
    -- 模板节点
    self.item_cell = me.assignWidget(self.img_bg, "item_cell")
    self.item_cell:setVisible(false)
    self.item_goods = me.assignWidget(self.img_bg, "item_goods")
    self.item_goods:setVisible(false)
    self:tabBtnClicked(PvpMainView.GroupType.TIAN)

    return true
end

-- 页签按钮点击事件
function PvpRewardView:tabBtnClicked(tag)
    for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
        local text_title_btn = me.assignWidget(v, "text_title_btn")
        if v.tag == tag then
            v:setEnabled(false)
            text_title_btn:setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
            text_title_btn:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
        else
            v:setEnabled(true)
            text_title_btn:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
            text_title_btn:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
        end
    end
end

-- 刷新table
function PvpRewardView:refreshTableView()
    local tableSize = self.layout_table:getContentSize()
    local function numberOfCellsInTableView(table)
        return #self.info.award
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 134 + 5
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            -- 创建模板
            local node = self.item_cell:clone()
            node:setVisible(true)
            node:setPosition(cc.p(0, 5))
            cell:addChild(node)
            cell.node = node
        end
        local info = self.info.award[idx + 1]
        -- 底板
        local img_mask = me.assignWidget(cell.node, "img_mask")
        img_mask:setVisible(idx % 2 ~= 0)
        -- 排名
        local text_rank = me.assignWidget(cell.node, "text_rank")
        if idx + 1 == #self.info.award then
        	text_rank:setString("参与奖")
        else
        	if info.bg == info.ed then
	        	text_rank:setString(string.format("排名%s", info.bg))
	        else
	        	text_rank:setString(string.format("排名%s~%s", info.bg, info.ed))
	        end
        end
        -- 物品底板
        local panel_goods = me.assignWidget(cell.node, "panel_goods")
        panel_goods:removeAllChildren()
        for i, v in ipairs(info.rw or {}) do
        	local item_goods = self.item_goods:clone()
        	item_goods:setVisible(true)
        	item_goods:setPosition(cc.p(60 + (i - 1) * 120, 67))
        	panel_goods:addChild(item_goods)
        	local etc = cfg[CfgType.ETC][v[1]]
            -- 底框
            item_goods:loadTexture(getQuality(etc.quality))
            -- icon
            local img_goods = me.assignWidget(item_goods, "img_goods")
            img_goods:loadTexture(getItemIcon(etc.id))
            me.registGuiClickEvent(img_goods, function()
                showPromotion(v[1], v[2])
            end)
            img_goods:setSwallowTouches(false)
            -- 描述
            local img_desc_bg = me.assignWidget(item_goods, "img_desc_bg")
            local txt_desc = me.assignWidget(item_goods, "txt_desc")
            if etc.showtxt and etc.showtxt ~= "" then
                img_desc_bg:setVisible(true)
                txt_desc:setVisible(true)
                txt_desc:setString(etc.showtxt)
            else
                img_desc_bg:setVisible(false)
                txt_desc:setVisible(false)
            end
            -- 数量
            local text_num = me.assignWidget(item_goods, "text_num")
            text_num:setString(tostring(v[2]))
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
end

function PvpRewardView:onEnter()
    print("PvpRewardView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpRewardView:onEnterTransitionDidFinish()
    print("PvpRewardView onEnterTransitionDidFinish")
end

function PvpRewardView:onExit()
    print("PvpRewardView onExit")
    UserModel:removeLisener(self.lisener)
end
