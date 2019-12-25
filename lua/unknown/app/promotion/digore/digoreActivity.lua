digoreActivity = class("digoreActivity",function(...)
    return cc.CSLoader:createNode(...)
end)
digoreActivity.__index = digoreActivity
function digoreActivity:create(...)
    local layer = digoreActivity.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
--jnmo god
function digoreActivity:ctor()
    print("digoreActivity:ctor()")
end
function digoreActivity:init()
    self.cate = {me.assignWidget(self, "cate1"),me.assignWidget(self, "cate2"),me.assignWidget(self, "cate3")}
    me.registGuiClickEvent(me.assignWidget(self.cate[1],"joinBtn"), handler(self, self.joinActivity))
    me.registGuiClickEvent(me.assignWidget(self.cate[2],"joinBtn"), handler(self, self.joinActivity))
    me.registGuiClickEvent(me.assignWidget(self.cate[3],"joinBtn"), handler(self, self.joinActivity))
    self.rankBtn = me.assignWidget(self, "rankBtn")
    me.registGuiClickEvent(self.rankBtn, handler(self, self.gotoRank))

    self.reportBtn = me.registGuiClickEventByName(self, "reportBtn", function(node)
        local mailview = mailview:create("mailview.csb",mailview.MAILDIGORE,1)
        me.runningScene():addChild(mailview, me.MAXZORDER);
        me.showLayer(mailview, "bg_frame")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.mailview = mailview
        else
            pWorldMap.mailview = mailview
        end
        me.assignWidget(self.reportBtn, "redpoint"):setVisible(false)
        user.activity_mail_new[20]=0
    end)

    if user.activity_mail_new[20] and user.activity_mail_new[20]>0 then
        me.assignWidget(self.reportBtn, "redpoint"):setVisible(true)
    end

    self.rankBtn = me.registGuiClickEventByName(self, "rankBtn", function(node)
        local pRank = rankView:create("rank/rankview.csb")
        pRank:setRankRype(rankView.DIGORE_SCORE_RANK)
        pRank:ParentNode(self)
        me.runningScene():addChild(pRank, me.MAXZORDER)
        me.showLayer(pRank, "bg_frame")
        self.mRankView = pRank
        NetMan:send(_MSG.digoreRank(1, 103))
    end)

    self.awardBtn = me.registGuiClickEventByName(self, "awardBtn", function(node)
        local pAward = digoreRewards:create("digore/digore_rewards.csb")
        me.runningScene():addChild(pAward, me.MAXZORDER)
        me.showLayer(pAward, "bg")
        NetMan:send(_MSG.CheckActivity_Limit_Reward(17))
    end)

    self.shopBtn = me.registGuiClickEventByName(self, "shopBtn", function(node)
        local pShop = digoreShop:create("digore/digoreShop.csb")
        me.runningScene():addChild(pShop, me.MAXZORDER)
        me.showLayer(pShop, "bg_frame")
        NetMan:send(_MSG.initShop(17))
    end)

    me.registGuiClickEventByName(self, "Button_Help", function(node)
        local help = digoreHelp:create("digore/digoreHelp.csb")
        me.popLayer(help)
    end )

    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_JOIN) then
            local id = msg.c.id
            user.activityDetail.list[id].fightPower=msg.c.fightPower
            user.activityDetail.list[id].size=msg.c.size
            user.activityDetail.list[id].inReg=msg.c.inReg
            user.activityDetail.list[id].inFight=msg.c.inFight
            if msg.c.inReg==true then
                showTips("报名成功")
            end
            self:initTopBar(1)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_INIT_VIEW) then
            if msg.c.activityId == ACTIVITY_ID_DIGORE then
                self:initTopBar(0)
            end
        elseif checkMsg(msg.t, MsgCode.SHOP_BUY_AMOUNT) then
            user.digoreScore = msg.c.score
            me.assignWidget(self, "scoreTxt"):setString(user.digoreScore)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_MAIL_NEW) then
            if user.activity_mail_new[20] and user.activity_mail_new[20]>0 then
                me.assignWidget(self.reportBtn, "redpoint"):setVisible(true)
            end
        end      
    end ) 

    return true
end
function digoreActivity:onEnter()  
    me.registGuiClickEventByName(self,"Button_close",function ()
        self:close()
    end)

    self:initTopBar(0)

    me.doLayout(self,me.winSize)
end

