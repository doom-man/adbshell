timeLimitDetailSubcell = class("timeLimitDetailSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
timeLimitDetailSubcell.__index = timeLimitDetailSubcell

function timeLimitDetailSubcell:create(...)
    local layer = timeLimitDetailSubcell.new(...)
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

function timeLimitDetailSubcell:ctor()
    print("timeLimitDetailSubcell:ctor()")
end
function timeLimitDetailSubcell:init()
    print("timeLimitDetailSubcell:init()")
    self.timers = {}
    self.totalNum = 0
    return true
end
function timeLimitDetailSubcell:onEnter()  
    local activity = cfg[CfgType.LIMIT_ACTIVITY][me.toNum(user.activityDetail.stageID)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end
    me.assignWidget(self,"Text_title_process"):setString("阶段("..user.activityDetail.stage.."/5):")
    me.assignWidget(self,"Text_grade"):setString(activity.stage)
    me.assignWidget(self,"Text_mynumber"):setString("我的积分："..user.activityDetail.number)
    local time = user.activityDetail.countDown-(me.sysTime()-user.activityDetail.startTime)/1000
    me.assignWidget(self,"Text_time"):setString(me.formartSecTime(time))
    self.timer = me.registTimer(-1,function ()
        time = time-1
        if time <= 0 then
            time = 0
            me.clearTimer(self.timer)
        end
        local t = me.formartSecTime(time)
        me.assignWidget(self,"Text_time"):setString(t)
    end,1)
    
    if me.toNum(user.activityDetail.singleRanking) <= 0 then
        me.assignWidget(self,"Text_rank_process"):setString("未上榜")
    else
        me.assignWidget(self,"Text_rank_process"):setString("我的排名:"..user.activityDetail.singleRanking)
    end
    if me.toNum(user.activityDetail.totalRanking) <= 0 then
        me.assignWidget(self,"Text_rank_total"):setString("未上榜")
    else
        me.assignWidget(self,"Text_rank_total"):setString("我的排名:"..user.activityDetail.totalRanking)
    end

    self:setRewardInfo(user.activityDetail.rewards)
    self:setProcess(user.activityDetail.number,self.totalNum,user.activityDetail.rewards)
    
    me.registGuiClickEventByName(self,"Button_process",function ()
        NetMan:send(_MSG.rankList(rankView.PROMITION_SINGLE ))
    end)

    me.registGuiClickEventByName(self,"Button_total",function ()
        NetMan:send(_MSG.rankList(rankView.PROMITION_TOTAL ))
    end)

    me.registGuiClickEventByName(self,"Button_total_history",function ()
        NetMan:send(_MSG.rankList(rankView.PROMITION_HISTORY ))
    end)

    self.lisener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_TIMELIMIT or msg.c.activityId == ACTIVITY_ID_TIMELIMIT_NEW then
                self:setRewardInfo(user.activityDetail.rewards)
            end
        end
    end)

    --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_TIMELIMIT_NEW)]==1 then --移除红点
        removeRedpoint(ACTIVITY_ID_TIMELIMIT_NEW)
    --end

    me.doLayout(self,me.winSize)
end

function timeLimitDetailSubcell:setProcess(number,totalNum,rewards)
    local unReach = true
    for var = 1, 4 do
        local LoadingBar = me.assignWidget(self,"LoadingBar_process_"..var)
        local num = rewards[var].key
        local num_pre = 0
        if var-1>0 then
            num_pre = rewards[var-1].key
        end
        if number>=num then
            LoadingBar:setPercent(100)
        else
            if unReach == true then
                LoadingBar:setPercent(math.floor((number-num_pre)/(num-num_pre)*100))
                unReach = false
            else
                LoadingBar:setPercent(0)
            end
        end
    end
end

function timeLimitDetailSubcell:setRewardInfo(rewards)
    local function addAnim(node)
        local ani = createArmature("keji_jiesuo")
        node:addChild(ani)
        ani:getAnimation():play("donghua")
        ani:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
    end

    local pngs = {}
    pngs[#pngs+1] = "huodong_baoxiang_lvse.png"
    pngs[#pngs+1] = "huodong_baoxiang_lanse.png"
    pngs[#pngs+1] = "huodong_baoxiang_zise.png"
    pngs[#pngs+1] = "huodong_baoxiang_chengse.png"
    for var = 1, 4 do
        local Text_process = me.assignWidget(self,"Text_process_"..var) 
        local Node_process = me.assignWidget(self,"Node_process_"..var)
        local Panel_touch = me.assignWidget(self,"Panel_touch_"..var)
        local data = rewards[var]
        Text_process:setString(data.key)
        if var == 4 then
            self.totalNum = math.floor(data.key+data.key*0.1)    
        end

        local sp = Node_process:getChildByTag(5555)
        if sp == nil then
            sp = me.createSprite(pngs[var])
            sp:setTag(5555)
            sp:setAnchorPoint(cc.p(0.5,0.5))
            sp:setPosition(cc.p(0,0))
            Node_process:addChild(sp)
        end

        if data.status == 0 then -- 已领取
            Panel_touch:removeAllChildren()
            me.graySprite(sp)
            me.registGuiClickEvent(Panel_touch,function ()
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData_Limit(data.items)
                mainCity:addChild(gdc,me.MAXZORDER)
            end)
        elseif data.status == 1 then --未领取 
            addAnim(Panel_touch)
            me.registGuiClickEvent(Panel_touch,function ()
                NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,data.key,user.activityDetail.stageID))
            end)
        elseif data.status == 2 then --未达到
            me.registGuiClickEvent(Panel_touch,function ()
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData_Limit(data.items)
                me.popLayer(gdc)
            end)
        end
    end
end

function timeLimitDetailSubcell:onExit()
    UserModel:removeLisener(self.lisener) -- 删除消息通知
    me.clearTimer(self.timer) 
end