--[Comment]
--jnmo
EveryDayBuy = class("EveryDayBuy",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
EveryDayBuy.__index = EveryDayBuy
function EveryDayBuy:create(...)
    local layer = EveryDayBuy.new(...)
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
EveryDayBuy.EVERYDAY = 1        -- 每日优惠
EveryDayBuy.REWARD = 2        -- 累积奖励
RewardIcon = { "huodong_baoxiang_lanse.png","huodong_baoxiang_chengse.png","huodong_baoxiang_zise.png"}
function EveryDayBuy:ctor()   
    print("EveryDayBuy ctor") 
end
function EveryDayBuy:init()   
    print("EveryDayBuy init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
        self.DayType = EveryDayBuy.EVERYDAY
        self.Button_month = me.registGuiClickEventByName(self, "Button_month", function(node)
        --  每日优惠
        self:setButton(self.Button_month, false)
        self:setButton(self.Button_week, true)      
    
        self.DayType = EveryDayBuy.EVERYDAY
        self:setType()      
    end )
        self.Button_week = me.registGuiClickEventByName(self, "Button_week", function(node)
        -- 事件信息
        self:setButton(self.Button_week, false)
        self:setButton(self.Button_month, true)     
        self.DayType = EveryDayBuy.REWARD   
        self:setType()
    end )

    self:setButton(self.Button_month, false)
    self:setType()
    return true
end
function EveryDayBuy:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(212, 197, 180, 255))
    else
        title:setTextColor(cc.c4b(235, 228, 198, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function EveryDayBuy:setType()
    
    if self.DayType == EveryDayBuy.EVERYDAY then      
       me.assignWidget(self,"Panel_Vevr_Discount"):setVisible(true)
       me.assignWidget(self,"Panel_accumulate"):setVisible(false)
       self:setVevrDay()     
    elseif self.DayType == EveryDayBuy.REWARD then
       me.assignWidget(self,"Panel_Vevr_Discount"):setVisible(false)
       me.assignWidget(self,"Panel_accumulate"):setVisible(true) 
       self:setReward()     
    end
end
function EveryDayBuy:setVevrDay()
    local Panel_Table_Node = me.assignWidget(self,"Panel_Table_Node")
    Panel_Table_Node:removeAllChildren()
    local pData =  cfg[CfgType.ETC][user.activityDetail.RechargRewardId]
    local pStrData = me.split(pData["useEffect"],",")

    local pWidth = math.min(565,table.nums(pStrData)*140)
    local pScrollView = cc.ScrollView:create()    
    pScrollView:setViewSize(cc.size(565,145))
    pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    pScrollView:setAnchorPoint(cc.p(0,0))
    pScrollView:setPosition(cc.p(10,147))
    pScrollView:setContentSize(cc.size(pWidth,145))
    Panel_Table_Node:addChild(pScrollView)
    dump(user.activityDetail)
             
    for key, var in pairs(pStrData) do
        local Node = me.assignWidget(self,"Panel_Table_cell"):clone():setVisible(true)
        Node:setAnchorPoint(cc.p(0,0))
        Node:setPosition(cc.p(140*(key-1),10))
        local pButton = me.assignWidget(Node,"Button_bg")
        local pTable = me.split(var,":")
        me.registGuiClickEvent(pButton,function (node)
            showPromotion(me.toNum(pTable[1]),pTable[2])
        end)  
        
        dump(pTable)
        local pcfg = cfg[CfgType.ETC][me.toNum(pTable[1])]
        me.assignWidget(Node, "Goods_Icon"):loadTexture("item_" .. pcfg.icon .. ".png", me.localType)
        me.assignWidget(Node, "Image_quality"):loadTexture(getQuality(pcfg.quality), me.localType)
        local plabel = me.assignWidget(Node, "Text_28")
        plabel:setString(pTable[2])
        pButton:setSwallowTouches(false)
        pScrollView:addChild(Node)
    end       
    local pRecharge = user.recharge[user.activityDetail.RechargeId]  
    local pRice = me.assignWidget(self,"Text_8")
    pRice:setString("￥ "..pRecharge.rmb)
    local pButtonBuy = me.assignWidget(self,"Button_buy")
    if user.activityDetail.isbuy == 1  then
       pButtonBuy:setBright(false)
       pButtonBuy:setTouchEnabled(false)
    else
       pButtonBuy:setBright(true)
       pButtonBuy:setTouchEnabled(true)
    end
    me.registGuiClickEvent(pButtonBuy,function (node)
       if user.activityDetail.isbuy == 0  then
          --NetMan:send(_MSG.worldChat("#45 502"))
          payMgr:getInstance():checkChooseIap(pRecharge)   
       end   
    end)  

end
function EveryDayBuy:setReward()
    local Panel_Reward_node = me.assignWidget(self,"Panel_Reward_node")
     Panel_Reward_node:removeAllChildren()
     local pData = user.activityDetail.TotalRward
     for key, var in pairs(pData) do
        local Node = me.assignWidget(self,"Panel_reward"):clone():setVisible(true)
        Node:setAnchorPoint(cc.p(0,0))
        if key == 3 then
           Node:setPosition(cc.p(185*(key-1)-40,0))
        else
           Node:setPosition(cc.p(185*(key-1),0))
        end
        local ButtonBg = me.assignWidget(Node,"reward_icon")
        local pBool = false
        for Intkey, Intvar in pairs(user.activityDetail.ReceiceReward) do
            if me.toNum(Intkey) == key then
               pBool = true
            end
        end
        local complete = me.assignWidget(Node,"complete")
        complete:setString(var[1].."天")
        local Receive_icon = me.assignWidget(Node,"Receive_icon")
        if pBool then
           Receive_icon:setVisible(true)
        else
           Receive_icon:setVisible(false)
        end
        if user.activityDetail.BuyDayNum >= me.toNum(var[1]) and pBool ==false then
           --
           local ani = createArmature("keji_jiesuo")
           me.assignWidget(Node,"Panel_Animation"):addChild(ani)
           ani:getAnimation():play("donghua")
           print("特效")
        end
         me.registGuiClickEvent(ButtonBg,function (node)
            if user.activityDetail.BuyDayNum >= me.toNum(var[1]) and pBool ==false then
               NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,key))
            else
                local def = cfg[CfgType.ETC][var[2]]     
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData(def.useEffect)
                mainCity:addChild(gdc,me.MAXZORDER)       
            end
            
           end)
         me.assignWidget(Node, "reward_icon"):loadTexture(RewardIcon[key], me.localType)
        Panel_Reward_node:addChild(Node)
    end     
    local pLoadingBar_Reward = me.assignWidget(self,"LoadingBar_Reward")
    pLoadingBar_Reward:setPercent(user.activityDetail.BuyDayNum/(user.activityDetail.TotalBuyDay-1)*100)  
end
function EveryDayBuy:update(msg)   
    if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
        self:setType()
    end
end
function EveryDayBuy:onEnter()
    print("EveryDayBuy onEnter") 
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
	me.doLayout(self,me.winSize)  
end
function EveryDayBuy:onEnterTransitionDidFinish()
	print("EveryDayBuy onEnterTransitionDidFinish") 
end
function EveryDayBuy:onExit()
    print("EveryDayBuy onExit")    
end
function EveryDayBuy:close()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    self:removeFromParentAndCleanup(true)  
end
