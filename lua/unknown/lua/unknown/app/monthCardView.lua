monthCardView = class("monthCardView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
monthCardView.__index = monthCardView

monthCardView_monthButton = 1
monthCardView_weekButton = 2
function monthCardView:create(...)
    local layer = monthCardView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function monthCardView:ctor()
    print("monthCardView ctor")
    self.currentBtnID = nil
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        self:close()
    end )
end

function monthCardView:close()
    mainCity.monthCardView = nil
    self:removeFromParentAndCleanup(true)
end

MONTHCARD_ID = 7
function monthCardView:init()
    print("monthCardView init")
    self.Button_month = me.assignWidget(self,"Button_month")
    self.Button_week = me.assignWidget(self,"Button_week")
    self.Panel_pageIndex = me.assignWidget(self,"Panel_pageIndex")
    self.Panel_PageView = me.assignWidget(self,"Panel_PageView")
    self.pages = {}
    self.monthData = {}
    self.weekData = {}

    me.registGuiClickEvent(self.Button_month,function ()
        self:swichButton(monthCardView_monthButton)
    end)

    me.registGuiClickEvent(self.Button_week,function ()
        self:swichButton(monthCardView_weekButton)
    end)

    self.PageView = ccui.PageView:create()
    self.PageView:setContentSize(cc.size(self.Panel_PageView:getContentSize().width,self.Panel_PageView:getContentSize().height))
    self.PageView:setTouchEnabled(true)
    self.PageView:setDirection(ccui.PageViewDirection.HORIZONTAL)
    self.Panel_PageView:addChild(self.PageView)

    self.PageView:addEventListener(function (sender,event)
        if event==ccui.PageViewEventType.turning then
            local index = self.PageView:getCurPageIndex()
            self:setCurrentPageIndex(index+1)
        end
    end)

    return true
end

function monthCardView:swichButton(buttonID)
    self.currentBtnID = buttonID
    me.buttonState(self.Button_month,buttonID ~= monthCardView_monthButton)
    me.buttonState(self.Button_week,buttonID ~= monthCardView_weekButton)
    if buttonID == monthCardView_monthButton then
        self:initMonthView()
    elseif buttonID == monthCardView_weekButton then
        self:initWeekView()
    end
end

function monthCardView:initPageIndex(total)
    self.Panel_pageIndex:removeAllChildren()
    me.tableClear(self.pages)
    self.pages= {}
    local W = self.Panel_pageIndex:getContentSize().width
    for var = 1, total do
        local pageCell =ccui.ImageView:create()
        if var == 1 then
            pageCell:loadTexture("yueka_dian_lv.png", me.localType)
        else
            pageCell:loadTexture("yueka_dian_hui.png", me.localType)
        end
        self.pages[var] = pageCell
        self.Panel_pageIndex:addChild(self.pages[var])
        self.pages[var]:setPosition(cc.p(W-18*(total-var+1),0))
    end
end

function monthCardView:setCurrentPageIndex(index)
    for key, var in pairs(self.pages) do
        if me.toNum(key) == index then
            var:loadTexture("yueka_dian_lv.png", me.localType)
        else
            var:loadTexture("yueka_dian_hui.png", me.localType)
        end
    end
end

