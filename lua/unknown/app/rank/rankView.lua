--[Comment]
--jnmo
rankView = class("rankView",function (...)
	local arg = {...}
	if table.getn(arg) == 1 then    
		return cc.CSLoader:createNode(arg[1])
		elseif table.getn(arg) == 2 then
--这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
return arg[1]:getChildByName(arg[2])
end
end)
rankView.__index = rankView
function rankView:create(...)
	local layer = rankView.new(...)
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
						end)            
			return layer
		end
	end
	return nil 
end
rankView.PERSONAL = 1 --个人排名
rankView.ALLIANCE = 2 --联盟排名
rankView.PLUNDER = 3 --战损排名
rankView.PVPSCORE = 4 --pvp积分排名
rankView.PROMITION_SINGLE = 5 --限时活动单项排名
rankView.PROMITION_TOTAL = 6 --限时活动总排名
rankView.PROMITION_HISTORY = 7 --限时活动历史排名
rankView.PROMITION_NEWYEAR = 8 -- 新春排名
rankView.PROMITION_NEWYEARTOTAL = 9 -- 新春总排名
rankView.PROMITION_MEDAL = 10 -- 武勋兑换排名
rankView.PROMITION_MEDALTOTAL = 11 -- 武勋兑换总排名
rankView.ACHIEVEMENT = 13 -- 成就排名
rankView.PAY_RANK = 14 --充值排行
rankView.COST_RANK = 15 ---消费排行
rankView.BOSS_ACT_FAMILY_RANK = 16 --流浪活动排行
rankView.HERO_LEVEL_RANK = 17 --英雄试炼
rankView.RESIST_INVASION_RANK = 19 --抵御蛮族积分排名
rankView.NET_PAY_RANK = 21 --跨服充值排名
rankView.NET_COST_RANK = 22 --跨服消费排名
rankView.NETBATTLE_PERSON = 101 --跨服个人排行榜
rankView.NETBATTLE_SERVER = 102 --跨服区服排行榜
rankView.DIGORE_SCORE_RANK = 201 --挖矿 积分排行榜
rankView.DIGORE_ENEMY_RANK = 202 --挖矿 仇敌排行榜

function rankView:ctor()   
	print("rankView ctor") 
	self.mMail = nil
	self.Blink_Bool = true
	self.BlinkTime = nil
end
function rankView:digoreGroud(gid)
    self.digoreGid=gid
end
function rankView:setRankRype(rankType)
	self.RankType = rankType
	if self.RankType == rankView.PROMITION_NEWYEAR or self.RankType == rankView.PROMITION_NEWYEARTOTAL then
		self:setNewYearType(rankView.PROMITION_NEWYEAR)
    elseif self.RankType == rankView.PROMITION_MEDAL or self.RankType == rankView.PROMITION_MEDALTOTAL then
        self:setNewYearType(rankView.PROMITION_MEDAL)
    elseif self.RankType == rankView.ACHIEVEMENT then
        self:setAchievementType(rankView.ACHIEVEMENT)
    elseif self.RankType == rankView.HERO_LEVEL_RANK then
        self:setHeroLevelType(rankView.HERO_LEVEL_RANK)
    elseif self.RankType == rankView.DIGORE_SCORE_RANK then
        self:setDigoreType(rankView.DIGORE_SCORE_RANK) 
    elseif self.RankType == rankView.DIGORE_ENEMY_RANK then
        self:setDigoreType(rankView.DIGORE_ENEMY_RANK)
    elseif self.RankType == rankView.RESIST_INVASION_RANK then
        self:setResistInvasionType(rankView.RESIST_INVASION_RANK)
    elseif self.RankType == rankView.NETBATTLE_PERSON or self.RankType == rankView.NETBATTLE_SERVER then
        self:setNetBattleType(self.RankType)
    end
end

