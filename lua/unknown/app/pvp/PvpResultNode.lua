--[[
	文件名：PvpResultNode.lua
	描述：跨服争霸 16进8、8进4、半决赛、决赛通用节点
	创建人：libowen
	创建时间：2019.10.25
--]]

PvpResultNode = class("PvpResultNode", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpResultNode.__index = PvpResultNode

-- 结果产出点位映射图：例如 第一组对战结束产出位置是第五组的攻击点位，第二组对战结束产出位置是第五组防御点位
local ResultMap = {
	[1] = {turn = 5, name = "attacker"},
	[2] = {turn = 5, name = "defender"},
	[3] = {turn = 6, name = "attacker"},
	[4] = {turn = 6, name = "defender"},
	[5] = {turn = 7, name = "attacker"},
	[6] = {turn = 7, name = "defender"},
	[7] = {turn = -1, name = "winner"},
}

function PvpResultNode:create(...)
    local layer = PvpResultNode.new(...)
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
function PvpResultNode:ctor()
    print("PvpResultNode ctor")
    -- 节点列表
    self.nodeList = {}
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
    	-- 下注
        if checkMsg(msg.t, MsgCode.PVP_BET) then
            if msg.c.group == self.info.group then
            	for index, v in ipairs(self.info.vs.reports) do
            		if v.id == msg.c.id then
	            		v.atkBet = msg.c.atkBet
	            		v.defenBet = msg.c.defenBet
	            		v.myAtkBet = msg.c.myAtkBet
	            		v.myDefenBet = msg.c.myDefenBet
	            		v.atkPL = msg.c.atkPL
	            		v.defenPL = msg.c.defenPL
	            		break
	            	end
            	end
            	self.info.vs.myBet = msg.c.myBet
		    	self.info.vs.betTimes = msg.c.betTimes
		    	-- 刷新页面
		    	self:refreshView()
		    end
	    -- 数据更新
	    elseif checkMsg(msg.t, MsgCode.PVP_MATCH_DATA_UPDATE) then
	    	if msg.c.group == self.info.group then
	    		self.info.stp = msg.c.stp
		    	self.info.vs.curRound = msg.c.curRound
      			-- 倒计时
        		self.info.vs.countdown = msg.c.countdown
        		-- 对战数据
        		for i, v in ipairs(self.info.vs.reports) do
        			if v.id == msg.c.reportId then
        				v.atkWin = msg.c.atkWin
        				v.defendWin = msg.c.defendWin
        				v.start = msg.c.start
        				break
        			end
        		end
        		-- 刷新页面
		    	self:refreshView()
		    end
        end
    end)
end

-- 初始化
function PvpResultNode:init()
    print("PvpResultNode init")
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
	-- 下一场进攻方与防守方
	self.text_attacker = me.assignWidget(self, "text_attacker")
	self.text_vs = me.assignWidget(self, "text_vs")
	self.text_defender = me.assignWidget(self, "text_defender")
	-- 模板
	self.layout_item = me.assignWidget(self, "layout_item")
	self.layout_item:setVisible(false)
	-- 7组
	for i = 1, 7 do
		self.nodeList[i] = {}
		local key = string.format("img_turn%s", i)
		local img_turn = me.assignWidget(self, key)
		-- 进攻方
		local node_attacker = me.assignWidget(img_turn, "node_attacker")
		local layout_attacker = self.layout_item:clone()
		layout_attacker:setVisible(true)
		layout_attacker:setPosition(cc.p(0, 0))
		node_attacker:addChild(layout_attacker)
		self.nodeList[i].attacker = layout_attacker
		-- 防守方
		local node_defender = me.assignWidget(img_turn, "node_defender")
		local layout_defender = self.layout_item:clone()
		layout_defender:setVisible(true)
		layout_defender:setPosition(cc.p(0, 0))
		node_defender:addChild(layout_defender)
		self.nodeList[i].defender = layout_defender
	end
	-- 冠军
	local layout_winner = self.layout_item:clone()
	layout_winner:setPosition(cc.p(0, 0))
	layout_winner:setVisible(true)
	me.assignWidget(self, "node_winner"):addChild(layout_winner)
	self.nodeList.winner = layout_winner
	-- 冠军标识
	self.img_winner = me.assignWidget(self, "img_winner")
	self.img_winner:setVisible(false)

    return true
end

-- 设置节点数据
function PvpResultNode:setData(data)
	self.info = data
	-- 刷新内容
	self:refreshView()
