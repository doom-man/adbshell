--[[
	文件名：PvpMatchNode.lua
	描述：跨服争霸32进16节点
	创建人：libowen
	创建时间：2019.10.24
--]]

PvpMatchNode = class("PvpMatchNode", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpMatchNode.__index = PvpMatchNode

function PvpMatchNode:create(...)
    local layer = PvpMatchNode.new(...)
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
function PvpMatchNode:ctor()
    print("PvpMatchNode ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
   		if checkMsg(msg.t, MsgCode.PVP_MATCH_DATA_UPDATE) then
      		if msg.c.group == self.info.group then
                self.info.stp = msg.c.stp
                self.info.vs.curRound = msg.c.curRound
      			-- 倒计时
        		self.info.vs.countdown = msg.c.countdown
        		self:refreshNextView()
        		-- 对战数据
        		for i, v in ipairs(self.info.vs.reports) do
        			if v.id == msg.c.reportId then
        				v.atkWin = msg.c.atkWin
        				v.defendWin = msg.c.defendWin
        				v.start = msg.c.start
        				break
        			end
        		end
        		local offest = self.tableView:getContentOffset()
				self.tableView:reloadData()
				self.tableView:setContentOffset(offest)
      		end
        end
    end)
end

-- 初始化
function PvpMatchNode:init()
    print("PvpMatchNode init")
    -- 天阶
    self.btn_tianjie = me.assignWidget(self, "btn_tianjie")
    self.btn_tianjie.tag = PvpMainView.GroupType.TIAN
    me.registGuiClickEvent(self.btn_tianjie, function(sender)
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.TIAN)
	    end
    	NetMan:send(_MSG.get_pvp_info(PvpMainView.GroupType.TIAN))
    end)
    -- 人阶
    self.btn_renjie = me.assignWidget(self, "btn_renjie")
    self.btn_renjie.tag = PvpMainView.GroupType.REN
    me.registGuiClickEvent(self.btn_renjie, function(sender)
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.REN)
	    end
    	NetMan:send(_MSG.get_pvp_info(PvpMainView.GroupType.REN))
    end)
    -- 地阶
    self.btn_dijie = me.assignWidget(self, "btn_dijie")
    self.btn_dijie.tag = PvpMainView.GroupType.DI
    me.registGuiClickEvent(self.btn_dijie, function(sender)
    	for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
	    	v:setEnabled(v.tag ~= PvpMainView.GroupType.DI)
	    end
    	NetMan:send(_MSG.get_pvp_info(PvpMainView.GroupType.DI))
    end)
    -- 标题
    self.text_title = me.assignWidget(self, "text_title")
    self.text_title:setString("")
    -- 下一场倒计时
    self.node_rich = me.assignWidget(self, "node_rich")
    self.node_rich:removeAllChildren()
    local richText = mRichText:create("")
	richText:setAnchorPoint(cc.p(0.5, 0.5))
	self.node_rich:addChild(richText)
	self.richText = richText

    self.layout_table = me.assignWidget(self, "layout_table")
    -- 模板节点
    self.layout_item = me.assignWidget(self, "layout_item")
    self.layout_item:setVisible(false)

    return true
end

-- 设置节点数据
function PvpMatchNode:setData(data)
	self.info = data
	-- 刷新内容
	self:refreshView()
end