function rankView:init()   
	print("rankView init")
	me.registGuiClickEventByName(self,"Button_cancel",function (node)
		self:close()     
    end) 
	me.assignWidget(self,"Panel_New_Year"):setVisible(false)
	self.mRankNum = 0
    self.btn_Peronal = me.registGuiClickEventByName(self,"Button_personal_create",function (node) -- 个人排名
	    self:setButton(self.btn_Peronal,false) 
	    self:setButton(self.btn_Alliance,true)  
	    self:setButton(self.btn_Plunder,true)  
	    self:setButton(self.btn_Score,true) 
	    self.RankType = rankView.PERSONAL           
	    self:setRankType()
    end)
    self.btn_Alliance = me.registGuiClickEventByName(self,"Button_alliance_list",function (node) -- 联盟排名
	    self:setButton(self.btn_Peronal,true) 
	    self:setButton(self.btn_Alliance,false) 
	    self:setButton(self.btn_Plunder,true) 
	    self:setButton(self.btn_Score,true)          
	    self.RankType = rankView.ALLIANCE 
	    --if table.maxn(user.rankAlliancedata) == 0 then
		    NetMan:send(_MSG.rankList(rankView.ALLIANCE ))
--	    else
--		    self:setRankType() 
--	    end                              
	    end)
    self.btn_Plunder = me.registGuiClickEventByName(self,"Button_alliance_plunder",function (node) -- 战损排名
	    self:setButton(self.btn_Peronal,true) 
	    self:setButton(self.btn_Alliance,true)   
	    self:setButton(self.btn_Plunder,false)   
	    self:setButton(self.btn_Score,true)
	    self.RankType = rankView.PLUNDER 
	    if table.maxn(user.plunderData) == 0 then
		    NetMan:send(_MSG.rankList(rankView.PLUNDER ))
	    else
		    self:setRankType() 
	    end                              
    end)

    self.btn_Score = me.registGuiClickEventByName(self,"Button_PVP_Score",function (node) -- 积分排名
	    self:setButton(self.btn_Peronal,true) 
	    self:setButton(self.btn_Alliance,true)   
	    self:setButton(self.btn_Plunder,true)
	    self:setButton(self.btn_Score,false)      
	    self.RankType = rankView.PVPSCORE 
	    --if table.maxn(user.scoreData) == 0 then
		    NetMan:send(_MSG.rankList(rankView.PVPSCORE ))
	    --else
		--    self:setRankType() 
	    --end                              
    end)

    self.btn_SelfArea = me.registGuiClickEventByName(self,"Button_self_area",function (node) -- 本区排名
	    self:setButton(self.btn_SelfArea,false) 
	    self:setButton(self.btn_AllArea,true)  
	    self.RankType = rankView.HERO_LEVEL_RANK           
	    NetMan:send(_MSG.rankList(17))
    end)
    self.btn_AllArea = me.registGuiClickEventByName(self,"Button_all_area",function (node) -- 全区排名
	    self:setButton(self.btn_SelfArea,true) 
	    self:setButton(self.btn_AllArea,false) 
	    self.RankType = rankView.HERO_LEVEL_RANK           
	    NetMan:send(_MSG.rankList(18))
    end)

    self.btn_Tian = me.registGuiClickEventByName(self,"Button_digore_tian",function (node) -- 挖矿 天榜
	    self:setButton(self.btn_Tian,false) 
	    self:setButton(self.btn_Di,true)  
        self:setButton(self.btn_Ren,true) 
	    self.RankType = rankView.DIGORE_SCORE_RANK    
	    NetMan:send(_MSG.digoreRank(1, 103))
    end)
    self.btn_Di = me.registGuiClickEventByName(self,"Button_digore_di",function (node) -- 挖矿 地榜
	    self:setButton(self.btn_Tian,true) 
	    self:setButton(self.btn_Di,false)  
        self:setButton(self.btn_Ren,true)
	    self.RankType = rankView.DIGORE_SCORE_RANK           
	    NetMan:send(_MSG.digoreRank(2, 103))
    end)
    self.btn_Ren = me.registGuiClickEventByName(self,"Button_digore_ren",function (node) -- 挖矿 人榜
	    self:setButton(self.btn_Tian,true) 
	    self:setButton(self.btn_Di,true)  
        self:setButton(self.btn_Ren,false) 
	    self.RankType = rankView.DIGORE_SCORE_RANK           
	    NetMan:send(_MSG.digoreRank(3, 103))
    end)

    self.btn_Enemy1 = me.registGuiClickEventByName(self,"Button_digore_enemy1",function (node) -- 挖矿 个人仇敌
	    self:setButton(self.btn_Enemy1,false) 
	    self:setButton(self.btn_Enemy2,true)  
	    self.RankType = rankView.DIGORE_ENEMY_RANK           
        me.assignWidget(me.assignWidget(self,"digore_enemybg"), "Text_25"):setString("攻击自己次数")
	    NetMan:send(_MSG.digoreRank(self.digoreGid, 105))
    end)

    self.btn_Enemy2 = me.registGuiClickEventByName(self,"Button_digore_enemy2",function (node) -- 挖矿 全民公敌
	    self:setButton(self.btn_Enemy1,true) 
	    self:setButton(self.btn_Enemy2,false)
	    self.RankType = rankView.DIGORE_ENEMY_RANK          
        me.assignWidget(me.assignWidget(self,"digore_enemybg"), "Text_25"):setString("总战斗次数") 
	    NetMan:send(_MSG.digoreRank(self.digoreGid, 104))
    end)

    self.Button_NetBattle_Person = me.registGuiClickEventByName(self,"Button_NetBattle_Person",function (node) -- 跨服个人积分
	    self:setButton(self.Button_NetBattle_Person,false) 
	    self:setButton(self.Button_NetBattle_Server,true)  
	    self.RankType = rankView.NETBATTLE_PERSON           
	    NetMan:send(_MSG.rankList(self.RankType))
    end)
    self.Button_NetBattle_Server = me.registGuiClickEventByName(self,"Button_NetBattle_Server",function (node) -- 跨服区服积分
	    self:setButton(self.Button_NetBattle_Person,true) 
	    self:setButton(self.Button_NetBattle_Server,false) 
	    self.RankType = rankView.NETBATTLE_SERVER          
	    NetMan:send(_MSG.rankList(self.RankType))
    end)
    me.registGuiClickEventByName(self,"Button_Activity_Reward",function ()
	    NetMan:send(_MSG.CheckActivity_Limit_Reward(self.activityRewardType))
    end)

    me.registGuiClickEventByName(self,"rank_onself_Btn",function (node)
	    if self.Blink_Bool then             
		    if self.mRankNum ~= 0 then
			    self:setTableOffset(self.mRankNum)
			    self:pitchcellhint()
			    self.Blink_Bool = false
		    end
	    end        
    end)  

    me.registGuiClickEventByName(self,"rank_allian_Btn",function (node)
	    if self.Blink_Bool then             
		    if self.mRankNum ~= 0 then
			    self:setTableOffset(self.mRankNum)
			    self:pitchcellhint()
			    self.Blink_Bool = false
		    end        
	    end       
    end) 
    return true
end

function rankView:setAchievementType(currentType)
	me.assignWidget(self,"Button_total_score"):setVisible(false)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_alliance_plunder"):setVisible(false)
    self:setButton(self.btn_Peronal,false) 
    self.RankType = currentType 
    self.btn_Peronal:setVisible(true)
    me.assignWidget(self.btn_Peronal, "Text_title"):setString("积分排名")
end

function rankView:setHeroLevelType(currentType)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_personal_create"):setVisible(false)

    me.assignWidget(self,"Button_self_area"):setVisible(true)
    me.assignWidget(self,"Button_all_area"):setVisible(true)

    self.RankType = currentType 
end
function rankView:setDigoreType(currentType)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_personal_create"):setVisible(false)

    if currentType==rankView.DIGORE_SCORE_RANK then
        me.assignWidget(self,"Button_digore_tian"):setVisible(true)
        me.assignWidget(self,"Button_digore_ren"):setVisible(true)
        me.assignWidget(self,"Button_digore_di"):setVisible(true)
    elseif currentType==rankView.DIGORE_ENEMY_RANK then
        me.assignWidget(self,"Button_digore_enemy1"):setVisible(true)
        me.assignWidget(self,"Button_digore_enemy2"):setVisible(true)
    end
    self.RankType = currentType 
end

function rankView:setNetBattleType(currentType)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_personal_create"):setVisible(false)
    self:setButton(self.Button_NetBattle_Person,false) 
    self.Button_NetBattle_Person:setVisible(true)
    self:setButton(self.Button_NetBattle_Server,true)  
    self.Button_NetBattle_Server:setVisible(true)
    self.RankType = currentType 
