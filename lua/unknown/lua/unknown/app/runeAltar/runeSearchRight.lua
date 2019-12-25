runeSearchRight = class("runeSearchRight",function(...)
    return cc.CSLoader:createNode(...)
end)

function runeSearchRight:create(...)
    local layer = runeSearchRight.new(...)
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

function runeSearchRight:ctor()
    print("runeSearchRight:ctor()")
end
function runeSearchRight:init()
    print("runeSearchRight:init()")
    return true
end
function runeSearchRight:onEnter()
    me.doLayout(self,me.winSize)  

    self.todaySearchTimes = me.assignWidget(self, "todaySearchTimes")
    self.searchItemNums1 = me.assignWidget(self, "searchItemNums1")
    self.searchItemNums2 = me.assignWidget(self, "searchItemNums2")
    self.limitTime = me.assignWidget(self, "limitTime")
    self.limitTxt = me.assignWidget(self, "limitTxt")
    self.freeTxt = me.assignWidget(self, "freeTxt")
    self.freetimesTxt = me.assignWidget(self, "freetimesTxt")
    self.costIcon1 = me.assignWidget(self, "costIcon1")
    self.costIcon2 = me.assignWidget(self, "costIcon2")
    self.todayFreeTimes = me.assignWidget(self, "todayFreeTimes")
    self.showItem1 = me.assignWidget(self, "item1")
    self.showItem2 = me.assignWidget(self, "item2")
    self.searchOneBtn = me.assignWidget(self, "searchOneBtn")
    self.searchTenBtn = me.assignWidget(self, "searchTenBtn")
    self.bg = me.assignWidget(self, "bg")

    me.registGuiClickEventByName(self,"item1Click",function ()
        showPromotion(78,self.item1.count)
    end)  
    me.registGuiClickEventByName(self,"item2Click",function ()
        showPromotion(79,self.item2.count)
    end) 
    me.registGuiClickEventByName(self,"detailBtn",function ()
        local runeSearchAward = runeSearchAwardList:create("rune/runeSearchAwardList.csb")
        me.runningScene():addChild(runeSearchAward, me.MAXZORDER)
        runeSearchAward:setData(self.data.runes, self.data.ids)
        me.showLayer(runeSearchAward,"bg")
    end) 
    me.registGuiClickEvent(self.searchOneBtn, handler(self, self.onClineOne))
    me.registGuiClickEvent(self.searchTenBtn, handler(self, self.onClineTen))
    if self.searchOneBtn then
        guideHelper.nextStepByOpt(false,self.searchOneBtn)
    end

    -- 活动等UI红点显示
    self.uiRedPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateUIRedPoint))
end

-- 活动等UI红点显示
function runeSearchRight:updateUIRedPoint()
    if user.UI_REDPOINT.relicBtn[tostring(999)]==1 and self.data.id==1 then
        me.assignWidget(me.assignWidget(self, "searchOneBtn"), "redpoint"):setVisible(true)
    else
        me.assignWidget(me.assignWidget(self, "searchOneBtn"), "redpoint"):setVisible(false)
    end
end

function runeSearchRight:setData(data, item1, item2)
    self.bg:loadTexture("relic/rune_search_bg"..data.id..".png", me.localType)
    self.data = data
    self.item1=item1
    self.item2=item2

    if user.UI_REDPOINT.relicBtn[tostring(999)]==1 and self.data.id==1 then
        me.assignWidget(me.assignWidget(self, "searchOneBtn"), "redpoint"):setVisible(true)
    else
        me.assignWidget(me.assignWidget(self, "searchOneBtn"), "redpoint"):setVisible(false)
    end

    self.showItem1:loadTexture(getItemIcon(item1.id))
    self.showItem2:loadTexture(getItemIcon(item2.id))
    self.searchItemNums1:setString(item1.count)
    self.searchItemNums2:setString(item2.count)

    self.todaySearchTimes:setString((data.max-data.today).."/"..data.max)

    me.clearTimer(self.freeTimeId)
    me.clearTimer(self.pTime)
    if data.time<=0 then
        self.limitTxt:setVisible(false)
    else
        self.limitTxt:setVisible(true)
        self.pTime = me.registTimer(-1, function(dt)
            if self.data.time == 0 then
                me.clearTimer(self.pTime)
            end
            self.data.time = self.data.time - 1
            self.limitTime:setString(me.formartSecTime(self.data.time))
        end , 1)
    end

    self:showOneBtn()
    self:showTenBtn()
    print(data)
end
function runeSearchRight:showTenBtn()
    self.costIcon2:loadTexture(getItemIcon(self.data.tenNeed[1]))
    me.assignWidget(self.costIcon2, "costTxt"):setString(self.data.tenNeed[2])
end

