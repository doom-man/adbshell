-- [Comment]
-- jnmo
warshipPvPView = class("warshipPvPView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipPvPView.__index = warshipPvPView
function warshipPvPView:create(...)
    local layer = warshipPvPView.new(...)
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
function warshipPvPView:ctor()
    print("warshipPvPView ctor")
end
function warshipPvPView:init()
    print("warshipPvPView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Image_daygift", function(node)
        NetMan:send(_MSG.CheckActivity_Limit_Reward(21))        
    end )
    me.registGuiClickEventByName(self, "Image_seasongift", function(node)
        NetMan:send(_MSG.CheckActivity_Limit_Reward(22))
    end )
    me.registGuiClickEventByName(self, "Button_Rank", function(node)

    end )
    me.registGuiClickEventByName(self, "Button_Log", function(node)
        local mailview = mailview:create("mailview.csb",mailview.MAILSHIPPVP,1)
        me.runningScene():addChild(mailview, me.MAXZORDER);
        me.showLayer(mailview, "bg_frame")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.mailview = mailview
        else
            pWorldMap.mailview = mailview
        end
    end )
    me.registGuiClickEventByName(self, "Button_Addtime", function(node)


    end )
    me.registGuiClickEventByName(self, "Button_config", function(node)
        NetMan:send(_MSG.msg_ship_refit_get_ship())
        local dispose = warshipDisposeView:create("warshipDisposeView.csb")
        me.popLayer(dispose)
    end )
    self.Text_myrank = me.assignWidget(self, "Text_myrank")
    self.Text_Pvp_num = me.assignWidget(self, "Text_Pvp_num")
    self.Text_End = me.assignWidget(self, "Text_End")

    self.Text_myshipName = me.assignWidget(self, "Text_myshipName")
    self.Image_myshipicon = me.assignWidget(self, "Image_myshipicon")
    self.Text_myrank = me.assignWidget(self, "Text_myrank")
    self.Text_myrank = me.assignWidget(self, "Text_myrank")
    self.Text_myrank = me.assignWidget(self, "Text_myrank")
    return true
end
function warshipPvPView:initWithData(data)
    self.Text_myrank:setString(data.myRank)
    local myshipDef = cfg[CfgType.SHIP_DATA][data.myShip.defid]
    self.Text_myshipName:setString(myshipDef.name)
    self.Text_Pvp_num:setString(data.restChallengeTime .. "/" .. data.maxChanllengeTime)
    self.Image_myshipicon:loadTexture(getWarshipImageTexture(data.myShip.type), me.localType)
    me.resizeImage(self.Image_myshipicon, 320, 200)
    local function info_call(node)
        local info = warshipPVPPlayerInfo:create("warshipPVPPlayerInfo.csb")
        info:initWithData(node.data)
        me.popLayer(info)
    end
    local function battle_call(node)
       NetMan:send(_MSG.msg_ship_refit_pvp_battle(node.data.rank))
    end
    for var = 1, 6 do
        local player = me.assignWidget(self, "Image_player" .. var)
        local Image_rank = me.assignWidget(player, "Image_rank")
        local Image_icon = me.assignWidget(player, "Image_icon")
        local rank = me.assignWidget(player, "rank")
        local Text_Player_Name = me.assignWidget(player, "Text_Player_Name")
        local Button_Battle = me.assignWidget(player, "Button_Battle")
        local vdata = data.list[var]
        if vdata.rank == 1 then
            Image_rank:setVisible(true)
            rank:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_1.png", me.localType)
        elseif vdata.rank == 2 then
            Image_rank:setVisible(true)
            rank:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_2.png", me.localType)
        elseif vdata.rank == 3 then
            Image_rank:setVisible(true)
            rank:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_3.png", me.localType)
        else
            Image_rank:setVisible(false)
            rank:setVisible(true)
            rank:setString(vdata.rank)
        end
        Text_Player_Name:setString(vdata.pName)
        Image_icon:loadTexture(getWarshipImageTexture(vdata.type), me.localType)
        me.registGuiClickEvent(Image_icon, info_call)
        me.registGuiClickEvent(Button_Battle, battle_call)
        Image_icon.data = vdata
        Button_Battle.data= vdata
        me.resizeImage(Image_icon, 200, 120)
    end
end
function warshipPvPView:onEnter()
    print("warshipPvPView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_ENTER_PVP) then
            self:initWithData(msg.c)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_LIMIT_REWARDS) then
            if self.rewardView == nil then
                self.rewardView = pvpRewardView:create("NewYearReawrd.csb")
                self.rewardView:setRewardType(msg.c.type, msg.c.award, function()
                    self.rewardView = nil
                end )
                self.rewardView:setRewardInfos()
                me.popLayer(self.rewardView)
            else
                self.rewardView:setRewardType(msg.c.type, msg.c.award, function()
                    self.rewardView = nil
                end )
                self.rewardView:setRewardInfos()
            end
        elseif checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_PVP_BATTLE) then
            self.battleResult = msg.c
            local ani = warShipBattleAni:create("warshipPVPAni.csb")
            ani:setResult(self.battleResult)
            me.popLayer(ani)
        elseif checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_PVP_MAILINFO) then            
            local info = warshipPVPMailInfo:create("warshipPVPMailInfo.csb")
            info:initWithData(msg.c)
            me.popLayer(info)
        end
    end )
end
function warshipPvPView:onEnterTransitionDidFinish()
    print("warshipPvPView onEnterTransitionDidFinish")
end
function warshipPvPView:onExit()
    print("warshipPvPView onExit")
    UserModel:removeLisener(self.modelkey)
end
function warshipPvPView:close()
    self:removeFromParent()
end

