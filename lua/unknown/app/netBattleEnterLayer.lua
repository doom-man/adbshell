-- [Comment]
-- jnmo
netBattleEnterLayer = class("netBattleEnterLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
netBattleEnterLayer.__index = netBattleEnterLayer
function netBattleEnterLayer:create(...)
    local layer = netBattleEnterLayer.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
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
function netBattleEnterLayer:ctor()
    print("netBattleEnterLayer ctor")
end
function netBattleEnterLayer:init()
    print("netBattleEnterLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Tips", function(node)
             local tips = me.createNode("MessageBox_netBattleTips.csb")
             me.registGuiClickEventByName(tips,"btn_ok",function (args)
                 tips:removeFromParent()
             end)
             me.registGuiClickEventByName(tips,"btn_close",function (args)
                 tips:removeFromParent()
             end)
             me.popLayer(tips)
    end )    
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.CROSS_SEVER_PROMOTION_LIST) then
            self:initWithData(msg.c)
        elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then
            -- 跨服争霸
            if msg.c.type == 21 or msg.c.type == 22 or msg.c.type == 23 then
                return
            end
            -- 奖励
            if self.kingdom_cross_rewards == nil then
                self.kingdom_cross_rewards = nil
                if msg.c.type == kingdom_cross_rewards.RankRewardType or msg.c.type == kingdom_cross_rewards.totalRewardType
                or msg.c.type == kingdom_cross_rewards.countryRewardType then
                    self.kingdom_cross_rewards = kingdom_cross_rewards:create("kingdom_cross_rewards.csb")
                end
                self.kingdom_cross_rewards:setRewardType(msg.c.type, msg.c.stp, msg.c.award, function()
                    self.kingdom_cross_rewards = nil
                end )     
                me.popLayer(self.kingdom_cross_rewards)
            else
                self.kingdom_cross_rewards:setRewardType(msg.c.type, msg.c.stp, msg.c.award, function()
                    self.kingdom_cross_rewards = nil
                end )
                self.kingdom_cross_rewards:setRewardInfos()
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_CROSS_APPLY_AUTH) then
            -- 奖励
            self:close()
        end
    end )
    self.list = me.assignWidget(self, "list")
    return true
end
function netBattleEnterLayer:onEnter()
    print("netBattleEnterLayer onEnter")
    me.doLayout(self, me.winSize)
