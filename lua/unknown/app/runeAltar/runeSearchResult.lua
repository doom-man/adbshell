runeSearchResult = class("runeSearchResult", runeSearchRight)

function runeSearchResult:create(...)
    local layer = runeSearchResult.new(...)
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

function runeSearchResult:ctor()
    print("runeSearchResult:ctor()")
end
function runeSearchResult:init()
    print("runeSearchResult:init()")
    return true
end
function runeSearchResult:onEnter()
    me.doLayout(self,me.winSize)  

    self.freeTxt = me.assignWidget(self, "freeTxt")
    self.freetimesTxt = me.assignWidget(self, "freetimesTxt")
    self.costIcon1 = me.assignWidget(self, "costIcon1")
    self.costIcon2 = me.assignWidget(self, "costIcon2")
    self.todayFreeTimes = me.assignWidget(self, "todayFreeTimes")
    self.showItem1 = me.assignWidget(self, "item1")
    self.showItem2 = me.assignWidget(self, "item2")
    self.searchOneBtn = me.assignWidget(self, "searchOneBtn")
    self.searchTenBtn = me.assignWidget(self, "searchTenBtn")
    self.okBtn = me.assignWidget(self, "okBtn")
    self.contentPanel = me.assignWidget(self, "contentPanel")

    me.registGuiClickEvent(self.searchOneBtn, handler(self, self.onClineOne))
    me.registGuiClickEvent(self.searchTenBtn, handler(self, self.onClineTen))
    me.registGuiClickEvent(self.okBtn, function (node)
        me.dispatchCustomEvent("run_search_guide")
        self:close()
    end)

end

function runeSearchResult:requestServer(single)
    superfunc(self, "requestServer", single)
    self:close()
end
function runeSearchResult:close()
    self:removeFromParentAndCleanup(true)
end
function runeSearchResult:setData(data, item1, item2)
    self.data = data
    self.item1=item1
    self.item2=item2

    me.clearTimer(self.freeTimeId)

    self:showOneBtn()
    self:showTenBtn()

    if user.UI_REDPOINT.relicBtn[tostring(999)]==1 then
        removeRedpoint(999)
    end
end

function runeSearchResult:setItemData(data)
    local listData = data.c.list

    local posX = 171/2
    local posY = 0
    local listNums = #listData
    if listNums<6 then
        posY=240
    else
        posY=348
    end

    local animRuneList={}
    for i, v in ipairs(listData) do
        local j = math.floor((i-1)/5)
        local k = (i-1)%5
        local item=nil
        if v.itemType==1 then
            item = BackpackCell:create("backpack/backpackcell.csb")
            v.defid=v.id
            v.count=v.amount
            item:setUI(v)  
            item:setAnchorPoint(0.5, 0.5)   
            item:setPosition(k*171+posX, posY-j*232)  
            me.registGuiClickEventByName(item,"Button_bg",function ()
                showPromotion(v.defid,v.count)
            end)  
            if v.count==1 then
                me.assignWidget(item, "num_bg"):setVisible(false)
            end
        elseif v.itemType==2 then
            v.cfgId=v.defId
            item = runeItem:create("rune/runeItem.csb")
            if listNums>1 then
                item:setScale(0.5)
            end
            item:setData(v)
            item:setAnchorPoint(0.5, 0.5)
            item:setPosition(k*171+posX, posY-j*232)
            if item.lvTxt:getString()=="1" then
                item.lvBox:setVisible(false)
            end

            table.insert(animRuneList, v)
            me.registGuiClickEventByName(item,"box",function ()
                local runeDetail = runeDetailView:create ("rune/runeDetailView.csb")
                me.runningScene():addChild(runeDetail, me.MAXZORDER)
                me.showLayer(runeDetail, "bg")
                runeDetail:setRuneInfo(v)
                runeDetail:hideBtn()
            end)
        end
        self.contentPanel:addChild(item)
    end
    if listNums<6 then
        self.contentPanel:setPositionX(214+(855-listNums*171)/2)
    end
    if #animRuneList>0 then
        me.assignWidget(self, "bg"):setVisible(false)        
        self:createSpecialRuneAnimation(animRuneList, handler(self, self.animPlayOver))
    end
end

