--[[
	文件名：PvpFightReportView.lua
	描述：跨服争霸战报页面
	创建人：libowen
	创建时间：2019.10.24
--]]

PvpFightReportView = class("PvpFightReportView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpFightReportView.__index = PvpFightReportView

-- 分路名
local RoadName = {
    [0] = "上路",
    [1] = "中路",
    [2] = "下路",
}

function PvpFightReportView:create(...)
    local layer = PvpFightReportView.new(...)
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
function PvpFightReportView:ctor()
    print("PvpFightReportView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_TWO_PLAYER_WAR_REPORT) or checkMsg(msg.t, MsgCode.PVP_PERSONAL_WAR_REPORT) then
            self.info = msg.c
            -- 刷新列表
            self:refreshTableView()
      	-- 战报详情
        elseif checkMsg(msg.t, MsgCode.PVP_WAR_REPORT_DETAIL) then
       		if msg.c.index == 1 then
	        	if self.detailView and not tolua.isnull(self.detailView) then
	        		self.detailView:removeFromParent()
	        		self.detailView = nil
	        	end
	        	local view = mailFightInfor:create("mailFightInfor.csb")
	       		self:addChild(view)
	       		me.showLayer(view, "bg_frame")
	       		self.detailView = view
	       		local mailData = self:makeUpMailData(msg)
	            view:setMailType(mailview.PVP)
	            view:setData(mailData, NetMan--[[user.Cross_Sever_Status == mCross_Sever and netBattleMan or NetMan]])
	        end
        end
    end)
end

-- 初始化
function PvpFightReportView:init()
    print("PvpFightReportView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 海选记录
    self.img_preSelect = me.assignWidget(self.img_bg, "img_preSelect")
    self.img_preSelect:setVisible(false)
    me.registGuiClickEvent(self.img_preSelect, function(sender)
        local view = PvpRecordView:create("pvp/PvpRecordView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
    end)
    self.text_preSelect = me.assignWidget(self.img_bg, "text_preSelect")
    self.text_preSelect:setVisible(false)
    me.registGuiClickEvent(self.text_preSelect, function(sender)
        local view = PvpRecordView:create("pvp/PvpRecordView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
    end)
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    self.img_center = me.assignWidget(self.img_bg, "img_center")
    -- 空提示
    self.text_empty = me.assignWidget(self.img_center, "text_empty")
    self.text_empty:setVisible(false)
    self.layout_table = me.assignWidget(self.img_center, "layout_table")
    -- 模板节点
    self.layout_item = me.assignWidget(self.img_center, "layout_item")
    self.layout_item:setVisible(false)

    return true
end

-- 设置战报类型
--[[
	type 		-- 战报类型：1:玩家个人战报  2:小组玩家战报
	id 			-- 小组玩家id
--]]
function PvpFightReportView:setReportType(rType, id)
	if rType == 1 then
        self.img_preSelect:setVisible(true)
        self.text_preSelect:setVisible(true)
		-- 获取玩家个人战报
		NetMan:send(_MSG.get_pvp_personal_war_report(id))
	elseif rType == 2 then
        self.img_preSelect:setVisible(false)
        self.text_preSelect:setVisible(false)
		-- 获取小组玩家战报
    	NetMan:send(_MSG.get_pvp_two_player_war_report(id))
	end
end

-- 刷新table
function PvpFightReportView:refreshTableView()
    if self.info.list and #self.info.list > 0 then
        self.text_empty:setVisible(false)
    else
        self.text_empty:setVisible(true)
    end
    local tableSize = self.layout_table:getContentSize()
    local function numberOfCellsInTableView(table)
        return #self.info.list
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 170 + 5
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            -- 创建模板
            local node = self.layout_item:clone()
            node:setSwallowTouches(false)
            node:setVisible(true)
            node:setPosition(cc.p(0, 5))
            cell:addChild(node)
            cell.node = node
        end
        local info = self.info.list[idx + 1]
        me.registGuiClickEvent(cell.node, function(sender)
        	self.selItemInfo = info
	    	NetMan:send(_MSG.get_pvp_war_report_detail(info.id, 1))
	    end)
        -- 标题
        local text_titile = me.assignWidget(cell.node, "text_titile")
        if info.nid == PvpMainView.PvpStage.MATCH_2_1 then
            text_titile:setString(string.format("%s %s %s", info.name, PvpMainView.StageName[info.nid], RoadName[info.road]))
        else
            text_titile:setString(string.format("%s %s 第%s场 %s", info.name, PvpMainView.StageName[info.nid], info.session, RoadName[info.road]))
        end
        -- 时间
        local text_time = me.assignWidget(cell.node, "text_time")
        text_time:setString(me.GetSecTime(info.time))
        -- win:  1:攻方胜利  2:攻方失败
        -- 攻击方
        local text_name_attacker = me.assignWidget(cell.node, "text_name_attacker")
        text_name_attacker:setString(info.attackerName)
        local img_result_attacker = me.assignWidget(cell.node, "img_result_attacker")
        img_result_attacker:loadTexture(info.win == 1 and "zhanbao_icon_shengli.png" or "kuafuzhengba_37.png")
        -- 防守方
        local text_name_defender = me.assignWidget(cell.node, "text_name_defender")
        text_name_defender:setString(info.defenderName)
        local img_result_defender = me.assignWidget(cell.node, "img_result_defender")
        img_result_defender:loadTexture(info.win == 2 and "zhanbao_icon_shengli.png" or "kuafuzhengba_37.png")

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

-- 依照mail数据格式构造战报数据
function PvpFightReportView:makeUpMailData(msg)
	local mail = {
		FighType = 0, FightType = 0, Property = 0, atcNum = 0, defNum = 0,
		belong = 0, durable = 0, landLv = 0, loseArmy = 1, name = "粮食",
		nvalue = 0, rType = 1, roleuid = 0, status = 0,
		time = self.selItemInfo.time / 1000, title = "", type = 0,
		win = 0, x = 0, y = 0,
		attacker = {
			uid = self.selItemInfo.attacker,
			name = self.selItemInfo.attackerName,
			lv = 0,
		},
		defender = {
			uid = self.selItemInfo.defender,
			name = self.selItemInfo.defenderName,
			lv = 0,
		}
	}
	mail.uid = msg.c.uid
	mail.success = msg.c.success
    mail.gold = msg.c.gold
    mail.wood = msg.c.wood
    mail.stone = msg.c.stone
    mail.food = msg.c.food
    mail.itemList = msg.c.itemList

    --攻
    mail.attacker.info = msg.c.attacker
    mail.attacker.infoship = msg.c.attackerShip
    mail.attacker.inforune = msg.c.attackerRune
    mail.attacker.infohero = msg.c.atkHeros
    mail.attacker.wenming = msg.c.atkCountry
    -- 防
    mail.defender.info = msg.c.defender
    mail.defender.infoship = msg.c.defenderShip
    mail.defender.inforune = msg.c.defenderRune
    mail.defender.infohero = msg.c.defendHeros
    mail.defender.wenming = msg.c.defCountry

    return mail
end

function PvpFightReportView:onEnter()
    print("PvpFightReportView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpFightReportView:onEnterTransitionDidFinish()
    print("PvpFightReportView onEnterTransitionDidFinish")
end

function PvpFightReportView:onExit()
    print("PvpFightReportView onExit")
    UserModel:removeLisener(self.lisener)
end
