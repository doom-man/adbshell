--[[
	文件名：PvpBetsView.lua
	描述：跨服争霸下注页面
	创建人：libowen
	创建时间：2019.10.28
--]]

PvpBetsView = class("PvpBetsView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpBetsView.__index = PvpBetsView

function PvpBetsView:create(...)
    local layer = PvpBetsView.new(...)
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
function PvpBetsView:ctor()
    print("PvpBetsView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_BET) then
            if msg.c.group == self.extraInfo.group and msg.c.id == self.info.id then
            	self.info.atkBet = msg.c.atkBet
            	self.info.defenBet = msg.c.defenBet
            	self.info.myAtkBet = msg.c.myAtkBet
            	self.info.myDefenBet = msg.c.myDefenBet
                self.info.atkPL = msg.c.atkPL
                self.info.defenPL = msg.c.defenPL
            	self.extraInfo.myBet = msg.c.myBet
            	self.extraInfo.betTimes = msg.c.betTimes
            	self:refreshView()
            end
        end
    end)
end

-- 初始化
function PvpBetsView:init()
    print("PvpBetsView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 场次轮次
    self.img_center = me.assignWidget(self.img_bg, "img_center")
    self.text_turn = me.assignWidget(self.img_center, "text_turn")
    -- 比赛时间
    self.text_time = me.assignWidget(self.img_center, "text_time")
    -- 进攻方
    self.img_attacker = me.assignWidget(self.img_center, "img_attacker")
    -- 防守方
    self.img_defender = me.assignWidget(self.img_center, "img_defender")
    -- 下注所需资源
    self.img_res = me.assignWidget(self.img_center, "img_res")
    -- 单注所需资源数量
    self.text_num_single = me.assignWidget(self.img_center, "text_num_single")
    -- 剩余下注次数
    self.text_num_left = me.assignWidget(self.img_center, "text_num_left")
    -- 规则
    self.btn_rule = me.assignWidget(self.img_center, "btn_rule")
    me.registGuiClickEvent(self.btn_rule, function(sender)
        showSimpleTips("竞猜次数与自身VIP等级有关，下个阶段会重置竞猜次数", sender)
    end)

    return true
end

--[[
	data 			-- 小组数据
	extraData 		-- 包含下注资源id、单注数量、剩余下注次数等信息
--]]
function PvpBetsView:setData(data, extraData)
	self.info = data
	self.extraInfo = extraData
	self:refreshView()
end

-- 刷新页面
function PvpBetsView:refreshView()
	self.text_turn:setString(string.format("%s %s 第%s场", PvpMainView.GroupName[self.extraInfo.group], PvpMainView.StageName[self.info.nid], self.info.session))
	self.text_time:setString(string.format("比赛时间：%s", me.GetSecTime(self.info.time)))
	for i, v in ipairs({self.img_attacker, self.img_defender}) do
		-- 空
		local img_empty = me.assignWidget(v, "img_empty")
		img_empty:setVisible(i == 1 and self.info.atacker == 0 or self.info.defender == 0)
		-- 底框
		local img_frame = me.assignWidget(v, "img_frame")
		img_frame:setVisible(i == 1 and self.info.atacker ~= 0 or self.info.defender ~= 0)
		-- 主城皮肤
		local img_skin = me.assignWidget(v, "img_skin")
		img_skin:ignoreContentAdaptWithSize(true)
		img_skin:setScale(0.25)
		img_skin:setVisible(i == 1 and self.info.atacker ~= 0 or self.info.defender ~= 0)
		if img_skin:isVisible() then
			if i == 1 then
				if self.info.atkAdornment == 0 then
					local cfgItem = cfg[CfgType.BUILDING][self.info.atkCenterId]
					img_skin:loadTexture(buildIcon(cfgItem), me.localType)
				else
					local cfgItem = cfg[CfgType.SKIN_STRENGTHEN][self.info.atkAdornment]
					img_skin:loadTexture("cityskin"..cfgItem.icon.."_1.png", me.localType)
				end
			else
				if self.info.defAdornment == 0 then
					local cfgItem = cfg[CfgType.BUILDING][self.info.defCenterId]
					img_skin:loadTexture(buildIcon(cfgItem), me.localType)
				else
					local cfgItem = cfg[CfgType.SKIN_STRENGTHEN][self.info.defAdornment]
					img_skin:loadTexture("cityskin"..cfgItem.icon.."_1.png", me.localType)
				end
			end
		end
        -- 玩家名
        local text_name = me.assignWidget(v, "text_name")
        text_name:setString(i == 1 and self.info.atkName or self.info.defName)
		-- 服务器名
		local text_server = me.assignWidget(v, "text_server")
		text_server:setString(i == 1 and self.info.atkServer or self.info.defServer)
		-- 战力
		local text_fap = me.assignWidget(v, "text_fap")
		text_fap:setString(string.format("战力:%s", i == 1 and self.info.atkFightPower or self.info.defFightPower))
		-- 身价
		local text_value = me.assignWidget(v, "text_value")
		text_value:setString(string.format("身价:%s", i == 1 and self.info.atkBet or self.info.defenBet))
		-- 赔率
		local text_odds = me.assignWidget(v, "text_odds")
		text_odds:setString(string.format("奖金:%s", i == 1 and self.info.atkPL or self.info.defenPL))
		-- 已下注
		local text_bets = me.assignWidget(v, "text_bets")
		text_bets:setString(string.format("已猜%s次", i == 1 and self.info.myAtkBet or self.info.myDefenBet))
		-- 下注
		local btn_bets = me.assignWidget(v, "btn_bets")
		me.registGuiClickEvent(btn_bets, function(sender)
    		NetMan:send(_MSG.pvp_bet(self.extraInfo.group, self.info.id, i, 1))
	    end)
	end
	-- 下注资源
	self.img_res:loadTexture(getItemIcon(self.extraInfo.betNeedId))
	self.text_num_single:setString(self.extraInfo.betPrice)
	self.text_num_left:setString(string.format("剩余竞猜次数：%s", self.extraInfo.betTimes))
end

function PvpBetsView:onEnter()
    print("PvpBetsView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpBetsView:onEnterTransitionDidFinish()
    print("PvpBetsView onEnterTransitionDidFinish")
end

function PvpBetsView:onExit()
    print("PvpBetsView onExit")
    UserModel:removeLisener(self.lisener)
end