-- 刷新内容
function PvpMatchNode:refreshView()
	local week = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
	local tableSize = self.layout_table:getContentSize()
    local function numberOfCellsInTableView(table)
        return #self.info.vs.reports
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
        local info = self.info.vs.reports[idx + 1]
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
        if self.info.stp == 1 and self.info.vs.curRound == info.session then
            text_score:setString("正在对决")
            text_score:setEnabled(false)
            text_score:setTextColor(cc.c3b(0x67, 0xff, 0x02))
            img_result_attacker:setVisible(false)
            img_result_defender:setVisible(false)
        else
            if info.start == 0 then
                text_score:setString("即将开始")
                text_score:setEnabled(false)
                text_score:setTextColor(cc.c3b(0xa9, 0x93, 0x79))
                img_result_attacker:setVisible(false)
                img_result_defender:setVisible(false)
            else
                text_score:setString(string.format("%s:%s【战报】", info.atkWin, info.defendWin))
                text_score:setEnabled(true)
                text_score:setTextColor(cc.c3b(0xa9, 0x93, 0x79))
                me.registGuiClickEvent(text_score,  function()
                    local view = PvpFightReportView:create("pvp/PvpFightReportView.csb")
                    me.runningScene():addChild(view, me.MAXZORDER)
                    me.showLayer(view, "img_bg")
                    view:setReportType(2, info.id)
                end)
                img_result_attacker:setVisible(true)
                img_result_attacker:loadTexture(info.atkWin > info.defendWin and "kuafuzhengba_12.png" or "kuafuzhengba_3.png")
                img_result_defender:setVisible(true)
                img_result_defender:loadTexture(info.atkWin > info.defendWin and "kuafuzhengba_3.png" or "kuafuzhengba_12.png")
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
    -- 页签
    for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
        if v.tag == self.info.group then
            v:setEnabled(false)
        else
            v:setEnabled(true)
            me.setWidgetCanTouchDelay(v, 1.0)
        end
    end
    self.text_title:setString(string.format("%s对阵表", PvpMainView.StageName[self.info.status]))
    -- 刷新下一场提示
    self:refreshNextView()
end

-- 刷新下一场提示
function PvpMatchNode:refreshNextView()
    -- 状态：0：未开始，1：进行中，2：已结束
	self.node_rich:stopAllActions()
    if self.info.stp == 0 then
        local tempSecond = self.info.vs.countdown
        local function countdown()
            if tempSecond > 0 then
                local timeStr = me.formartSecTimeHour(tempSecond)
                local tempStr = string.format("<txt0024,67FF02>%s&<txt0024,D4CDB9>后开启%s&", timeStr, PvpMainView.StageName[self.info.status])
                self.richText:setString(tempStr)
                tempSecond = tempSecond - 1
            else
                self.node_rich:stopAllActions()
                local tempStr = string.format("<txt0024,D4CDB9>即将进行%s&", PvpMainView.StageName[self.info.status])
                self.richText:setString(tempStr)
            end
        end
        countdown()
        self.node_rich:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1.0),
            cc.CallFunc:create(function()
                countdown()
            end)
        )))
    elseif self.info.stp == 1 then
        local tempSecond = self.info.vs.countdown
        if self.info.vs.curRound <= self.info.vs.round then
            local function countdown()
                if tempSecond > 0 then
                    local timeStr = me.formartSecTimeHour(tempSecond)
                    local tempStr = string.format("<txt0024,D4CDB9>正在进行&<txt0024,A99379>第%s场&<txt0024,D4CDB9>，共&<txt0024,A99379>%s&<txt0024,D4CDB9>场，&<txt0024,67FF02>%s&<txt0024,D4CDB9>后进行下一场&",
                        self.info.vs.curRound, self.info.vs.round, timeStr)
                    self.richText:setString(tempStr)
                    tempSecond = tempSecond - 1
                else
                    self.node_rich:stopAllActions()
                    local tempStr = string.format("<txt0024,D4CDB9>正在进行&<txt0024,A99379>第%s场&<txt0024,D4CDB9>，共&<txt0024,A99379>%s&<txt0024,D4CDB9>场，&<txt0024,67FF02>00:00:00&<txt0024,D4CDB9>后进行下一场&",
                        self.info.vs.curRound, self.info.vs.round)
                    self.richText:setString(tempStr)
                end
            end
            countdown()
            self.node_rich:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function()
                    countdown()
                end)
            )))
        else
            self.node_rich:stopAllActions()
            local tempStr = string.format("<txt0024,D4CDB9>%s已结束，即将进入下一阶段&", PvpMainView.StageName[self.info.status])
            self.richText:setString(tempStr)
        end
    else
        local tempStr = string.format("<txt0024,D4CDB9>%s已结束，即将进入下一阶段&", PvpMainView.StageName[self.info.status])
        self.richText:setString(tempStr)
    end
end

function PvpMatchNode:onEnter()
    print("PvpMatchNode onEnter")
end

function PvpMatchNode:onEnterTransitionDidFinish()
    print("PvpMatchNode onEnterTransitionDidFinish")
end

function PvpMatchNode:onExit()
    print("PvpMatchNode onExit")
    UserModel:removeLisener(self.lisener)
end
