vipView = class("vipView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
vipView.__index = vipView
function vipView:create(...)
    local layer = vipView.new(...)
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
function vipView:ctor()
    print("vipView ctor")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.isLoaded = { }
    self.vipTime = nil
    self.tableViews = { }
    self.haveSet = false
    self.changing = false
end
EVENT_VIP_UI_UPDATE = "EVENT_VIP_UI_UPDATE"
function vipView:close()
    self:removeFromParentAndCleanup(true)
end
function vipView:init()
    print("vipView init")
    self.touchLayer = ccui.Layout:create()
    self.touchLayer:setContentSize(cc.size(617, 573))
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setSwallowTouches(false)
    self.Text_NeedGold_0 = me.assignWidget(self, "Text_Gold")
    self.Text_NeedGold_txt = me.assignWidget(self, "Text_NeedGold_txt")
    self.Text_NeedGold_vip = me.assignWidget(self, "Text_NeedGold_vip")
    local function onTouchBegan(touch, event)
        -- self.tableViews[self.improvePv:getCurPageIndex()]:setTouchEnabled(false)
        self.improvePv:setTouchEnabled(false)
        self.startP = touch:getLocation()
        return true
    end
    local function onTouchMoved(touch, event)
        if not self.haveSet then
            local delta = touch:getDelta()
            if math.abs(delta.x) < 5 and math.abs(delta.y) < 5 then
                return
            else
                local mp = touch:getLocation()
                local dx = math.abs(mp.x - self.startP.x)
                local dy = math.abs(mp.y - self.startP.y)
                local tan = dy / dx
                if tan > 1 then
                    -- self.tableViews[self.improvePv:getCurPageIndex()]:setTouchEnabled(true)
                    self.haveSet = true
                else
                    self.improvePv:setTouchEnabled(true)
                    self.haveSet = true
                end
            end
        end
    end
    local function onTouchEnded(touch, event)
        self.haveSet = false
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.touchLayer)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    self.improvePv = me.assignWidget(self, "improvePv")
    self.curLevel = user.vip
    self.curExp = user.vipExp
    self.todayExp = user.todayExp
    self.arrow = me.assignWidget(self, "toEnable")
    self.enableBtn = me.assignWidget(self, "enableBtn")
    local levelNum = #cfg[CfgType.VIP_LEVEL]
    if self.curLevel == levelNum then
        self.upExp = cfg[CfgType.VIP_DF][self.curLevel].exp
    else
        self.upExp = cfg[CfgType.VIP_DF][self.curLevel + 1].exp
    end
    me.assignWidget(self, "curIcon"):loadTexture("lingzhu_icon_" ..(getCenterBuildingTime() + 1) .. ".png", me.localType)
    me.assignWidget(self, "vipNum"):setString(self.curLevel)
    me.assignWidget(self, "curVipNum"):setString(self.curLevel)
    me.assignWidget(self, "nextVipNum"):setString(self.curLevel + 1)
    me.assignWidget(self, "proNum"):setString(self.curExp .. "/" .. self.upExp)
    me.assignWidget(self, "LoadingBar_2"):setPercent(math.floor(self.curExp / self.upExp * 100))
    me.assignWidget(self, "pointNum"):setString(self.todayExp)

    local function callFuncPv(pSender, eventType)
        if eventType == 0 then
            local idx = nil
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                idx = pSender:getCurPageIndex()
            else
                idx = pSender:getCurrentPageIndex()
            end
            if idx ~= 0 and idx ~= 19 then
                if self.isLoaded[idx + 2] == false then
                    local body = self:createImproveBody(idx + 2)
                    if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                        self.improvePv:addWidgetToPage(body, idx + 1, false)
                    else
                        local layout = self.improvePv:getItem(idx + 1)
                        layout:addChild(body)
                    end
                    self.isLoaded[idx + 2] = true
                elseif self.isLoaded[idx] == false then
                    local body = self:createImproveBody(idx)
                    if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                        self.improvePv:addWidgetToPage(body, idx - 1, false)
                    else
                        local layout = self.improvePv:getItem(idx - 1)
                        layout:addChild(body)
                    end
                    self.isLoaded[idx] = true
                else
                    return
                end
            end
        end

    end
    self.updateTimer = me.registTimer(-1, function(dt)
        local idx = nil
        if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            idx = self.improvePv:getCurPageIndex()
        else
            idx = self.improvePv:getCurrentPageIndex()
        end
        self.Image_Left_arr:setVisible(idx ~= 0)
        self.Image_right_arr:setVisible(idx ~= 19)
    end , 0.3)

    if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
        self.improvePv:addEventListenerPageView(callFuncPv)
    else
        self.improvePv:addEventListener(callFuncPv)
    end
    self.Image_Left_arr = me.registGuiClickEventByName(self, "Image_Left_arr", function(node)
        if self.changing == false then
            me.clickAni5(node)
            local idx = nil
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                idx = self.improvePv:getCurPageIndex()
            else
                idx = self.improvePv:getCurrentPageIndex()
            end
            if idx > 0 then
                self.improvePv:scrollToPage(idx - 1)
            end
            self.changing = true
            me.DelayRun( function(node)
                self.changing = false
            end , 1)
        end
    end )
    self.Image_right_arr = me.registGuiClickEventByName(self, "Image_right_arr", function(node)
        if self.changing == false then
            me.clickAni5(node)
            local idx = nil
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                idx = self.improvePv:getCurPageIndex()
            else
                idx = self.improvePv:getCurrentPageIndex()
            end
            if idx < 19 then
                self.improvePv:scrollToPage(idx + 1)
            end
            self.changing = true
            me.DelayRun( function(node)
                self.changing = false
            end , 1)
        end
    end )

    if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
        self.improvePv:setUsingCustomScrollThreshold(true)
        self.improvePv:setCustomScrollThreshold(100)
    end
    for i = 1, levelNum do
        self.isLoaded[i] = false
        local layout = ccui.Layout:create()
        if (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            layout:setContentSize(self.improvePv:getContentSize())
            layout:setSwallowTouches(true)
            -- layout:setTouchEnabled(false)
        end
        self.improvePv:addPage(layout)
    end
    if self.curLevel == 1 then
        for level = 1, 2 do
            local body = self:createImproveBody(level)
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                self.improvePv:addWidgetToPage(body, level - 1, false)
            else
                local layout = self.improvePv:getItem(level - 1)
                layout:addChild(body)
            end

            self.isLoaded[level] = true
        end
    elseif self.curLevel == levelNum - 1 or self.curLevel == levelNum then
        for level = levelNum - 2, levelNum do
            local body = self:createImproveBody(level)
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                self.improvePv:addWidgetToPage(body, level - 1, false)
            else
                local layout = self.improvePv:getItem(level - 1)
                layout:addChild(body)
            end
            self.isLoaded[level] = true
        end
    else
        for level = self.curLevel - 1, self.curLevel + 1 do
            local body = self:createImproveBody(level)
            if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
                self.improvePv:addWidgetToPage(body, level - 1, false)
            else
                local layout = self.improvePv:getItem(level - 1)
                layout:addChild(body)
            end
            self.isLoaded[level] = true
        end
    end
    if self.curLevel == levelNum then
        if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            self.improvePv:setCurPageIndex(self.curLevel - 1)
        else
            self.improvePv:scrollToPage(self.curLevel - 1, 0)
        end
    else
        if not(targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            self.improvePv:setCurPageIndex(self.curLevel - 1)
        else
            self.improvePv:scrollToPage(self.curLevel - 1, 0)
        end
    end
    -- 9017:8|924|380&904|0

    me.registGuiClickEventByName(self, "enableBtn", function(node)
        local vipShop = vipShopView:create("vipShopView.csb")
        vipShop:initVipShop(1)
        self:addChild(vipShop)
        me.showLayer(vipShop, "bg")
    end )
    me.registGuiClickEventByName(self, "getBtn", function(node)
        local vipShop = vipShopView:create("vipShopView.csb")
        vipShop:initVipShop(2)
        self:addChild(vipShop)
        me.showLayer(vipShop, "bg")
    end )
    if user.vipTime and user.vipTime > 0 then
        self:setVipTime()
    end
    me.assignWidget(self, "bg_right"):addChild(self.touchLayer)

    me.registGuiClickEventByName(self, "Button_VipShop", function(node)
        local vshop = vipLevelShop:create("vipLevelShopView.csb")
        me.popLayer(vshop)
    end )

    me.registGuiClickEventByName(self, "levelBtn", function(node)
        if self.curLevel < 20 then
            local vshop = MessageBoxVip:create("MessageBox_Vip.csb")
            vshop:initWithData(self.upExp - self.curExp, self.curLevel + 1)
            me.popLayer(vshop)
        else
            showTips("VIP等级已达到最大")
        end
    end )

    return true
end

function vipView:revMsg(msg)
    if checkMsg(msg.t, MsgCode.ROLE_VIP_UPDATE) then
        self:close()
        local parent = mainCity or pWorldMap
        if parent and parent.showVipView then
            parent:showVipView()
        end
    end
end
function vipView:initDayGift(body, level)
    local def = cfg[CfgType.VIP_DF][level]
    local pkgdata = def.pkgdata
    local _, _, cost_itemid, cost_num, buy_itemid, cost, gift_itemid, _ = string.find(pkgdata, "(%d+):(%d+)|(%d+)|(%d+)&(%d+)|(%d+)")
    local dayItem = me.assignWidget(body, "dayItem")
    dayItem:ignoreContentAdaptWithSize(true)
    dayItem:loadTexture(getItemIcon(tonumber(gift_itemid)), me.localType)
    local giftItem = me.assignWidget(body, "giftItem")
    giftItem:ignoreContentAdaptWithSize(true)
    giftItem:loadTexture(getItemIcon(tonumber(buy_itemid)), me.localType)
    local cost_icon = me.assignWidget(body, "cost_icon")
    -- cost_icon:ignoreContentAdaptWithSize(true)
    cost_icon:loadTexture(getItemIcon(tonumber(cost_itemid)), me.localType)
    local cost_item = me.assignWidget(body, "cost_item")
    cost_item:setString(cost)
    local cost_icon_0 = me.assignWidget(body, "cost_icon_0")
    -- cost_icon_0:ignoreContentAdaptWithSize(true)
    cost_icon_0:loadTexture(getItemIcon(tonumber(cost_itemid)), me.localType)
    local cost_item_0 = me.assignWidget(body, "cost_item_0")
    cost_item_0:setString(cost_num)
    me.registGuiClickEvent(dayItem, function(node)

        local def = cfg[CfgType.ETC][tonumber(gift_itemid)]
        local gdc = giftDetailCell:create("giftDetailCell.csb")
        gdc:setItemData(def.useEffect)
        me.popLayer(gdc)
    end )
    me.registGuiClickEvent(giftItem, function(node)
        local def = cfg[CfgType.ETC][tonumber(buy_itemid)]
        local gdc = giftDetailCell:create("giftDetailCell.csb")
        gdc:setItemData(def.useEffect)
        me.popLayer(gdc)
    end )
    self.Button_Free = me.registGuiClickEventByName(body, "Button_Free", function(args)
        NetMan:send(_MSG.buyVipDayGift(0, 0))
    end )
    me.setButtonDisable(self.Button_Free, false)
    if self.curLevel == level then
        me.setButtonDisable(self.Button_Free, user.iget_free == false)
    end
    -- self.Button_Free:setVisible(level >= self.curLevel  )
    if level < self.curLevel then
        me.assignWidget(body, "tipsTxt"):setVisible(true)
        me.assignWidget(body, "tipsTxt2"):setVisible(false)
    else
        me.assignWidget(body, "tipsTxt"):setVisible(false)
        me.assignWidget(body, "tipsTxt2"):setVisible(true)
    end
    self.Button_Buy = me.registGuiClickEventByName(body, "Button_Buy", function(args)
        if tonumber(user.paygem) >= tonumber(cost_num) then
            local tempStr = string.format("确定消耗%s元宝购买此礼包吗?", cost_num)
            me.showMessageDialog(tempStr, function(name)
                if name == "ok" then
                    NetMan:send(_MSG.buyVipDayGift(level, 1))
                end
            end )
        else
            askToRechage(1)
        end
    end )
    me.setButtonDisable(self.Button_Buy, false)
    local ibuy = false
    for key, var in pairs(user.vip_buys) do
        if tonumber(level) == tonumber(var) then
            ibuy = true
        end
    end
    if ibuy == false and self.curLevel >= level then
        self.Button_Buy:setTitleText("点击购买")
        me.setButtonDisable(self.Button_Buy, true)
    else
        if self.curLevel < level then
            self.Button_Buy:setTitleText("点击购买")
        else
            self.Button_Buy:setTitleText("已购买")
        end
    end
    if self.curLevel < 20 then
        self.Text_NeedGold_0:setString(self.upExp - self.curExp)
        self.Text_NeedGold_vip:setString("VIP" ..(self.curLevel + 1))

        me.putNodeOnRight(self.Text_NeedGold_0, self.Text_NeedGold_txt, 2, cc.p(0, 2))
        me.putNodeOnRight(self.Text_NeedGold_txt, self.Text_NeedGold_vip, 2, cc.p(0, 2))

    else
        me.assignWidget(self, "Text_NeedGold"):setVisible(false)
        self.Text_NeedGold_0:setVisible(false)
        self.Text_NeedGold_vip:setVisible(false)
        self.Text_NeedGold_txt:setVisible(false)
    end
end
function vipView:onEnter()
    print("vipView onEnter")
    me.doLayout(self, me.winSize)
    self:arrowAnimation()
    self.modelkey = UserModel:registerLisener( function(msg)
        self:revMsg(msg)
    end )
end
function vipView:enterTransitionFinish()

end
function vipView:onExit()
    print("vipView onExit")
    if self.timer then
        me.clearTimer(self.timer)
    end
    me.clearTimer(self.updateTimer)
    UserModel:removeLisener(self.modelkey)
end

function vipView:initImproveTable(body, info, pageIdx)
    local num = math.ceil(#info / 2)
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 590, 100
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local improveCell = me.assignWidget(self, "improveCell"):clone():setVisible(true)
            self:initImproveCell(improveCell, info, idx)
            cell:addChild(improveCell)
        else
            local improveCell = me.assignWidget(cell, "improveCell")
            self:initImproveCell(improveCell, info, idx)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        return num
    end
    if self.tableViews[pageIdx] then
        self.tableViews[pageIdx]:removeFromParent()
    end
    self.tableViews[pageIdx] = cc.TableView:create(cc.size(590, 446))
    self.tableViews[pageIdx]:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableViews[pageIdx]:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableViews[pageIdx]:setPosition(cc.p(0, 8))
    self.tableViews[pageIdx]:setDelegate()
    body:addChild(self.tableViews[pageIdx])
    self.tableViews[pageIdx]:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableViews[pageIdx]:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableViews[pageIdx]:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableViews[pageIdx]:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableViews[pageIdx]:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableViews[pageIdx]:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableViews[pageIdx]:reloadData()
end

function vipView:initImproveCell(cell, info, idx)

    if (idx * 2 + 1) <= table.nums(info) then
        local data = info[idx * 2 + 1]
        me.assignWidget(cell, "lowDesc"):setString(data.name)
        me.assignWidget(cell, "lowValue"):setString(data.beforetxt)
        me.assignWidget(cell, "lowIcon"):loadTexture("icon_tech_" .. data.icon .. ".png", me.localType)
        me.assignWidget(cell, "isnew_low"):setVisible(data.isnew == 1)
        if (idx * 2 + 2) <= table.nums(info) then
            data = info[idx * 2 + 2]
            me.assignWidget(cell, "highDesc"):setString(data.name)
            me.assignWidget(cell, "highValue"):setString(data.beforetxt)
            me.assignWidget(cell, "highIcon"):loadTexture("icon_tech_" .. data.icon .. ".png", me.localType)
            me.assignWidget(cell, "Image_72"):setVisible(false)
            me.assignWidget(cell, "high"):setVisible(true)
            me.assignWidget(cell, "highDesc"):setVisible(true)
            me.assignWidget(cell, "highValue"):setVisible(true)
            me.assignWidget(cell, "highIcon"):setVisible(true)
            me.assignWidget(cell, "isnew_high"):setVisible(data.isnew == 1)
        else
            me.assignWidget(cell, "high"):setVisible(false)
            me.assignWidget(cell, "highDesc"):setVisible(false)
            me.assignWidget(cell, "highValue"):setVisible(false)
            me.assignWidget(cell, "highIcon"):setVisible(false)
            me.assignWidget(cell, "Image_72"):setVisible(false)
            me.assignWidget(cell, "highIcon"):setVisible(false)
            me.assignWidget(cell, "isnew_high"):setVisible(false)
        end
    end
end

function vipView:createImproveBody(level)
    local body = me.assignWidget(self, "improveBody"):clone():setVisible(true)
    -- me.assignWidget(body, "lowVipNum"):setString(level)
    -- me.assignWidget(body, "highVipNum"):setString(level + 1)
    local info = cfg[CfgType.VIP_LEVEL][level]
    local function comp(a, b)
        return a.order < b.order
    end
    table.sort(info, comp)
    me.assignWidget(body, "Text_vip_gift"):setString("VIP " .. level .. " 专属礼包")
    me.assignWidget(body, "Text_34"):setString("VIP " .. level .. " 增益效果")
    dump(level)
    self:initImproveTable(body, info, level - 1)
    self:initDayGift(body, level)
    return body
end

function vipView:setVipTime()
    self.vipTime = math.floor(user.vipTime / 1000) -(os.time() - user.vipLastUpdateTime)
    if self.vipTime > 0 then
        me.assignWidget(self, "toEnable"):setVisible(false)
        me.assignWidget(self, "Text_27"):setVisible(false)
        me.assignWidget(self, "restTime"):setVisible(true)
        self.enableBtn:loadTextureNormal("vip_tubiao_shijian_liang.png", me.localType)
        local timeAni = createArmature("i_button_activit_1")
        timeAni:setScale(0.43)
        timeAni:setPosition(cc.p(self.enableBtn:getContentSize().width / 2 + 2, self.enableBtn:getContentSize().height / 2))
        self.enableBtn:addChild(timeAni)
        timeAni:getAnimation():play("i_button_activity")
        me.clearTimer(self.timer)
        local textTimer = me.assignWidget(self, "restTime")
        textTimer:setString(me.formartSecTime(self.vipTime))
        self.timer = me.registTimer(-1, function(dt)
            self.vipTime = self.vipTime - 1
            textTimer:setString(me.formartSecTime(self.vipTime))
            if self.vipTime <= 0 then
                textTimer:setString(me.formartSecTime(0))
                me.clearTimer(self.timer)
                self.timer = nil
            end
        end , 1)


        local btn_VipShop = me.assignWidget(self, "Button_VipShop")
        local timeAni = createArmature("i_button_activit_1")
        timeAni:setScale(0.73)
        timeAni:setPosition(cc.p(2, 2))
        me.assignWidget(self, "animNode"):addChild(timeAni)
        timeAni:getAnimation():play("i_button_activity")
    end
end

function vipView:arrowAnimation()
    local move = cc.MoveBy:create(1, cc.p(-25, 0))
    local moveBack = move:reverse()
    local seq = cc.Sequence:create(move, moveBack)
    local easeOut = cc.EaseInOut:create(seq, 2)
    self.arrow:runAction(cc.RepeatForever:create(easeOut))
end