function runeSearchRight:showOneBtn()
    self.costIcon1:loadTexture(getItemIcon(self.data.singleNeed[1]))
    me.assignWidget(self.costIcon1, "costTxt"):setString(self.data.singleNeed[2])

    if self.data.freeNum>=self.data.free then  --免费次数用完
        self.freetimesTxt:setVisible(false)
        self.freeTxt:setVisible(false)

        self.costIcon1:setVisible(true)
    else
        self.costIcon1:setVisible(false)

        self.freeTxt:setVisible(true)
        self.freetimesTxt:setVisible(true)
        self.todayFreeTimes:setString((self.data.free-self.data.freeNum).."/"..self.data.free)
        if self.data.freeTime>0 then   --免费CD中
            self.freeTxt:setVisible(true)
            self.freeTimeId = me.registTimer(-1, function(dt)
                if self.data.freeTime == 0 then
                    me.clearTimer(self.freeTimeId)
                    self.freeTxt:setString("免费")
                    return
                end
                self.data.freeTime = self.data.freeTime - 1
                self.freeTxt:setString("免费 "..me.formartSecTime(self.data.freeTime))
            end , 1)
        else
            self.freeTxt:setString("免费")
        end
    end
end

function runeSearchRight:onClineOne(node)

    if self.data.freeNum>=self.data.free or self.data.freeTime>0 then  --免费次数用完 或者免费CD中
        if self.data.singleNeed[1]==self.item1.id then
            if self.data.singleNeed[2]>self.item1.count then --道具不足，提示花费其它金额
                self:costPrompt(self.item1, self.data.singleNeed[2], self.data.singleNeedType, self.data.singleNeedGem, 1)
            else
                self:requestServer(1)

            end
        else
            if self.data.singleNeed[2]>self.item2.count then --道具不足，提示花费其它金额
                self:costPrompt(self.item2, self.data.singleNeed[2], self.data.singleNeedType, self.data.singleNeedGem, 1)
            else
                self:requestServer(1)
            end
        end
    else
        self:requestServer(1)
    end
end

function runeSearchRight:onClineTen(node)
    if self.data.tenNeed[1]==self.item1.id then
        if self.data.tenNeed[2]>self.item1.count then --道具不足，提示花费其它金额
            self:costPrompt(self.item1, self.data.tenNeed[2], self.data.tenNeedType, self.data.tenNeedGem, 0)
        else

            self:requestServer(0)
        end
    else
        if self.data.tenNeed[2]>self.item2.count then --道具不足，提示花费其它金额
            self:costPrompt(self.item2, self.data.tenNeed[2], self.data.tenNeedType, self.data.tenNeedGem, 0)
        else
            self:requestServer(0)

        end
    end
end

function runeSearchRight:costPrompt(item, needNums, costItemId, costNums, single)
    local confirmView = cc.CSLoader:createNode("runeSearchMsgBox.csb")
    me.doLayout(confirmView, me.winSize)
    me.assignWidget(confirmView, "msg"):setString(item.name)
    me.assignWidget(confirmView, "costIcon1"):loadTexture(getItemIcon(item.id))
    me.resizeImage(me.assignWidget(confirmView, "costIcon1"), 33, 34)
    me.assignWidget(confirmView, "costIcon2"):loadTexture(getItemIcon(costItemId))
    me.resizeImage(me.assignWidget(confirmView, "costIcon2"), 33, 34)

    local costTxt2 = me.assignWidget(confirmView, "costTxt2")
    costTxt2:setString(costNums)
    me.assignWidget(confirmView, "Text_1"):setPositionX(costTxt2:getPositionX()+costTxt2:getContentSize().width+3)

    local costTxt1 = me.assignWidget(confirmView, "costTxt1")
    costTxt1:setString(needNums)
    me.assignWidget(confirmView, "Text_2"):setPositionX(costTxt1:getContentSize().width+3)

    me.registGuiClickEventByName(confirmView, "btn_ok", function(node)
        if costItemId==9008 and costNums>user.diamond then
            askToRechage(2)
            confirmView:removeFromParent()
            return
        elseif costItemId==9017 and costNums>user.paygem then
            askToRechage(1)
            confirmView:removeFromParent()
            return
        end
        self:requestServer(single)
        confirmView:removeFromParent()
    end )
    me.registGuiClickEventByName(confirmView, "btn_cancel", function(node)
        confirmView:removeFromParent()
    end )
    me.runningScene():addChild(confirmView, me.MAXZORDER)
end

function runeSearchRight:requestServer(single)
    self.searchOneBtn:setTouchEnabled(false)
    self.searchTenBtn:setTouchEnabled(false)
    NetMan:send(_MSG.Rune_search_request(1, self.data.id, single))
    showWaitLayer()
end

function runeSearchRight:onExit()
    me.clearTimer(self.freeTimeId)
    me.clearTimer(self.pTime)
    me.RemoveCustomEvent(self.uiRedPointListener)
end

function runeSearchRight:getSearchBtns()
    return self.searchOneBtn, self.searchTenBtn
end