end

-- 刷新内容
function PvpResultNode:refreshView()
	-- 初始化各组进攻方与防守方
	for index, v in ipairs(self.info.vs.reports) do
		for i = 1, 2 do
			local node = i == 1 and self.nodeList[index].attacker or self.nodeList[index].defender
			local nodeInfo = {}
			nodeInfo.playerName = i == 1 and v.atkName or v.defName
			nodeInfo.playerId = i == 1 and v.atacker or v.defender
			nodeInfo.serverName = i == 1 and v.atkServer or v.defServer
			nodeInfo.familyName = i == 1 and v.atkFamily or v.defFamily
			nodeInfo.fightPower = i == 1 and v.atkFightPower or v.defFightPower
			nodeInfo.betNum = i == 1 and v.myAtkBet or v.myDefenBet
			nodeInfo.odds = i == 1 and v.atkPL or v.defenPL
			if i == 1 then
				nodeInfo.isWin = v.atkWin > v.defendWin
			else
				nodeInfo.isWin = v.atkWin < v.defendWin
			end
			-- 身价
			nodeInfo.value = i == 1 and v.atkBet or v.defenBet
			-- 主城皮肤
			nodeInfo.centerId = i == 1 and v.atkCenterId or v.defCenterId
			nodeInfo.adornment = i == 1 and v.atkAdornment or v.defAdornment
			nodeInfo.image = i == 1 and v.atkImage or v.defImage
			-- 能否下注
			nodeInfo.canBet = v.canBet
			self:refreshNode(node, nodeInfo, clone(v))
		end
	end
	-- 各个组产出结果
	local starIdx, endIdx
	if self.info.status == PvpMainView.PvpStage.MATCH_8_4 then
		-- 8进4，检测1~4组
		starIdx = 1
		endIdx = 4
	elseif self.info.status == PvpMainView.PvpStage.MATCH_4_2 then
		-- 4进2，检测5~6组
		starIdx = 5
		endIdx = 6
	elseif self.info.status == PvpMainView.PvpStage.MATCH_2_1 or self.info.status == PvpMainView.STAGE_SHOWING then
		-- 2进1，检测7组
		starIdx = 7
		endIdx = 7
	end
	if starIdx and endIdx then
		for i = starIdx, endIdx do
			local v = self.info.vs.reports[i]
			if v and v.start == 1 then
				self:refreshResultNode(i)
				if starIdx == endIdx and endIdx == 7 then
					self.img_winner:setVisible(true)
				end
			end
		end
	end
	-- 页签
    for i, v in ipairs({self.btn_tianjie, self.btn_renjie, self.btn_dijie}) do
    	if v.tag == self.info.group then
    		v:setEnabled(false)
    	else
    		v:setEnabled(true)
    		me.setWidgetCanTouchDelay(v, 0.5)
    	end
    end
    -- 是否历史
    if self.info.history then
    	self.text_title:setString("上一届对阵图")
    else
    	if self.info.status == PvpMainView.STAGE_SHOWING then
	    	self.text_title:setString("淘汰赛对阵图")
	    else
	    	self.text_title:setString(string.format("%s对阵图", PvpMainView.StageName[self.info.status]))
	    end
    end
    -- 刷新下一场提示
    self:refreshNextView()
end