end

function rankView:setResistInvasionType(currentType)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_personal_create"):setVisible(false)
    self.RankType = currentType 
end


function rankView:setNewYearType(currentType)
	me.assignWidget(self,"Button_personal_create"):setVisible(false)
	me.assignWidget(self,"Button_alliance_list"):setVisible(false)
	me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
	me.assignWidget(self,"Button_alliance_plunder"):setVisible(false)
	me.assignWidget(self,"Panel_New_Year"):setVisible(true)
    self.poper_score = me.registGuiClickEventByName(self,"Button_poper_score",function (node) -- 联盟排名
	    self:setButton(self.total_score,true) 
	    self:setButton(self.poper_score,false) 
	    self.RankType = currentType 
	    if table.maxn(user.rankAlliancedata) == 0 then
		    NetMan:send(_MSG.rankList(self.RankType ))
	    else
		    self:setRankType() 
	    end                              
    end)

    self.total_score = me.registGuiClickEventByName(self,"Button_total_score",function (node) -- 战损排名
	    self:setButton(self.total_score,false) 
	    self:setButton(self.poper_score,true) 
	    if self.RankType == rankView.PROMITION_NEWYEAR then
		    self.RankType = rankView.PROMITION_NEWYEARTOTAL 
        elseif self.RankType == rankView.PROMITION_MEDAL then
			    self.RankType = rankView.PROMITION_MEDALTOTAL 
        end
		if table.maxn(user.plunderData) == 0 then
			NetMan:send(_MSG.rankList(self.RankType ))
		else
            self:setRankType() 
        end                              
    end)
    me.registGuiClickEventByName(self,"Button_Activity_NewYear_Reward",function ()
        if self.RankType == rankView.PROMITION_NEWYEAR or self.RankType == rankView.PROMITION_NEWYEARTOTAL then
	        NetMan:send(_MSG.CheckActivity_Limit_Reward(NewYearReawrd.singleNewYearRewardType))
	    elseif self.RankType == rankView.PROMITION_MEDAL or self.RankType == rankView.PROMITION_MEDALTOTAL then
		    NetMan:send(_MSG.CheckActivity_Limit_Reward(NewYearReawrd.singleDragonBoatType))
	    end
    end)
end

function rankView:ParentNode(pNode)
	self.pPerantNode = pNode
end


function rankView:setButton(button,b)
	button:setBright(b)
	local title = me.assignWidget(button,"Text_title")
	if b then
		title:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))     
        title:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))   
	else
		title:setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
        title:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))  
	end
	button:setSwallowTouches(true)
	button:setTouchEnabled(b)
end

function rankView:setRankType()
    if self.RankType == rankView.PERSONAL then  -- 个人排名               
	    me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(true)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
	    me.assignWidget(self,"table_node"):removeAllChildren()
	    local pData = user.rankdata