function monthCardView:initWeekView()
    self.PageView:removeAllPages()
    me.tableClear(self.weekData)
    self.weekData = {}
    for key, var in pairs(user.monthWeekInfos) do
        if var and me.toNum(var.type) == 1 then
            self.weekData[#self.weekData+1] = var
        end
    end
    self:initPageIndex(#self.weekData)
    local Node_Panel_week = me.createNode("Node_Panel_week.csb")
    for key, var in pairs(self.weekData) do
        local  cell = me.assignWidget(Node_Panel_week, "Panel_week"):clone()
        cell:setVisible(true)
        local itemData = user.recharge[var.id]
        if itemData == nil then
            __G__TRACKBACK__(" user.recharge[.."..var.id.."] is nil !!!!")
            return
        end
        me.assignWidget(cell,"Image_bg"):loadTexture("yuka_beijing_"..var.id..".png",me.localType)
        local buyBtn = me.assignWidget(cell,"buyBtn")
        buyBtn:setTitleText("只要￥"..itemData.rmb)
        local AtlasLabel_diamond = me.assignWidget(cell,"AtlasLabel_diamond")
        AtlasLabel_diamond:setString(itemData.diamond)
        local Image_diamond = me.assignWidget(cell,"Image_diamond")
        Image_diamond:setPosition(cc.p(AtlasLabel_diamond:getContentSize().width+10,20))
        if me.toNum(var.rnm) < me.toNum(var.limit) then --还可以购买
            me.assignWidget(cell,"Text_limited"):setString("限购"..var.limit-var.rnm.."次")            
            me.assignWidget(cell,"Text_limited"):setTextColor(me.convert3Color_("eaff00"))
            me.buttonState(buyBtn,true)
            buyBtn:setTitleColor(COLOR_WHITE)
        else --达到购买上限
            me.assignWidget(cell,"Text_limited"):setString("达到上限")            
            me.assignWidget(cell,"Text_limited"):setTextColor(COLOR_GRAY)
            buyBtn:setTitleColor(COLOR_GRAY)
            me.buttonState(buyBtn,false)
        end

        me.assignWidget(cell,"Text_decri"):setString(var.content)
        me.assignWidget(cell,"title_inside"):setString(var.title)
        local Panel_itemList = me.assignWidget(cell,"Panel_itemList")   
        if var.status == -1 and me.toNum(var.rnm) < me.toNum(var.limit) then
            me.buttonState(buyBtn,true)
            me.registGuiClickEvent(buyBtn,function (node)
--                NetMan:send(_MSG.worldChat("#45 "..itemData.id))
                payMgr:getInstance():checkChooseIap(itemData)
            end)
            me.assignWidget(cell,"restTime"):setVisible(false)
        elseif var.status == 0 then --可领取
            me.buttonState(buyBtn,true)
            me.assignWidget(cell,"restTime"):setVisible(true)
            me.assignWidget(cell,"restTime"):setString("剩余时间："..var.day .. "天")
            buyBtn:setTitleText("可领取")
            buyBtn:setTitleColor(COLOR_WHITE)
            me.registGuiClickEvent(buyBtn, function(node)
                print("领取周卡")
                NetMan:send(_MSG.getMonth(var.id))
            end )
        elseif var.status == 1 then --已领取
            me.buttonState(buyBtn,false)
            buyBtn:setTitleText("已领取")
            me.assignWidget(cell,"restTime"):setVisible(true)
            me.assignWidget(cell,"restTime"):setString("剩余时间："..var.day .. "天")
        end

        --加载奖励道具列表
        local list = ccui.ListView:create()  
        list:setBounceEnabled(true)
        list:setDirection(ccui.ListViewDirection.horizontal)
        list:setContentSize(cc.size(Panel_itemList:getContentSize().width, Panel_itemList:getContentSize().height))   
        local Node_Panel_item = me.createNode("Node_Panel_item.csb")
        local item = me.assignWidget(Node_Panel_item, "Panel_item")
        item:setVisible(true)
        list:setItemModel(item)
        for inKey, inVar in pairs(var.items) do           
            local def = cfg[CfgType.ETC][me.toNum(inVar[1])]
            if def == nil then
                __G__TRACKBACK__("itemid = "..inVar[1].." is nil !!!!")
                return
            end
            me.assignWidget(item,"Image_quality"):loadTexture(getQuality(def.quality), me.localType)
            me.assignWidget(item,"label_num"):setString(inVar[2])
            me.assignWidget(item,"Goods_Icon"):loadTexture("item_"..def.icon..".png")
            me.registGuiClickEventByName(item,"Panel_item", function (node)               
                showPromotion(inVar[1],inVar[2])
            end)
            list:pushBackDefaultItem()
        end    
        Panel_itemList:addChild(list)      
        self.PageView:insertPage(cell,me.toNum(key))
    end   
end

function monthCardView:initMonthView()
    self.PageView:removeAllPages()
    me.tableClear(self.monthData)
    self.monthData = {}
    for key, var in pairs(user.monthWeekInfos) do
        if var and me.toNum(var.type) == 2 then
            self.monthData[#self.monthData+1] = var
        end
    end
    self:initPageIndex(#self.monthData)
    local Node_Panel_month = me.createNode("Node_Panel_month.csb")
    for key, var in pairs(self.monthData) do
        local cell = me.assignWidget(Node_Panel_month, "Panel_month"):clone()
        cell:setVisible(true)
        local itemData = user.recharge[var.id]
        local buyBtn = me.assignWidget(cell,"buyBtn")
        
        if var and me.toNum(var.day) <= 0 then --再次购买按钮
            me.assignWidget(cell,"againBtn"):setVisible(false)
            me.assignWidget(cell,"againText"):setVisible(false)
            me.assignWidget(cell,"buyDay"):setVisible(true)
            me.assignWidget(cell,"buyDay"):setString("持续"..var.total.."天")
        else
            local againBtn = me.assignWidget(cell,"againBtn")
            againBtn:setVisible(true)
            me.assignWidget(cell,"buyDay"):setVisible(false)
            me.assignWidget(cell,"againText"):setVisible(true)
            me.buttonState(againBtn,true)
            me.assignWidget(cell,"againText"):setString(var.content)
            againBtn:setTitleColor(cc.c3b(255, 255, 255))
            me.registGuiClickEvent(againBtn, function(node)
--                NetMan:send(_MSG.worldChat("#45 "..itemData.id))
                payMgr:getInstance():checkChooseIap(itemData)
                me.setWidgetCanTouchDelay(node,1)
            end )
        end

        if var and var.status == - 1 then --未购买
            buyBtn:setVisible(true)
            me.registGuiClickEvent(buyBtn,function (node)
--                NetMan:send(_MSG.worldChat("#45 "..itemData.id))
                payMgr:getInstance():checkChooseIap(itemData)
            end)
            me.assignWidget(cell,"restTime"):setVisible(false)
        else --可领取/已领取
            me.assignWidget(cell,"restTime"):setVisible(true)
            me.assignWidget(cell,"restTime"):setString("剩余时间："..var.day .. "天")
            if var.status == 0 then --可领取
                buyBtn:setTitleText("领取")
                buyBtn:setVisible(true)
                me.registGuiClickEvent(buyBtn, function(node)
                    print("领取月卡")
                    NetMan:send(_MSG.getMonth(var.id))
                end )
            elseif var.status == 1 then --已经领取
                buyBtn:setEnabled(false)
                buyBtn:setTitleText("已领取")
                buyBtn:setVisible(true)
                buyBtn:setTitleColor(me.convert3Color_("848484"))
            end
            me.assignWidget(cell,"buyDay"):setVisible(false)
            me.assignWidget(cell,"restTime"):setVisible(true)
        end

        for inkey, invar in pairs(var.items) do
            if me.toNum(invar[1]) == 9008 then
                me.assignWidget(cell,"AtlasLabel_diamond"):setString(invar[2])
            end
        end
        me.assignWidget(cell,"title_inside"):setString(var.title)
        me.assignWidget(cell,"price"):setString("￥"..itemData.rmb)
        me.assignWidget(cell,"describe"):setString("购买立即获得"..itemData.diamond.."钻石")
        self.PageView:insertPage(cell,me.toNum(key))
    end
end

function monthCardView:updateState(msg)
    if checkMsg(msg.t, MsgCode.UPDATE_MONTH) then
        showTips("购买成功")
        if self.currentBtnID == monthCardView_monthButton then
            self:initMonthView()
        elseif self.currentBtnID == monthCardView_weekButton then
            self:initWeekView()
        end
    end
end
function monthCardView:onEnter()
    print("monthCardView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:updateState(msg)
    end )
    self:swichButton(monthCardView_monthButton)
end
function monthCardView:enterTransitionFinish()
end
function monthCardView:onExit()
    print("monthCardView onExit")
    UserModel:removeLisener(self.modelkey)
    mainCity.monthCardView = nil
end