end
function netBattleEnterLayer:initWithData(data)
    self.data = data
    self.list:removeAllChildren()

    local fillList = me.assignWidget(self, "fillList")
    self.list:pushBackCustomItem(fillList:clone())
    local item = me.assignWidget(self, "netbattleItem")
    if self.data.list then
        for key, var in pairs(self.data.list) do
            local cell = item:clone()
            local Button_Tips = me.assignWidget(cell, "Button_Tips")
            local Image_Name = me.assignWidget(cell, "Image_Name")
            local Text_tiaojian = me.assignWidget(cell, "Text_tiaojian")
            local Text_Time = me.assignWidget(cell, "Text_Time")
            local Image_Enter = me.assignWidget(cell, "Image_Enter")
            -- 0 未开启 1 开启 ext 是否在跨服中
            Image_Enter:setVisible(var.status == 1)
            local Text_time_txt = me.assignWidget(cell, "Text_time_txt")
            if var.status == 0 then
                Text_time_txt:setString("距离开启:")
            elseif var.status == 1 then
                Text_time_txt:setString("距离结束:")
            elseif var.status == 2 then
                Text_time_txt:setString("距离结束:")
                Text_Time:setString("活动已结束")
            end
            local Button_Rank = me.registGuiClickEventByName(cell, "Button_Rank", function(args)
                NetMan:send(_MSG.rankList(rankView.NETBATTLE_PERSON ))
            end )
            Button_Rank.pData = var
            local Button_Reward = me.registGuiClickEventByName(cell, "Button_Reward", function(node)
                local pData = node.pData
                NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.countryRewardType, pData.id))
            end )
            Button_Reward.pData = var
            local Button_History = me.registGuiClickEventByName(cell, "Button_History", function(args)
                    NetMan:send(_MSG.Cross_Fight_Record())
                    local kingdom_Cross_rank = kingdom_Cross_rank:create("kingdom_Cross_rank.csb")                   
                    me.popLayer(kingdom_Cross_rank,"bg_frame")                 
            end )
            Button_History.pData = var
            local function enter_call(node)
                local pData = node.pData               
                    if user.Cross_Sever_Status == mCross_Sever and CUR_GAME_STATE == GAME_STATE_CITY then
                        mainCity:cloudClose( function(node)                        
                            local loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                            me.runScene(loadlayer)
                            self:close()
                        end )
                    else
                        if pData.status == 1 then
                            if pData.ext == 1 then
                                showTips("已主动退出，无法再次进入。")
                            elseif pData.ext == 2 then
                                showTips("你所在区服已被沦陷，无法进入。")
                            else
                                NetMan:send(_MSG.getNetBattleDataMsg())
                                First_City = true
                                if pWorldMap and pWorldMap.kmv then
                                    pWorldMap.kmv:close()
                                end
                            end
                        elseif pData.status == 0 then
                            showTips("活动未开启")
                        elseif pData.status == 2 then
                            showTips("活动已结束")
                        end
                    end                
            end
            self.list:pushBackCustomItem(cell)
            me.registGuiClickEvent(Image_Enter, enter_call)
            local Button_Enter = me.registGuiClickEventByName(cell, "Button_Enter", enter_call)
            Image_Enter.pData = var
            Button_Enter.pData = var

            Image_Name:loadTexture("netbattle_title"..var.id..".png", me.localType)
            Image_Name:ignoreContentAdaptWithSize(true)

            -- 跨服争霸
            if var.id == 2 then
                cell:loadTexture("netbattle_icon2.png", me.localType)
                
                Button_Rank:setVisible(false)

                -- 查看历史
                local function enter1()
                    PvpMainView.isHistory = true
                    local view = PvpMainView:create("pvp/PvpMainView.csb")
                    me.runningScene():addChild(view, me.MAXZORDER)
                    self:close()
                end
                me.registGuiClickEvent(Button_History, enter1)
                Button_History:setVisible(var.status == 0)

                -- 规则
                me.registGuiClickEvent(Button_Tips, function(sender)
                    local ruleList = {
                        "<txt0018,D4CDB9>\n1.阵容设置：在报名前需要先设置比赛所用的上中下三路跨服阵容，所有数据均为镜像数据，本玩法不会出现伤亡与损失，并且阵容只能在报名阶段内修改，报名结束后仅能调整队伍分路。注意：比赛用的士兵、英雄、战舰、圣物、属性加成和buff效果以报名时各分路配置的效果为准，本服当前激活的圣物和英雄属性在活动中不生效；&",
                        "<txt0018,D4CDB9>\n2.胜负判定：所有赛程均为单淘汰赛制，对决时双方上中下三路同时进行战斗，上路VS上路，中路VS中路，下路VS下路，在2路以上战胜对手即为本场获胜，败者淘汰；&",
                        "<txt0018,D4CDB9>\n3.报名：需要在报名阶段选择与自己等级匹配的争霸赛场进行报名，未在报名阶段进行报名的将不能参与后续的比赛，可在报名期间取消再重新报名以更新属性效果；注意：某组如果报名的人数不足32人，该组将取消比赛；&",
                        "<txt0018,D4CDB9>\n4.海选：系统将各赛场报名的玩家自动匹配对手进行对决，胜者继续进行匹配，败者淘汰，直到选出32个玩家，晋级下一轮比赛；&",
                        "<txt0018,D4CDB9>\n5.32进16：系统将海选产生的32强自动匹配分组，分为16组比赛，每组胜者进入下一轮，败者淘汰；&",
                        "<txt0018,D4CDB9>\n6.16进8：系统将上一轮胜出的16个玩家自动匹配分组，分为8组比赛，每组胜者进入下一轮，败者淘汰；&",
                        "<txt0018,D4CDB9>\n7.8进4：系统将上一轮胜出的8个玩家自动匹配分组，分为8组比赛，分布在对阵图的左右两侧，每组胜者进入下一轮，败者淘汰；&",
                        "<txt0018,D4CDB9>\n8.半决赛：对阵图左右两侧进入半决赛的两个玩家进行对决，胜者进入决赛，败者淘汰；&",
                        "<txt0018,D4CDB9>\n9.决赛：对阵图左侧半决赛胜者与右侧半决赛胜者进行最终对决，胜者为本次比赛冠军，败者为本次比赛亚军；&",
                        "<txt0018,D4CDB9>\n10.竞猜：从8进4开始，所有玩家可进行竞猜，如果押注的选手进入下一轮，将根据选手最终的赔率获得奖励；&",
                        "<txt0018,D4CDB9>\n11.竞猜限制：不能竞猜自己或者自己当前的对手，每轮竞猜次数有限制，竞猜次数达到上限将不能再竞猜；&",
                        "<txt0018,D4CDB9>\n12.赛事奖励：自己所有比赛都结束时，根据自己所获得的最高名次获得赛事奖励；&",
                    }
                    local view = PvpRuleView:create("pvp/PvpRuleView.csb")
                    self:addChild(view)
                    me.showLayer(view, "img_bg")
                    view:setRuleList(ruleList)
                end)

                -- 奖励
                me.registGuiClickEvent(Button_Reward, function(sender)
                    local view = PvpRewardView:create("pvp/PvpRewardView.csb")
                    self:addChild(view)
                    me.showLayer(view, "img_bg")
                end)
                
                -- 活动入口
                local function enter2()
                    PvpMainView.isHistory = false
                    local view = PvpMainView:create("pvp/PvpMainView.csb")
                    me.runningScene():addChild(view, me.MAXZORDER)
                    self:close()
                end
                me.registGuiClickEvent(Image_Enter, enter2)
                me.registGuiClickEvent(Button_Enter, enter2)
            end
            if var.time > 0 then
                local time = var.time / 1000
                me.clearTimer(self.timer)
                Text_Time:setString(me.formartSecTime(time))
                self.timer = me.registTimer(time, function(dt)
                    if time > 0 then
                        time = time - 1
                        Text_Time:setString(me.formartSecTime(time))
                    else
                        me.clearTimer(self.timer)
                    end
                end , 1)
            end
        end
    end
end
function netBattleEnterLayer:onEnterTransitionDidFinish()
    print("netBattleEnterLayer onEnterTransitionDidFinish")
end
function netBattleEnterLayer:onExit()
    print("netBattleEnterLayer onExit")
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
end
function netBattleEnterLayer:close()
    self:removeFromParent()
end