--	    dump(pData)
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end
	    self:setRanHint()
    elseif self.RankType == rankView.ALLIANCE then -- 联盟排名
	    me.assignWidget(self,"table_node"):removeAllChildren() 
	    me.assignWidget(self,"alliance_bg"):setVisible(true)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
	    local pData = user.rankAlliancedata
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end
	    self:setRanHint()
    elseif self.RankType == rankView.PLUNDER then -- 战损排名
	    me.assignWidget(self,"table_node"):removeAllChildren() 
	    me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(true)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)

	    local pData = user.plunderData
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end 
	    self:setRanHint()
    elseif self.RankType == rankView.PVPSCORE then -- 积分排名
	    me.assignWidget(self,"table_node"):removeAllChildren() 
	    me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(true)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)

	    local pData = user.scoreData
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end 
	    self:setRanHint()
    elseif self.RankType == rankView.NETBATTLE_PERSON then
        me.assignWidget(self,"table_node"):removeAllChildren() 
	    me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"netbattle_person"):setVisible(true)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
        me.assignWidget(self,"netbattle_server"):setVisible(false)    
	    local pData = user.netPersonRankList
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end 
	    self:setRanHint()
    elseif self.RankType == rankView.NETBATTLE_SERVER then
        me.assignWidget(self,"table_node"):removeAllChildren() 
	    me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"netbattle_person"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
        me.assignWidget(self,"netbattle_server"):setVisible(true)        
	    local pData = user.netServerRankList
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end 
	    self:setRanHint()
	elseif self.RankType == rankView.PROMITION_SINGLE then 
		self.activityRewardType = 1
		me.assignWidget(self,"table_node"):removeAllChildren() 
		me.assignWidget(self,"alliance_bg"):setVisible(false)
		me.assignWidget(self,"personal_bg"):setVisible(false)
		me.assignWidget(self,"score_bg"):setVisible(false)
		me.assignWidget(self,"plunder_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)

		local activity_bg = me.assignWidget(self,"activity_bg")
		activity_bg:setVisible(true)
		me.assignWidget(self,"Button_personal_create"):setVisible(false)
		me.assignWidget(self,"Button_alliance_list"):setVisible(false)
		me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
		me.assignWidget(self,"Button_alliance_plunder"):setVisible(false)
		me.assignWidget(self,"Button_Activity_Reward"):setVisible(true)
        me.assignWidget(self,"area_bg"):setVisible(false)
		me.assignWidget(self,"Text_Reward_describe"):setString("排名奖励将在阶段结束时以邮件形式发放")
		me.assignWidget(self,"alliance_title"):setString("阶段排名")
		me.assignWidget(activity_bg,"Text_activityScore"):setString("阶段积分")
		local pData = user.promotin_LimitList
--		dump(pData)
		if table.maxn(pData) ~= 0 then
			self:initInfoTab(pData)
		end 
		self:setRanHint()
    elseif self.RankType == rankView.PROMITION_TOTAL then 
		self.activityRewardType = 2
		me.assignWidget(self,"table_node"):removeAllChildren() 
		me.assignWidget(self,"alliance_bg"):setVisible(false)
		me.assignWidget(self,"personal_bg"):setVisible(false)
		me.assignWidget(self,"score_bg"):setVisible(false)
		me.assignWidget(self,"plunder_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
		local activity_bg = me.assignWidget(self,"activity_bg")
		activity_bg:setVisible(true)
		me.assignWidget(self,"Button_personal_create"):setVisible(false)
		me.assignWidget(self,"Button_alliance_list"):setVisible(false)
		me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
		me.assignWidget(self,"Button_alliance_plunder"):setVisible(false)
		me.assignWidget(self,"Button_Activity_Reward"):setVisible(true)
		me.assignWidget(self,"Text_Reward_describe"):setString("排名奖励将在本次活动结束时以邮件形式发放")
		me.assignWidget(self,"alliance_title"):setString("总排名")
		me.assignWidget(activity_bg,"Text_activityScore"):setString("总积分")
		local pData = user.promotin_LimitList
		if table.maxn(pData) ~= 0 then
			self:initInfoTab(pData)
		end 
		self:setRanHint()
    elseif self.RankType == rankView.PROMITION_HISTORY then       
		me.assignWidget(self,"table_node"):removeAllChildren() 
		me.assignWidget(self,"alliance_bg"):setVisible(false)
		me.assignWidget(self,"personal_bg"):setVisible(false)
		me.assignWidget(self,"score_bg"):setVisible(false)
		me.assignWidget(self,"plunder_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
		local activity_bg = me.assignWidget(self,"activity_bg")
		activity_bg:setVisible(true)
		me.assignWidget(self,"Button_personal_create"):setVisible(false)
		me.assignWidget(self,"Button_alliance_list"):setVisible(false)
		me.assignWidget(self,"Button_PVP_Score"):setVisible(false)
		me.assignWidget(self,"Button_alliance_plunder"):setVisible(false)
		me.assignWidget(self,"Button_Activity_Reward"):setVisible(false)
		me.assignWidget(self,"alliance_title"):setString("历史排名")
		me.assignWidget(activity_bg,"Text_activityScore"):setString("历史积分")
		local pData = user.promotin_LimitList
--		dump(pData)
		if table.maxn(pData) ~= 0 then
			self:initInfoTab(pData)
		end 
		self:setRanHint()
    elseif self.RankType == rankView.PROMITION_NEWYEAR or 
    self.RankType == rankView.PROMITION_NEWYEARTOTAL or 
    self.RankType == rankView.PROMITION_MEDAL or 
    self.RankType == rankView.PROMITION_MEDALTOTAL then       
		me.assignWidget(self,"table_node"):removeAllChildren() 
		me.assignWidget(self,"alliance_bg"):setVisible(false)
		me.assignWidget(self,"personal_bg"):setVisible(false)
		me.assignWidget(self,"score_bg"):setVisible(false)
		me.assignWidget(self,"plunder_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(false)
		local activity_bg = me.assignWidget(self,"activity_New_Year_bg")
		activity_bg:setVisible(true)
        if self.RankType == rankView.PROMITION_NEWYEAR or self.RankType == rankView.PROMITION_MEDAL then
            me.assignWidget(self,"Text_New_activityScore"):setString("积分")
        else
            me.assignWidget(self,"Text_New_activityScore"):setString("总积分")
        end               
        local pData = user.promotin_LimitList  
	    if table.maxn(pData) ~= 0 then
		    self:initInfoTab(pData)
	    end 
	    self:setRanHint()
    elseif self.RankType == rankView.ACHIEVEMENT then --成就排行榜
        local bg = me.assignWidget(self,"personal_bg"):setVisible(true)
        me.assignWidget(bg,"Text_26"):setString("战斗力")
        me.assignWidget(bg,"Text_27"):setString("成就积分")
		local pData = user.AScoreData  
--		dump(pData)
		if table.maxn(pData) ~= 0 then
			self:initInfoTab(pData)
		end 
		self:setRanHint()
    elseif self.RankType == rankView.HERO_LEVEL_RANK then
        me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"area_bg"):setVisible(true)
	    me.assignWidget(self,"table_node"):removeAllChildren()
        me.assignWidget(self,"alliance_title"):setString("征服排名")
--	    dump(pData)
        self.mNum = 0
	    if self.areaRankData and table.maxn(self.areaRankData) ~= 0 then
		    self:initInfoTab(self.areaRankData)
	    end
	    self:setRanHint()
    elseif self.RankType == rankView.DIGORE_SCORE_RANK then
        me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"digore_scorebg"):setVisible(true)
	    me.assignWidget(self,"table_node"):removeAllChildren()
        me.assignWidget(self,"alliance_title"):setString("积分排名")
--	    dump(pData)
        self.mNum = 0
	    if self.digoreScoreRankData and table.maxn(self.digoreScoreRankData) ~= 0 then
		    self:initInfoTab(self.digoreScoreRankData)
	    end
	    self:setRanHint()
    elseif self.RankType == rankView.DIGORE_ENEMY_RANK then
        me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"digore_enemybg"):setVisible(true)
	    me.assignWidget(self,"table_node"):removeAllChildren()
        me.assignWidget(self,"alliance_title"):setString("仇敌排名")
--	    dump(pData)
        self.mNum = 0
	    if self.digoreEnemyRankData and table.maxn(self.digoreEnemyRankData) ~= 0 then
		    self:initInfoTab(self.digoreEnemyRankData)
	    end
	    self:setRanHint()
    elseif self.RankType == rankView.RESIST_INVASION_RANK then
        me.assignWidget(self,"alliance_bg"):setVisible(false)
	    me.assignWidget(self,"personal_bg"):setVisible(false)
	    me.assignWidget(self,"plunder_bg"):setVisible(false)
	    me.assignWidget(self,"score_bg"):setVisible(false)
	    me.assignWidget(self,"activity_bg"):setVisible(false)
        me.assignWidget(self,"resist_bg"):setVisible(true)
	    me.assignWidget(self,"table_node"):removeAllChildren()
        me.assignWidget(self,"alliance_title"):setString("积分排名")
--	    dump(pData)
        self.mNum = 0
	    if self.resistRankData and table.maxn(self.resistRankData) ~= 0 then
		    self:initInfoTab(self.resistRankData)
	    end
	    self:setRanHint()
    end
end

function rankView:setRanHint()
    self.mRankNum = 0
    if self.RankType == rankView.PERSONAL then  -- 个人排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = user.rankdata
--        dump(pData)
	    if table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if var["uid"] == user.uid then
				    rankNum = var["rank"]
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
    elseif self.RankType == rankView.NETBATTLE_PERSON then  -- 个人排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = user.netPersonRankList
--        dump(pData)
	    if table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if var["uid"] == user.uid then
				    rankNum = var["rank"]
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
    elseif self.RankType== rankView.NETBATTLE_SERVER then 
           me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)
		    me.assignWidget(self,"rank_not"):setVisible(false)
    elseif self.RankType == rankView.HERO_LEVEL_RANK then  -- 试炼排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = self.areaRankData