function digoreActivity:gotoRank(node)
    local pRank = rankView:create("rank/rankview.csb")
    pRank:setRankRype(rankView.HERO_LEVEL_RANK)
    pRank:ParentNode(self)
    me.runningScene():addChild(pRank, me.MAXZORDER)
    me.showLayer(pRank, "bg_frame")
    self.mRankView = pRank
    NetMan:send(_MSG.rankList(17))
end

function digoreActivity:setP(p)
    self.p = p
end


function digoreActivity:initTopBar(isReTimer)
    user.digoreScore = user.activityDetail.score
    me.assignWidget(self, "scoreTxt"):setString(user.activityDetail.score)

    if isReTimer==0 and self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end

    local Text_countDown
    if isReTimer==0 then
        self.countdown = user.activityDetail.countdown
        local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        if Panel_richText:getChildByName("richTxt")==nil then
            local rich = mRichText:create(user.activityDetail.desc or activity.desc, Panel_richText:getContentSize().width)
            rich:setPosition(0, Panel_richText:getContentSize().height)
            rich:setAnchorPoint(cc.p(0, 1))
            rich:setName("richTxt")
            Panel_richText:addChild(rich)
        end
        Text_countDown = me.assignWidget(self, "Text_time")
    end

    local timeStr = ""

    if user.activityDetail.status == 0 then
        timeStr = "后开启报名"
        for i=1, 3 do
            local data = user.activityDetail.list[i]
            local str = ""
            if data.maxLv==0 then
                str="主城等级：>="..data.level.."级"
            else
                str="主城等级："..data.level.."级-"..data.maxLv.."级"
            end
            me.assignWidget(self.cate[i], "cityLv"):setString(str)
            me.assignWidget(self.cate[i], "baomingTxt"):setString("报名人数："..data.size)
            me.assignWidget(self.cate[i], "luyongTxt"):setString(data.max>10000 and "无上限" or data.max)
            me.assignWidget(self.cate[i], "powerTxt"):setString(data.fightPower==0 and "无需求" or data.fightPower)
            local btn = me.assignWidget(self.cate[i], "joinBtn")
            me.assignWidget(btn, "btnTxt"):setString("报名")
            me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(20,20,20))
            me.assignWidget(self.cate[i], "statusTxt"):setVisible(false)
            btn:setBright(false)
        end
    elseif user.activityDetail.status == 1 then
        timeStr = "后结束报名"
        local isJoin=false  --是否报名
        for i=1, 3 do
            local data = user.activityDetail.list[i]
            local str = ""
            if data.maxLv==0 then
                str="主城等级：>="..data.level.."级"
            else
                str="主城等级："..data.level.."级-"..data.maxLv.."级"
            end
            me.assignWidget(self.cate[i], "cityLv"):setString(str)
            me.assignWidget(self.cate[i], "baomingTxt"):setString("报名人数："..data.size)
            me.assignWidget(self.cate[i], "luyongTxt"):setString(data.max>10000 and "无上限" or data.max)
            me.assignWidget(self.cate[i], "powerTxt"):setString(data.fightPower==0 and "无需求" or data.fightPower)
            if data.inReg==false then
                me.assignWidget(self.cate[i], "statusTxt"):setVisible(false)
            else
                isJoin=true
                me.assignWidget(self.cate[i], "statusTxt"):setVisible(true)
                if data.inFight==true then
                    me.assignWidget(self.cate[i], "statusTxt"):setString("将获得资格")
                    me.assignWidget(self.cate[i], "statusTxt"):setTextColor(cc.c3b(103, 255 ,2))
                else
                    me.assignWidget(self.cate[i], "statusTxt"):setString("未达到最低战力")
                    me.assignWidget(self.cate[i], "statusTxt"):setTextColor(cc.c3b(255, 0 ,0))
                end
            end
        end
        for i=1, 3 do
            local data = user.activityDetail.list[i]
            local btn = me.assignWidget(self.cate[i], "joinBtn")
            if data.inReg==true then
                me.assignWidget(btn, "btnTxt"):setString("取消报名")
                me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(100,21,21))
            elseif isJoin==false then
                if data.levelAchieve==1 then  --达到报名条件
                    btn:setBright(true)
                else
                    btn:setBright(false)
                end
                me.assignWidget(btn, "btnTxt"):setString("报名")
                me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(20,20,20))
            else
                btn:setBright(false)
                me.assignWidget(btn, "btnTxt"):setString("报名")
                me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(20,20,20))
            end
        end
    elseif user.activityDetail.status == 2 then
        timeStr = "后结束挖掘"
        for i=1, 3 do
            local data = user.activityDetail.list[i]
            local str = ""
            if data.maxLv==0 then
                str="主城等级：>="..data.level.."级"
            else
                str="主城等级："..data.level.."级-"..data.maxLv.."级"
            end
            me.assignWidget(self.cate[i], "cityLv"):setString(str)
            me.assignWidget(self.cate[i], "baomingTxt"):setString("报名人数："..data.size)
            me.assignWidget(self.cate[i], "luyongTxt"):setString(data.max>10000 and "无上限" or data.max)
            me.assignWidget(self.cate[i], "powerTxt"):setString(data.fightPower==0 and "无需求" or data.fightPower)
            local btn = me.assignWidget(self.cate[i], "joinBtn")
            me.assignWidget(btn, "btnTxt"):setString("前往遗迹")
            if data.inReg==false then
                me.assignWidget(self.cate[i], "statusTxt"):setVisible(false)
                btn:setBright(false)
                me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(229,229,229))
            else
                btn:setBright(true)
                me.assignWidget(btn, "btnTxt"):setTextColor(cc.c3b(100,21,21))
                me.assignWidget(self.cate[i], "statusTxt"):setVisible(true)
                if data.inFight==true then
                    me.assignWidget(self.cate[i], "statusTxt"):setString("已获得资格")
                    me.assignWidget(self.cate[i], "statusTxt"):setTextColor(cc.c3b(103, 255 ,2))
                else
                    me.assignWidget(self.cate[i], "statusTxt"):setString("未达到最低战力")
                    me.assignWidget(self.cate[i], "statusTxt"):setTextColor(cc.c3b(255, 0 ,0))
                end
            end
        end
    end

    if isReTimer==0 then
        Text_countDown:setString(me.formartSecTime(self.countdown)..timeStr)
        self.timer = me.registTimer(-1,function ()
            self.countdown = self.countdown - 1
            if self.countdown <= 0 then
                self.countdown = 0

                me.clearTimer(self.timer)
                self.timer = nil
                NetMan:send(_MSG.activityDetail(ACTIVITY_ID_DIGORE))
            end
            Text_countDown:setString(me.formartSecTime(self.countdown)..timeStr)
        end,1)
    end
