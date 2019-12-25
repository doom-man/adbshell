--[[
	文件名：PvpDetailScheduleView.lua
	描述：跨服争霸详细赛程页面
	创建人：libowen
	创建时间：2019.10.29
--]]

PvpDetailScheduleView = class("PvpDetailScheduleView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpDetailScheduleView.__index = PvpDetailScheduleView

function PvpDetailScheduleView:create(...)
    local layer = PvpDetailScheduleView.new(...)
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
function PvpDetailScheduleView:ctor()
    print("PvpDetailScheduleView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_DETAIL_SCHEDULE) then
            self.info = msg.c
            -- 刷新列表
            self:refreshTableView()
        end
    end)
    -- 默认天阶
    NetMan:send(_MSG.get_pvp_detial_schedule(1))
end

-- 初始化
function PvpDetailScheduleView:init()
    print("PvpDetailScheduleView init")
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
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.TIAN)
	    end
    	NetMan:send(_MSG.get_pvp_detial_schedule(1))
    end)
    -- 人阶
    self.btn_renjie = me.assignWidget(self.img_bg, "btn_renjie")
    self.btn_renjie.tag = PvpMainView.GroupType.REN
    me.registGuiClickEvent(self.btn_renjie, function(sender)
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.REN)
	    end
    	NetMan:send(_MSG.get_pvp_detial_schedule(2))
    end)
    -- 地阶
    self.btn_dijie = me.assignWidget(self.img_bg, "btn_dijie")
    self.btn_dijie.tag = PvpMainView.GroupType.DI
    me.registGuiClickEvent(self.btn_dijie, function(sender)
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.DI)
	    end
    	NetMan:send(_MSG.get_pvp_detial_schedule(3))
    end)
    -- 空提示
    self.text_empty = me.assignWidget(self.img_bg, "text_empty")
    self.text_empty:setVisible(false)
    self.layout_table = me.assignWidget(self.img_bg, "layout_table")
    -- 模板节点
    self.layout_item = me.assignWidget(self.img_bg, "layout_item")
    self.layout_item:setVisible(false)

    return true
end

-- 刷新table
function PvpDetailScheduleView:refreshTableView()
	if self.info.list and #self.info.list > 0 then
		self.text_empty:setVisible(false)
	else
		self.text_empty:setVisible(true)
	end
	local week = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
    local tableSize = self.layout_table:getContentSize()
    local function numberOfCellsInTableView(table)
        return #self.info.list
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 50 + 5
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            -- 创建模板
            local node = self.layout_item:clone()
            node:setVisible(true)
            node:setPosition(cc.p(0, 5))
            cell:addChild(node)
            cell.node = node
        end
        local info = self.info.list[idx + 1]
        -- 底板
        local img_mask = me.assignWidget(cell.node, "img_mask")
        img_mask:setVisible(idx % 2 ~= 0)
        -- 场次
        local text_turn = me.assignWidget(cell.node, "text_turn")
        text_turn:setString(string.format("%s第%s场", PvpMainView.StageName[info.nid], info.session))
        -- 时间
        local text_time = me.assignWidget(cell.node, "text_time")
        text_time:setString(string.format("%s%s", week[info.date], me.formartServerTime2(info.time / 1000)))
        -- 进攻方
        local img_result_attacker = me.assignWidget(cell.node, "img_result_attacker")
        local text_attacker = me.assignWidget(cell.node, "text_attacker")
        text_attacker:setString(string.format("%s.%s", info.atkServer, info.atkName))
        if info.atacker == user.uid then
            text_attacker:setTextColor(cc.c3b(0x67, 0xff, 0x02))
        else
            -- 是否同服
            if info.atkTag == 1 then
                text_attacker:setTextColor(cc.c3b(0x5e, 0xad, 0x0b6))
            else
                text_attacker:setTextColor(cc.c3b(0xa9, 0x93, 0x79))
            end
        end
        -- 防守方
        local img_result_defender = me.assignWidget(cell.node, "img_result_defender")
        local text_defender = me.assignWidget(cell.node, "text_defender")
        text_defender:setString(string.format("%s.%s", info.defServer, info.defName))
        if info.defender == user.uid then
            text_defender:setTextColor(cc.c3b(0x67, 0xff, 0x02))
        else
            -- 是否同服
            if info.defenTag == 1 then
                text_defender:setTextColor(cc.c3b(0x5e, 0xad, 0x0b6))
            else
                text_defender:setTextColor(cc.c3b(0xa9, 0x93, 0x79))
            end
        end
        -- 比分
        local text_score = me.assignWidget(cell.node, "text_score")
        if info.start == 0 then
        	text_score:setString("即将开始")
        	text_score:setEnabled(false)
            img_result_attacker:setVisible(false)
            img_result_defender:setVisible(false)
        else
            if info.showMails then
                text_score:setString(string.format("%s:%s【战报】", info.atkWin, info.defendWin))
                text_score:setEnabled(true)
                me.registGuiClickEvent(text_score,  function()
                    local view = PvpFightReportView:create("PvpFightReportView.csb")
                    me.runningScene():addChild(view, me.MAXZORDER)
                    me.showLayer(view, "img_bg")
                    view:setReportType(2, info.id)
                end)
            else
                text_score:setString(string.format("%s:%s", info.atkWin, info.defendWin))
                text_score:setEnabled(false)
            end
            img_result_attacker:setVisible(true)
            img_result_attacker:loadTexture(info.atkWin > info.defendWin and "kuafuzhengba_12.png" or "kuafuzhengba_3.png")
            img_result_defender:setVisible(true)
            img_result_defender:loadTexture(info.atkWin > info.defendWin and "kuafuzhengba_3.png" or "kuafuzhengba_12.png")
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

function PvpDetailScheduleView:onEnter()
    print("PvpDetailScheduleView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpDetailScheduleView:onEnterTransitionDidFinish()
    print("PvpDetailScheduleView onEnterTransitionDidFinish")
end

function PvpDetailScheduleView:onExit()
    print("PvpDetailScheduleView onExit")
    UserModel:removeLisener(self.lisener)
end