--        dump(pData)
	    if self.areaRankData and table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if tonumber(var.item[1]) == user.uid then
				    rankNum = key
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
    elseif self.RankType == rankView.DIGORE_SCORE_RANK then  -- 挖矿 积分排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = self.digoreScoreRankData
--        dump(pData)
	    if self.digoreScoreRankData and table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if tonumber(var.item[1]) == user.uid then
				    rankNum = key
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end

        local txt= me.assignWidget(self, "digore_score_txt")
        
        if self.digoreScoreData and self.digoreScoreData.inGroup==true then
            txt:setVisible(true)
            txt:setString("我的积分 "..self.digoreScoreData.value)
        else
            txt:setVisible(false)
            txt:setString("我的积分 0")
            me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)
		    me.assignWidget(self,"rank_not"):setVisible(false)
        end
    elseif self.RankType == rankView.DIGORE_ENEMY_RANK then  -- 挖矿 仇敌排名
        me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = self.digoreEnemyRankData
--        dump(pData)
	    if self.digoreEnemyRankData and table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if tonumber(var.item[1]) == user.uid then
				    rankNum = key
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end

        local txt= me.assignWidget(self, "digore_score_txt")
        
        if self.digoreEnemyData and self.digoreEnemyData.inGroup==true then
            txt:setVisible(true)
            txt:setString("我的罪恶值 "..self.digoreEnemyData.value)
        else
            txt:setVisible(false)
            txt:setString("我的罪恶值 0")
            me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)
		    me.assignWidget(self,"rank_not"):setVisible(false)
        end
    elseif self.RankType == rankView.RESIST_INVASION_RANK then  -- 抵御蛮族积分排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = self.resistRankData