function runeSearchResult:animPlayOver()
    me.assignWidget(self, "bg"):setVisible(true)
    if self.okBtn then        
        guideHelper.nextStepByOpt(false,self.okBtn)
    end
end

function runeSearchResult:setCloseCallback(cb)
    self.closeCb = cb
end

function runeSearchResult:onExit()
    print("runeSearchResult:onExit()")
    superfunc(self, "onExit")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    local _ = self.closeCb and self.closeCb()
end

-- 帧动画特效   单位列表runeDataList  -- 结束动画时调用callBackfunc
function runeSearchResult:createSpecialRuneAnimation(runeDataList, callBackfunc)
    local parentNode = cc.Director:getInstance():getRunningScene()
    local rootLayer = parentNode:getChildByName("rootLayer")
    if rootLayer then
        rootLayer:removeFromParent()
    end

    local b = false

    local item = runeItem:create("rune/runeItem.csb")
    item:setAnchorPoint(cc.p(0.5, 0.5))   

    rootLayer = cc.LayerColor:create(cc.c4b(0,0,0,180), me.winSize.width, me.winSize.height)
    rootLayer:setName("rootLayer")
    parentNode:addChild(rootLayer, me.MAXZORDER)
    rootLayer:setPosition(cc.p(0, 0))
    rootLayer:addChild(item, 100)
    item:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))

    -- 卡牌延时显示动画
    local callFunc = function ()
        item:setVisible(true)
        item:setOpacity(0)
        local fadeTo = cc.FadeTo:create(0.3, 255)
        
        item:runAction(cc.Sequence:create(fadeTo, cc.CallFunc:create(function ()
            b = false   
        end)))
    end

    -- 卡牌背景动画
    local bgEffect = cc.Sprite:createWithSpriteFrameName("jianglingkapaibeijing_00000.png")
    bgEffect:setAnchorPoint(cc.p(0.5, 0.5))
    bgEffect:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    bgEffect:setScale(4)  
    rootLayer:addChild(bgEffect, 99)
    local cache = cc.SpriteFrameCache:getInstance()
    local animFrames = { }
    for j = 1, 10 do        
        local frame = cache:getSpriteFrame("jianglingkapaibeijing_0000" .. j - 1 ..".png")
        if frame == nil then
            break
        end
        animFrames[j] = frame
    end

    -- 卡牌前景动画
    local froneEffect = cc.Sprite:createWithSpriteFrameName("gaojikapai_00000.png")
    froneEffect:setAnchorPoint(cc.p(0.5, 0.5))
    froneEffect:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 15))
    froneEffect:setScale(2)  
    rootLayer:addChild(froneEffect, 101)
    local animFrames2 = { }
    for j = 1, 20 do
        local str 
        str = string.format("gaojikapai_000%02d.png", j - 1)
        local frame = cache:getSpriteFrame(str)      
        if frame == nil then
            break
        end
        animFrames2[j] = frame
    end    
    
    local function playGetAnimation()
        b = true

        item:setVisible(false)
        item:stopAllActions()
        me.DelayRun(callFunc, 0.25, item)
        
        bgEffect:stopAllActions() 
        local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.13)
        local ani1 = cc.Animate:create(animation)
        bgEffect:runAction(cc.RepeatForever:create(ani1))
                        
        froneEffect:stopAllActions()
        local animation2 = cc.Animation:createWithSpriteFrames(animFrames2, 0.05)
        local ani2 = cc.Animate:create(animation2)
        froneEffect:runAction(ani2)
    end 
    
    local runeData = runeDataList[1]
    if not runeData then
        rootLayer:removeFromParent()
        if callBackfunc then
            callBackfunc()
        end
        return
    end
    item:setData(runeData)
    if item.lvTxt:getString()=="1" then
        item.lvBox:setVisible(false)
    end

    playGetAnimation()
     
    local index = 1
    local function onTouchBegin(touch, event)
        if b then
            return false      
        else
            return true
        end
    end
    local function onTouchMove(touch, event)
        return true
    end
    local function onTouchEnd(touch, event)
        local nextRuneData = runeDataList[index + 1]
        index = index + 1
        if nextRuneData then 
            item:setData(nextRuneData)
            playGetAnimation()
        else
            rootLayer:removeFromParent()
            if callBackfunc then
                callBackfunc()
            end            
        end    
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED);
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED);
    rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, rootLayer);  
end