end

function digoreActivity:joinActivity(node)
    local tipsTxt={"天阶遗迹","人阶遗迹", "地阶遗迹"}
    local isJoin=0  --是否报名
    for i=1, 3 do
        local data = user.activityDetail.list[i]
        if data.inReg==true then
            isJoin=i
            break
        end
    end
    local index = node:getTag()
    local data = user.activityDetail.list[index]

    if user.activityDetail.status == 0 then
        showTips("活动还未开始")
    elseif user.activityDetail.status == 1 then
        if data.inReg==true then --取消报名
            local function continue(str)
                if str=="ok" then
                    NetMan:send(_MSG.digoreJoin(data.id, false))
                end
            end
            me.showMessageDialog("确认取消报名吗?", continue)
        elseif isJoin==0 then
            if data.levelAchieve==1 then  --达到报名条件
                --[[
                local function continue(str)
                    if str=="ok" then
                        NetMan:send(_MSG.digoreJoin(data.id, true))
                    end
                end
                self:showMessageDialog(tipsTxt[index], continue)
                ]]
                NetMan:send(_MSG.digoreJoin(data.id, true))
            else
                showTips("主城等级未达到"..data.level.."级")
            end
        else
            showTips("已报名"..tipsTxt[isJoin])
        end
    elseif user.activityDetail.status == 2 then
        if data.inReg==false then
            showTips("未获得本次遗迹秘宝挖掘资格")
        else
            local tmpView = digoreView:create("digore/digoreview.csb")
            tmpView:setTitleIndex(isJoin)
            me.runningScene():addChild(tmpView, me.MAXZORDER)
            me.showLayer(tmpView, "fixLayout")
            NetMan:send(_MSG.digoreShow(data.id, 1))

            self.p:close()
        end
    end
end

function digoreActivity:showMessageDialog(txt, callfuc)
    local box = MessageBox:create("digore/digorePrompt.csb")
    me.assignWidget(box, "msg1"):setString(txt)
    box:register(callfuc or nil)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")
end


function digoreActivity:close()
    self:removeFromParentAndCleanup(true)
end

function digoreActivity:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    me.clearTimer(self.timer)
    self.timer=nil
end