--        dump(pData)
	    if self.resistRankData and table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if tonumber(var.item[1]) == user.uid then
				    rankNum = key
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
    elseif  self.RankType == rankView.ACHIEVEMENT then --成就排行榜
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = user.AScoreData
	    if table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if var["uid"] == user.uid then
				    rankNum = var["rank"]
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
    elseif self.RankType == rankView.ALLIANCE then -- 联盟排名 
	    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
	    local rankNum = 0
	    if user.familyUid ~= 0  then                
		    local pData = user.rankAlliancedata
		    if table.maxn(pData) ~= 0 then
			    for key, var in pairs(pData) do
				    if var["uid"] == user.familyUid then
					    rankNum = var["rank"]
					    break
				    end
			    end   
		    end
		    self.mRankNum = rankNum           
		    if rankNum ~= 0 then
			    me.assignWidget(self,"rank_allian_Btn"):setVisible(true)
			    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
			    me.assignWidget(self,"rank_not_bg"):setVisible(false)
			    self:setPointpitch(rankNum,self.mNum)     
		    else
			    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
			    me.assignWidget(self,"Rank_num"):setVisible(false)
			    me.assignWidget(self,"rank_not_bg"):setVisible(true)
			    me.assignWidget(self,"rank_not"):setVisible(true)
			    me.assignWidget(self,"rank_not"):setString("未上榜")
    -- showTips("未上榜")
            end
        else
	        me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	        me.assignWidget(self,"Rank_num"):setVisible(false)
	        me.assignWidget(self,"rank_not_bg"):setVisible(true)
	        me.assignWidget(self,"rank_not"):setVisible(true)
	        me.assignWidget(self,"rank_not"):setString("未加入联盟")
        end 
    elseif self.RankType == rankView.PLUNDER then -- 战损排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    me.assignWidget(self,"Rank_num"):setVisible(false)
	    me.assignWidget(self,"rank_not_bg"):setVisible(false)
	    me.assignWidget(self,"rank_not"):setVisible(false)    
	    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
    elseif self.RankType == rankView.PVPSCORE then -- 积分排名
	    me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	    local rankNum = 0
	    local pData = user.scoreData
	    if table.maxn(pData) ~= 0 then
		    for key, var in pairs(pData) do
			    if var["uid"] == user.uid then
				    rankNum = var["rank"]
				    break
			    end
		    end   
	    end  
	    self.mRankNum = rankNum
	    if rankNum ~= 0 then
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
		    me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
		    me.assignWidget(self,"rank_not_bg"):setVisible(false)             
		    self:setPointpitch(rankNum,self.mNum)         
	    else
		    me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
		    me.assignWidget(self,"Rank_num"):setVisible(false)
		    me.assignWidget(self,"rank_not_bg"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setVisible(true)
		    me.assignWidget(self,"rank_not"):setString("未上榜")
	    end
	elseif self.RankType == rankView.PROMITION_SINGLE or
		self.RankType == rankView.PROMITION_TOTAL or
		self.RankType == rankView.PROMITION_HISTORY or
		self.RankType == rankView.PROMITION_NEWYEAR or 
		self.RankType == rankView.PROMITION_NEWYEARTOTAL or   
		self.RankType == rankView.PROMITION_MEDAL or 
		self.RankType == rankView.PROMITION_MEDALTOTAL then   
		me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
		local rankNum = 0
		local pData = user.promotin_LimitList
		if table.maxn(pData) ~= 0 then
			for key, var in pairs(pData) do
				if me.toNum(var["uid"]) == user.uid then
					rankNum = var["index"]
					break
				end
			end   
		end  
		self.mRankNum = rankNum
		if rankNum ~= 0 then
			me.assignWidget(self,"rank_onself_Btn"):setVisible(true)
			me.assignWidget(self,"Rank_num"):setString(rankNum):setVisible(true)
			me.assignWidget(self,"rank_not_bg"):setVisible(false)             
			self:setPointpitch(rankNum,self.mNum)         
		else
			me.assignWidget(self,"rank_onself_Btn"):setVisible(false)
			me.assignWidget(self,"Rank_num"):setVisible(false)
			me.assignWidget(self,"rank_not_bg"):setVisible(true)
			me.assignWidget(self,"rank_not"):setVisible(true)
			me.assignWidget(self,"rank_not"):setString("未上榜")
		end
	end   
end
function rankView:initInfoTab(pInfoTab)  
	local iNum  =  math.min(300,#pInfoTab)
	self.mNum = iNum 
    local function tableCellTouched(table, cell)
	    if self.RankType == rankView.PERSONAL or self.RankType == rankView.PLUNDER then  -- 个人排名
		    local pId = cell:getIdx()
		    local pData = pInfoTab[pId+1]
		    if pData["uid"] ~= user.uid then
			    NetMan:send(_MSG.roleInfor(pData["uid"]))
			    showWaitLayer() 
		    end          
	    elseif self.RankType == rankView.ALLIANCE then -- 联名排名 
		    local pId = cell:getIdx()
		    local pData = pInfoTab[pId+1]
		    if pData["uid"] ~= user.familyUid then
			    NetMan:send(_MSG.rankallianceInfor(pData["uid"])) 
			    showWaitLayer()
		    end                        
	    end
    end

    local function cellSizeForTable(table, idx)
	    return 1160, 61
    end

    local function tableCellAtIndex(table, idx)
         print("self.RankType = "..self.RankType)
        local cell = table:dequeueCell()        
        if nil == cell then
            print(" nil == cell !!!!!!")
	        cell = cc.TableViewCell:new()
	        local pRankCell = nil
            if self.RankType == rankView.PLUNDER then -- 战损排名 
	            pRankCell = RankCell:create(self,"plunder_cell")
            elseif self.RankType == rankView.PROMITION_TOTAL or 
		        self.RankType == rankView.PROMITION_HISTORY or 
		        self.RankType == rankView.PROMITION_SINGLE or
		        self.RankType == rankView.PROMITION_NEWYEAR or
		        self.RankType == rankView.PROMITION_NEWYEARTOTAL or
		        self.RankType == rankView.PROMITION_MEDAL or 
		        self.RankType == rankView.PROMITION_MEDALTOTAL then
		        pRankCell = RankCell:create(self,"activity_cell")
		        pRankCell:setActivityData(pInfoTab[idx+1],idx+1)
            elseif self.RankType == rankView.HERO_LEVEL_RANK then
                pRankCell = RankCell:create(self,"area_cell")
            elseif self.RankType == rankView.DIGORE_SCORE_RANK then
                pRankCell = RankCell:create(self,"digore_scorecell")
            elseif self.RankType == rankView.DIGORE_ENEMY_RANK then
                pRankCell = RankCell:create(self,"digore_enemycell")
            elseif self.RankType == rankView.RESIST_INVASION_RANK then
                pRankCell = RankCell:create(self,"resist_cell")
            elseif self.RankType == rankView.NETBATTLE_PERSON then
                pRankCell = RankCell:create(self,"netbattle_cell_person")
            elseif self.RankType == rankView.NETBATTLE_SERVER then
                pRankCell = RankCell:create(self,"netbattle_cell_server")
            else
		        pRankCell = RankCell:create(self,"rank_cell")
            end
	        pRankCell:setAnchorPoint(cc.p(0,0))
	        pRankCell:setPosition(cc.p(0,0))
            if self.RankType == rankView.PERSONAL then  -- 个人排名
	            pRankCell:setPeronalData(pInfoTab[idx+1])
            elseif self.RankType == rankView.ALLIANCE then -- 联名排名 
	            pRankCell:setAllianceData(pInfoTab[idx+1])
            elseif self.RankType == rankView.HERO_LEVEL_RANK then -- 英雄试炼 
	            pRankCell:setHeroLevelData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.DIGORE_SCORE_RANK then -- 挖矿积分排名 
	            pRankCell:setDigoreScoreData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.DIGORE_ENEMY_RANK then -- 挖矿积分排名 
	            pRankCell:setDigoreEnemyData(idx+1, pInfoTab[idx+1], self)
            elseif self.RankType == rankView.RESIST_INVASION_RANK then -- 抵御蛮族 
	            pRankCell:setResistData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.NETBATTLE_PERSON then
                pRankCell:setNetBattlePerson(pInfoTab[idx+1])
            elseif self.RankType == rankView.NETBATTLE_SERVER then
                pRankCell:setNetBattleServer(pInfoTab[idx+1])
            elseif self.RankType == rankView.PLUNDER then -- 战损排名 
	            pRankCell:setplunder(pInfoTab[idx+1])
	            local pButtonPoint = me.assignWidget(pRankCell, "Button_point")
	            pButtonPoint:setTag(idx + 1)
	            me.registGuiClickEvent(pButtonPoint, function(node)                   
		            local pIndx = me.toNum(node:getTag())
		            local pData = pInfoTab[pIndx]
		            local pX = pData["x"]
		            local pY = pData["y"]
		            self:setLookMap(cc.p(pX,pY))                    
		            end )
	            pButtonPoint:setSwallowTouches(true)            
            elseif self.RankType == rankView.PVPSCORE then -- 积分排名 
	            pRankCell:setScore(pInfoTab[idx+1])
            elseif self.RankType == rankView.ACHIEVEMENT then -- 成就积分排名
	            pRankCell:setScore_Achievement(pInfoTab[idx+1])
            end             
            if idx %2 == 0 then 
                 pRankCell:loadTexture("default.png",me.localType)
            else
                 pRankCell:loadTexture("alliance_cell_bg1.png",me.localType)
            end
            cell:addChild(pRankCell)                                 
        else
	        local pRankCell = nil
            if self.RankType == rankView.PLUNDER then -- 战损排名 
	            pRankCell = me.assignWidget(cell,"plunder_cell") 
            elseif self.RankType == rankView.HERO_LEVEL_RANK then -- 英雄试炼  
	            pRankCell = me.assignWidget(cell,"area_cell")  
            elseif self.RankType == rankView.DIGORE_SCORE_RANK then -- 挖矿 积分排行
	            pRankCell = me.assignWidget(cell,"digore_scorecell")
            elseif self.RankType == rankView.DIGORE_ENEMY_RANK then -- 挖矿 积分排行
	            pRankCell = me.assignWidget(cell,"digore_enemycell")
            elseif self.RankType == rankView.RESIST_INVASION_RANK then-- 抵御蛮族 
                pRankCell = me.assignWidget(cell,"resist_cell")     
            elseif self.RankType == rankView.NETBATTLE_PERSON then
                pRankCell = me.assignWidget(cell,"netbattle_cell_person")
            elseif self.RankType == rankView.NETBATTLE_SERVER then
                pRankCell = me.assignWidget(cell,"netbattle_cell_server")         
            else
	            pRankCell = me.assignWidget(cell,"rank_cell")
            end
            if self.RankType == rankView.PERSONAL then  -- 个人排名
	            pRankCell:setPeronalData(pInfoTab[idx+1])
            elseif self.RankType == rankView.ALLIANCE then -- 联名排名 
	            pRankCell:setAllianceData(pInfoTab[idx+1])
            elseif self.RankType == rankView.HERO_LEVEL_RANK then -- 英雄试炼 
	            pRankCell:setHeroLevelData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.DIGORE_SCORE_RANK then -- 挖矿 积分排行
	            pRankCell:setDigoreScoreData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.DIGORE_ENEMY_RANK then -- 挖矿 积分排行
	            pRankCell:setDigoreEnemyData(idx+1, pInfoTab[idx+1], self)        
            elseif self.RankType == rankView.RESIST_INVASION_RANK then -- 抵御蛮族 
	            pRankCell:setResistData(idx+1, pInfoTab[idx+1])
            elseif self.RankType == rankView.PLUNDER then -- 战损排名 
	            pRankCell:setplunder(pInfoTab[idx+1])
	            local pButtonPoint = me.assignWidget(pRankCell, "Button_point")
	            pButtonPoint:setTag(idx + 1)
            elseif self.RankType == rankView.PVPSCORE then -- 积分排名 
	            pRankCell:setScore(pInfoTab[idx+1])
            elseif self.RankType == rankView.PROMITION_TOTAL or 
		        self.RankType == rankView.PROMITION_HISTORY or 
		        self.RankType == rankView.PROMITION_SINGLE  or  
		        self.RankType == rankView.PROMITION_NEWYEAR or
                self.RankType == rankView.PROMITION_NEWYEARTOTAL or  -- 限时活动排名 
                self.RankType == rankView.PROMITION_MEDAL or 
                self.RankType == rankView.PROMITION_MEDALTOTAL then
                pRankCell = me.assignWidget(cell,"activity_cell")
                pRankCell:setActivityData(pInfoTab[idx+1],idx+1)
            elseif self.RankType == rankView.ACHIEVEMENT then -- 成就积分排名
	            pRankCell:setScore_Achievement(pInfoTab[idx+1])
            elseif self.RankType == rankView.NETBATTLE_PERSON then
                pRankCell:setNetBattlePerson(pInfoTab[idx+1])
            elseif self.RankType == rankView.NETBATTLE_SERVER then
                pRankCell:setNetBattleServer(pInfoTab[idx+1])
            end 
            if idx %2 == 0 then 
                 pRankCell:loadTexture("default.png",me.localType)
            else
                 pRankCell:loadTexture("alliance_cell_bg1.png",me.localType)
            end
        end  
        return cell
    end

    function numberOfCellsInTableView(table)       
	    return iNum
    end
    local tableView = cc.TableView:create(cc.size(1167,498))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    me.assignWidget(self,"table_node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()     
    self.tableView = tableView
end

function rankView:setTableOffset(pIdx)
	if pIdx < 5 then
		self.tableView:setContentOffset(cc.p(0,-(self.mNum*61 - 498)))
    elseif pIdx > 296 then 
		self.tableView:reloadData()
		self.tableView:setContentOffset(cc.p(0,0))
    else
        if (self.mNum-3-pIdx) < 0 then
			self.tableView:reloadData()
			self.tableView:setContentOffset(cc.p(0,0))
        else
			self.tableView:reloadData()
			self.tableView:setContentOffset(cc.p(0,-(self.mNum-3-pIdx)*61))
        end
    end
end

function rankView:setPointpitch(pTag,pTabNum)
	pTag = me.toNum(pTag)
	local pPointX =  580
	local pPointY = (pTabNum- pTag+1)*61-35
	self.pPitchHint = me.assignWidget(self,"Image_mine"):clone()         
	self.pPitchHint:setVisible(true)
	self.pPitchHint:setPosition(cc.p(pPointX,pPointY))
	self.pPitchHint:setLocalZOrder(10)
	self.tableView:addChild(self.pPitchHint)
end

function rankView:pitchcellhint()
	self.pPitchHint:stopAllActions()
	local a5 = cc.Blink:create(0.9,2)
	self.pPitchHint:runAction(a5)
	self.BlinkTime =  me.registTimer(2, function(dt) 
		self.Blink_Bool = true
	end,1.2)  
end

-- 个人信息界面 
function rankView:popupInfoView(pData)
	if pData then
		if self.layout == nil then
			self.layout = ccui.Layout:create() 
			self.layout:setContentSize(cc.size(me.winSize.width,me.winSize.height))
			self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
			self.layout:setAnchorPoint(cc.p(0,0))
			self.layout:setPosition(cc.p(0,0))
			self.layout:setSwallowTouches(true)  
			self.layout:setTouchEnabled(true)
			self:addChild(self.layout,me.MAXZORDER)
		end
		self.mRoleData = pData
		local info = me.assignWidget(self, "Panel_Info"):clone()
		info:setTouchEnabled(true)
		info:setSwallowTouches(true)
		self.layout:addChild(info)
		info:setVisible(true)
		info:setAnchorPoint(cc.p(0.5,0.5))
		info:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))
		me.assignWidget(info,"Text_name"):setString(pData["name"])
		me.assignWidget(info,"fightNum"):setVisible(pData.fightPower~=nil)
		if pData.fightPower then
			me.assignWidget(info,"fightNum"):setString(me.toNum(pData.fightPower))
		end
		me.assignWidget(info,"Text_union"):setVisible(pData.familyName~=nil)
		if pData.familyName then
            me.assignWidget(info,"Text_union"):setVisible(true)
			me.assignWidget(info,"Text_union"):setString("联盟："..pData.familyName)
        else    
            me.assignWidget(info,"Text_union"):setVisible(false)
		end
		me.assignWidget(info,"Text_dep"):setVisible(pData.degree ~=nil)
		if pData.degree then
            me.assignWidget(info,"Text_dep"):setVisible(true)
			me.assignWidget(info,"Text_dep"):setString("职位："..me.alliancedegree(pData.degree))
         else    
            me.assignWidget(info,"Text_dep"):setVisible(false)
		end
--		if user.rankAlliancedatashow  == 1 then
--			me.assignWidget(info,"Text_union"):setVisible(true)
--			me.assignWidget(info,"Text_dep"):setVisible(true)
--		else
--			me.assignWidget(info,"Text_union"):setVisible(false)
--			me.assignWidget(info,"Text_dep"):setVisible(false)
--		end
		me.registGuiTouchEvent(self.layout,function (node,event)
			if event ~= ccui.TouchEventType.ended then
			return
		end 
		self.layout:removeFromParent()
		self.layout = nil
		end)

		me.registGuiClickEvent(me.assignWidget(info,"Button_mail"),function ()
			self.layout:removeAllChildren()
			self:popupMailView(self.mRoleData)
        end)
	end
end
function rankView:setLookMap(pos)                 
	local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
	me.showMessageDialog(pStr, function(args)
        if args == "ok" then
			if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
				pWorldMap:RankSkipPoint(pos)
				self:close()
            elseif canJumpWorldMap() then
				mainCity:cloudClose(function (node)
					print("跳转外城")
					local loadlayer = loadWorldMap:create("loadScene.csb")
					loadlayer:setWarningPoint(pos)
					me.runScene(loadlayer)
                end)
				me.DelayRun(function ()                    
					self:close()
                end)
            end             
        end
    end )                               
end
function rankView:popupMailView(pData)
	local mail = sendMailCell:create("sendMailCell.csb")
	mail:setData(nil,pData["name"],mCross_Sever_Out)
	self:addChild(mail)       
	self.layout:removeFromParent()
	self.layout = nil  
	self.mMail = mail   
end

function rankView:popalliance(pData)
	local pAllinceInfor = RanAllianceInfor:create("rank/rankallianceInfo.csb")
	self:addChild(pAllinceInfor, me.MAXZORDER);                      
	pAllinceInfor:setData(pData)
	me.showLayer(pAllinceInfor, "bg_frame")    
end

function rankView:update(msg)
	if checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
        if msg.c.typeId==17 or msg.c.typeId==18 then
            self.areaRankData = msg.c.list
        elseif msg.c.typeId==19 then
            self.resistRankData = msg.c.list
        end
		self:setRankType()
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_RANK) then
        if msg.c.typeId==103 then --积分排行
            self.digoreScoreData = msg.c
            self.digoreScoreRankData = msg.c.list
        elseif msg.c.typeId==104 or msg.c.typeId==105 then --仇敌排行
            self.digoreEnemyData = msg.c
            self.digoreEnemyRankData = msg.c.list
        end
		self:setRankType()
    elseif checkMsg(msg.t, MsgCode.ROLE_VIEW_PLAYER_INFO) then  -- 个人信息
	    self:popupInfoView(msg.c)
	    disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RANK_FAMILY_INFO) then  -- 联盟信息    
	    local pData = msg.c
	    self:popalliance(pData)
	    disWaitLayer()
	elseif checkMsg(msg.t, MsgCode.CHAT_MAIL) then
		if me.toNum(msg.c.alertId) == 559  then
            if self.mMail then
    --  self.mMail:removeFromParent()
            self.mMail = nil
            end
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_LIMIT_REWARDS) then
	    if self.rewardView == nil then
		    self.rewardView = nil
		    if msg.c.type == timeLimitRewardSubcell.singleRewardType or msg.c.type == timeLimitRewardSubcell.totalRewardType then
			    self.rewardView = timeLimitRewardSubcell:create("timeLimitCell_rewards.csb")
		    else
			    self.rewardView = NewYearReawrd:create("NewYearReawrd.csb")
		    end
		    self.rewardView:setRewardType(msg.c.type,msg.c.award,function ()
			    self.rewardView = nil
            end)
		    self:addChild(self.rewardView)
	    else
		    self.rewardView:setRewardType(msg.c.type,msg.c.award,function ()
			    self.rewardView = nil
            end)
		    self.rewardView:setRewardInfos()
	    end
    end    
