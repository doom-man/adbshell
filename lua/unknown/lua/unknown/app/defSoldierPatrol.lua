-- [Comment]
-- jnmo
defSoldierPatrol = class("defSoldierPatrol", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierPatrol.__index = defSoldierPatrol
function defSoldierPatrol:create(...)
    local layer = defSoldierPatrol.new(...)
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
function defSoldierPatrol:ctor()
    print("defSoldierPatrol ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_GUARD_PATROL_INIT) then
              self:initData(msg.c)
        elseif checkMsg(msg.t, MsgCode.MSG_GUARD_PATROL_GET) then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_PATROL)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2+50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
        end
    end )
end


function defSoldierPatrol:initData(data)
    
    self.data = data
    self.patrolTimes:setString((data.max-data.times).."/"..data.max)
    if #self.data.items==0 then
        self.awardIcon:setVisible(false)
    else
        self.awardIcon:setVisible(true)
        self.awardNums:setString(#self.data.items)
    end

    self.Text_Max:setString("入驻上限:".. data.armyTotal.."/"..data.armyMax)

    me.clearTimer(self.timeId)
    if data.countdown<=0 then
        self.ntime:setString("00:00:00")
    else
        self.ntime:setString(me.formartSecTime(self.data.countdown))
        self.timeId = me.registTimer(-1, function(dt)
            if self.data.countdown == 0 then
                me.clearTimer(self.timeId)
            end
            self.data.countdown = self.data.countdown - 1
            self.ntime:setString(me.formartSecTime(self.data.countdown))
        end , 1)
    end

    
    if data.status==0 then
        self.statuspanel:setVisible(false)
        self.patrolBtnTxt:setString("开始巡逻")
        self.statusTxt:setString("空闲中")
        self.patrolBtn:setVisible(true)
        self.awardBtn:setVisible(false)
    elseif data.status==1 then
        self.statuspanel:setVisible(true)
        self.patrolBtnTxt:setString("停止巡逻")
        self.statusTxt:setString("巡逻中")
        self.patrolBtn:setVisible(true)
        self.awardBtn:setVisible(false)
    elseif data.status==2 then
        self.statuspanel:setVisible(true)
        self.patrolBtnTxt:setString("领取奖励")
        self.statusTxt:setString("巡逻结束")
        self.patrolBtn:setVisible(false)
        self.awardBtn:setVisible(true)
    end

    local descTxt =me.assignWidget(self, "descTxt_0")
    descTxt:setString(me.strReplace(descTxt:getString(), "#", {data.defs[1].lv, data.defs[1].per}))

    descTxt =me.assignWidget(self, "descTxt_1")
    descTxt:setString(me.strReplace(descTxt:getString(), "#", {data.defs[2].lv, data.defs[2].per}))

    descTxt =me.assignWidget(self, "descTxt_2")
    descTxt:setString(me.strReplace(descTxt:getString(), "#", {data.defs[3].lv, data.defs[3].per}))

    descTxt =me.assignWidget(self, "descTxt_4")
    descTxt:setString(me.strReplace(descTxt:getString(), "#", {data.base}))

    me.coroClear(self.schid)
    self.mH = coroutine.create(function()
        self:initPatrolLog()
    end)
    self.schid = me.coroStart(self.mH)
end

---
-- 初始化巡逻日志
--
function defSoldierPatrol:initPatrolLog()
    self.ListView:removeAllChildren()
    local index = 1
    for inKey, inVar in ipairs(self.data.history) do
        local timeObj = os.date("*t", inVar.time)
        if #inVar.record==0 then
            inVar.record[1]=0
        end
        for k, v in ipairs(inVar.record) do
            local cItem = self.logcell:clone():setVisible(true)
            local dateTxt = me.assignWidget(cItem, "dateTxt")
            local timeTxt = me.assignWidget(cItem, "timeTxt")
            local descTxt = me.assignWidget(cItem, "descTxt")
            if k==1 then
                dateTxt:setString(timeObj.month.."月" .. timeObj.day.."日")
                timeTxt:setString(timeObj.hour..":" .. timeObj.min)
            else
                dateTxt:setString("")
                timeTxt:setString("")
            end
            self.ListView:pushBackCustomItem(cItem)
            index = index + 1
            local itemPng = "lingzhu_beijing_huadong_2.png"
            if index % 2 == 0 then
                itemPng = "alliance_alpha_bg.png"
            end
        
            local str = ""
            if inVar.id==1 then
                str = "<txt0014,c0bd8c>开始巡逻&"
            elseif inVar.id==4 then
                str = "<txt0014,c0bd8c>未获得物品&"
            elseif inVar.id==3 then
                str = "<txt0014,c0bd8c>结束巡逻&"
            else
                local cfgData = cfg[CfgType.ETC][v[1]]
                local _, color = me.getColorByQuality(cfgData.quality)
                str="<txt0014,c0bd8c>获得&<txt0014,"..string.sub(color,2)..">"..cfgData.name.."&<txt0014,c0bd8c>x"..v[2].."&"
            end
            local richTxt = mRichText:create(str)
            richTxt:setPosition(215.5, 6)
            cItem:addChild(richTxt)
            cItem:loadTexture(itemPng, me.localType)
        end
        coroutine.yield()
    end
end

---
-- 点击巡逻
--
function defSoldierPatrol:clickPatrol()
    if self.data.status==0 then
        local function continue(str)
            if str=="ok" then
                NetMan:send(_MSG.guard_patrol_start())
            end
        end
        me.showMessageDialog("巡逻时禁卫军不会参与守城战斗，是否确认?", continue)
    elseif self.data.status==1 then
        local function continue(str)
            if str=="ok" then
                NetMan:send(_MSG.guard_patrol_stop())
            end
        end
        me.showMessageDialog("停止巡逻仍会消耗次数，且巡逻时间不满10分钟时将不会获得物品，是否确认?", continue)
    elseif self.data.status==2 then
        local awardPanel = defSoldierPatrolAward:create("defSoldierPatrolAward.csb")
        me.popLayer(awardPanel)
        awardPanel:setData(self.data)
    end

end

---
-- 显示奖励
--
function defSoldierPatrol:showAward()
    local awardPanel = defSoldierPatrolAward:create("defSoldierPatrolAward.csb")
    me.popLayer(awardPanel)
    awardPanel:setData(self.data)
end

function defSoldierPatrol:init()
    print("defSoldierPatrol init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    
    self.statuspanel = me.assignWidget(self, "statuspanel")
    self.Text_Max = me.assignWidget(self, "Text_Max")
    self.ListView = me.assignWidget(self, "ListView")
    self.logcell = me.assignWidget(self, "logcell")
    self.statusTxt = me.assignWidget(self, "statusTxt")
    self.patrolTimes = me.assignWidget(self, "patrolTimes")
    self.awardIcon = me.assignWidget(self, "awardIcon")
    self.awardNums = me.assignWidget(self.awardIcon, "awardNums")
    self.ntime = me.assignWidget(self, "ntime")
    self.patrolBtn = me.registGuiClickEventByName(self, "patrolBtn", handler(self, self.clickPatrol))
    self.patrolBtnTxt = me.assignWidget(self.patrolBtn, "image_title")
    me.registGuiClickEvent(self.awardIcon, handler(self, self.showAward))
    self.awardBtn = me.registGuiClickEventByName(self, "awardBtn", handler(self, self.clickPatrol))


    local descBtn = me.assignWidget(self,"descBtn")
    self.mDescBool = false
    me.registGuiClickEvent(descBtn,function (node)     
         if self.mDescBool then
            me.assignWidget(self, "descNode"):setVisible(false)     
            self.mDescBool = false
         else
            me.assignWidget(self, "descNode"):setVisible(true)   
            --me.assignWidget(self, "descTxt"):setString("可以锁定"..LOCK_ITEM_NUMS.."条属性")
            self.mDescBool = true
         end         
                             
   end)
    local function onTouchBegan()
        if self.mDescBool then
            me.assignWidget(self, "descNode"):setVisible(false)     
            self.mDescBool = false
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, me.assignWidget(self,"touchPanel"))
    me.assignWidget(self,"touchPanel"):setSwallowTouches(false)

    return true
end

function defSoldierPatrol:onEnter()
    print("defSoldierPatrol onEnter")
    me.doLayout(self, me.winSize)
end
function defSoldierPatrol:onEnterTransitionDidFinish()
    print("defSoldierPatrol onEnterTransitionDidFinish")
end
function defSoldierPatrol:onExit()
    print("defSoldierPatrol onExit")

    me.coroClear(self.schid)
    me.clearTimer(self.timeId)
    UserModel:removeLisener(self.modelkey)
end
function defSoldierPatrol:close()
    self:removeFromParent()
end