-- 刷新单个节点
function PvpResultNode:refreshNode(node, nodeInfo, groupInfo)
	-- 底框
	local img_frame = me.assignWidget(node, "img_frame")
	-- 空
	local img_empty = me.assignWidget(node, "img_empty")
	-- 主城图标
	local img_skin  = me.assignWidget(node, "img_skin")
	img_skin:ignoreContentAdaptWithSize(true)
	img_skin:setScale(0.25)
	-- 玩家信息
	local layout_info = me.assignWidget(node, "layout_info")
	-- 服务器
	local text_server = me.assignWidget(layout_info, "text_server")
	-- 下注数
	local img_bets = me.assignWidget(layout_info, "img_bets")
	local text_bets = me.assignWidget(layout_info, "text_bets")
	-- 结果
	local img_result = me.assignWidget(layout_info, "img_result")
	-- 玩家名
	local text_name = me.assignWidget(layout_info, "text_name")
	-- 赔率
	local  text_odds = me.assignWidget(layout_info, "text_odds")
	-- 下注
	local btn_bet = me.assignWidget(layout_info, "btn_bet")
	-- 是否轮空
	if nodeInfo.playerId == 0 then
		img_empty:setVisible(true)
		img_frame:setVisible(false)
		img_skin:setVisible(false)
		layout_info:setVisible(false)
		me.registGuiClickEvent(node, function()
			showTips("虚位以待")
		end)
	else
		img_empty:setVisible(false)
		img_frame:setVisible(true)
		img_skin:setVisible(true)
		if nodeInfo.adornment == 0 then
			local cfgItem = cfg[CfgType.BUILDING][nodeInfo.centerId]
			img_skin:loadTexture(buildIcon(cfgItem), me.localType)
		else
			local cfgItem = cfg[CfgType.SKIN_STRENGTHEN][nodeInfo.adornment]
			img_skin:loadTexture("cityskin"..cfgItem.icon.."_1.png", me.localType)
		end
		layout_info:setVisible(true)
		text_server:setString(nodeInfo.serverName)
		if nodeInfo.betNum > 0 then
			img_bets:setVisible(true)
			text_bets:setVisible(true)
			text_bets:setString(string.format("已猜%s次", nodeInfo.betNum))
		else
			img_bets:setVisible(false)
			text_bets:setVisible(false)
		end
		text_name:setString(nodeInfo.playerName)
		text_odds:setString(string.format("奖金：%s", nodeInfo.odds))
		-- 0：未开始，1：已结束
		if groupInfo.start == 0 then
			img_result:setVisible(false)
			btn_bet:setVisible(nodeInfo.canBet)
			me.registGuiClickEvent(btn_bet, function(sender)
	            -- 下注
	            local view = PvpBetsView:create("pvp/PvpBetsView.csb")
		    	me.runningScene():addChild(view, me.MAXZORDER)
		    	me.showLayer(view, "img_bg")
		    	view:setData(groupInfo, {
		    		group = self.info.group,
		    		betNeedId = self.info.vs.betNeedId,
		    		betPrice = self.info.vs.betPrice,
		    		myBet = self.info.vs.myBet,
		    		betTimes = self.info.vs.betTimes,
		    	})
	        end)
		elseif groupInfo.start == 1 then
			if nodeInfo.isOutput then
				btn_bet:setVisible(false)
				img_result:setVisible(false)
				img_bets:setVisible(false)
				text_bets:setVisible(false)
			else
				img_result:setVisible(true)
				img_result:loadTexture(nodeInfo.isWin and "kuafuzhengba_12.png" or "kuafuzhengba_3.png")
				btn_bet:setVisible(false)
			end
		end
		me.registGuiClickEvent(node, function()
			-- 玩家详情
			local view = PvpPlayerDetailView:create("pvp/PvpPlayerDetailView.csb")
		    me.runningScene():addChild(view, me.MAXZORDER)
		    me.showLayer(view, "img_bg")
		    view:setData(nodeInfo)
		end)
	end
end