end

function rankView:onEnter()
	if self.RankType == rankView.PERSONAL then 
		self:setButton(self.btn_Peronal,false)
    elseif self.RankType == rankView.ALLIANCE then 
        self:setButton(self.btn_Alliance,false)
    elseif self.RankType == rankView.HERO_LEVEL_RANK then 
        self:setButton(self.btn_SelfArea,false)
    elseif self.RankType == rankView.DIGORE_SCORE_RANK then 
        self:setButton(self.btn_Tian,false)
    elseif self.RankType == rankView.DIGORE_ENEMY_RANK then 
        self:setButton(self.btn_Enemy1,false)
    elseif self.RankType == rankView.PLUNDER then 
        self:setButton(self.btn_Plunder,false)
    elseif self.RankType == rankView.PVPSCORE then 
        self:setButton(self.btn_Score,false)
    elseif self.RankType == rankView.PROMITION_NEWYEAR or self.RankType == rankView.PROMITION_MEDAL then 
        self:setButton(self.poper_score,false)
    elseif self.RankType == rankView.PROMITION_NEWYEARTOTAL or self.RankType == rankView.PROMITION_MEDALTOTAL then 
        self:setButton(self.total_score,false)
    end
	me.assignWidget(self,"rank_allian_Btn"):setVisible(false)
	me.assignWidget(self,"rank_not"):setVisible(false)

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知d
	    self:update(msg)        
    end)
	self:setRankType()
    me.doLayout(self,me.winSize)  
end

function rankView:onEnterTransitionDidFinish()
    --[[
    me.DelayRun(function ()
        self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知d
	    self:update(msg)        
    end)
    end,0.2)
    ]]
    print("rankView onEnterTransitionDidFinish") 
end

function rankView:onExit()
	print("rankView onExit")  
    UserModel:removeLisener(self.modelkey) -- 删除消息通知  
    self.pPerantNode.mRankView = nil   
    me.clearTimer(self.BlinkTime)   
end

function rankView:close()
	self:removeFromParentAndCleanup(true)  
end