-- 刷新下一场提示
function PvpResultNode:refreshNextView()
	self.node_rich:stopAllActions()
	if self.info.stp == 0 then
		local tempSecond = self.info.vs.countdown
		local function countdown()
			if tempSecond > 0 then
				local timeStr = me.formartSecTimeHour(tempSecond)
				local tempStr = string.format("<txt0020,67FF02>%s&<txt0020,D4CDB9>后开启%s&", timeStr, PvpMainView.StageName[self.info.status])
				self.richText:setString(tempStr)
				tempSecond = tempSecond - 1
			else
				self.node_rich:stopAllActions()
				local tempStr = string.format("<txt0020,D4CDB9>即将进行%s&", PvpMainView.StageName[self.info.status])
				self.richText:setString(tempStr)
			end
			self.text_attacker:setString("")
			self.text_vs:setString("")
			self.text_defender:setString("")
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
		local function countdown()
	        if self.info.vs.curRound <= self.info.vs.round then
	    		if tempSecond > 0 then
	    			local timeStr = me.formartSecTimeHour(tempSecond)
	    			local tempStr = string.format("<txt0020,D4CDB9>正在进行&<txt0020,A99379>第%s场&<txt0020,D4CDB9>，共&<txt0020,A99379>%s&<txt0020,D4CDB9>场&<txt0020,67FF02>%s&<txt0020,D4CDB9>后进行下一场&",
	    				self.info.vs.curRound, self.info.vs.round, timeStr)
	    			self.richText:setString(tempStr)
	    			tempSecond = tempSecond - 1
	    		else
	    			self.node_rich:stopAllActions()
	    			local tempStr = string.format("<txt0020,D4CDB9>正在进行&<txt0020,A99379>第%s场&<txt0020,D4CDB9>，共&<txt0020,A99379>%s&<txt0020,D4CDB9>场&<txt0020,67FF02>00:00:00&<txt0020,D4CDB9>后进行下一场&",
	    				self.info.vs.curRound, self.info.vs.round)
	    			self.richText:setString(tempStr)
	    		end
	    		if self.info.status == PvpMainView.PvpStage.MATCH_2_1 then
	    			self.node_rich:stopAllActions()
	    			local tempStr = string.format("<txt0020,D4CDB9>正在进行&<txt0020,A99379>决赛&")
	    			self.richText:setString(tempStr)
	    		end
	    		if not self.currRound or self.currRound ~= self.info.vs.curRound then
	    			self.currRound = self.info.vs.curRound
		    		for i, v in ipairs(self.info.vs.reports) do
		    			if v.nid == self.info.status and v.session == self.info.vs.curRound then
		    				self.text_attacker:setString(string.format("%s.%s", v.atkServer, v.atkName))
							self.text_vs:setString("VS")
							self.text_defender:setString(string.format("%s.%s", v.defServer, v.defName))
		    				break
		    			end
		    		end
		    	end
	        else
	            self.node_rich:stopAllActions()
	            -- 决赛 or 展示
	            local tempStr
	            if self.info.status == PvpMainView.PvpStage.MATCH_2_1 or self.info.status == PvpMainView.STAGE_SHOWING then
	            	tempStr = ""
	            else
	            	tempStr = string.format("<txt0020,D4CDB9>%s已结束，即将进入下一阶段&", PvpMainView.StageName[self.info.status])
	            end 
	            self.richText:setString(tempStr)
	            self.text_attacker:setString("")
				self.text_vs:setString("")
				self.text_defender:setString("")
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
        -- 决赛 or 展示
        local tempStr
        if self.info.status == PvpMainView.PvpStage.MATCH_2_1 or self.info.status == PvpMainView.STAGE_SHOWING then
        	tempStr = ""
        else
        	tempStr = string.format("<txt0020,D4CDB9>%s已结束，即将进入下一阶段&", PvpMainView.StageName[self.info.status])
        end 
        self.richText:setString(tempStr)
        self.text_attacker:setString("")
		self.text_vs:setString("")
		self.text_defender:setString("")
	end
end

-- 刷新胜出节点
function PvpResultNode:refreshResultNode(idx)
	local info = self.info.vs.reports[idx]
	local node, item = nil, ResultMap[idx]
	if item.turn == -1 then
		node = self.nodeList[item.name]
	else
		node = self.nodeList[item.turn][item.name]
	end
	local isAttacker = info.atkWin > info.defendWin
	local nodeInfo = {}
	nodeInfo.playerName = isAttacker and info.atkName or info.defName
	nodeInfo.playerId = isAttacker and info.atacker or info.defender
	nodeInfo.serverName = isAttacker and info.atkServer or info.defServer
	nodeInfo.familyName = isAttacker and info.atkFamily or info.defFamily
	nodeInfo.fightPower = isAttacker and info.atkFightPower or info.defFightPower
	nodeInfo.betNum = isAttacker and info.myAtkBet or info.myDefenBet
	nodeInfo.odds = isAttacker and info.atkPL or info.defenPL
	if isAttacker then
		nodeInfo.isWin = info.atkWin > info.defendWin
	else
		nodeInfo.isWin = info.atkWin < info.defendWin
	end
	-- 身价
	nodeInfo.value = isAttacker and info.atkBet or info.defenBet
	-- 主城皮肤
	nodeInfo.centerId = isAttacker and info.atkCenterId or info.defCenterId
	nodeInfo.adornment = isAttacker and info.atkAdornment or info.defAdornment
	nodeInfo.image = isAttacker and info.atkImage or info.defImage
	nodeInfo.isOutput =  true
	self:refreshNode(node, nodeInfo, clone(info))
end

function PvpResultNode:onEnter()
    print("PvpResultNode onEnter")
end

function PvpResultNode:onEnterTransitionDidFinish()
    print("PvpResultNode onEnterTransitionDidFinish")
end

function PvpResultNode:onExit()
    print("PvpResultNode onExit")
    UserModel:removeLisener(self.lisener)
end
