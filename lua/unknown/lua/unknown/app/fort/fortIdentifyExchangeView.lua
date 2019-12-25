-- [Comment]
-- jnmo
fortIdentifyExchangeView = class("fortIdentifyExchangeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortIdentifyExchangeView.__index = fortIdentifyExchangeView
function fortIdentifyExchangeView:create(...)
    local layer = fortIdentifyExchangeView.new(...)
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

function fortIdentifyExchangeView:ctor()
    print("fortIdentifyExchangeView ctor")
end
function fortIdentifyExchangeView:init()
    print("fortIdentifyExchangeView init")
    self.Panel_item = me.assignWidget(self, "Panel_item")
    self.Image_UseItem = me.assignWidget(self.Panel_item, "Image_UseItem")    
    self.Node_item = me.assignWidget(self, "Node_item")
    self.Panel_scrollView = me.assignWidget(self, "Panel_scrollView")
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    self.Text_currentNum = me.assignWidget(self, "Text_currentNum")
    self.selectIndex = 1
    self.selectNum = 1
    self.selectTotalNum = 1
    self.itemDetailView = nil
    self.SellDef = {}
    self.selectNode = nil
    me.registGuiTouchEvent(self.Panel_item,function (node,event)
        if event == ccui.TouchEventType.began then
            if self.itemDetailView == nil then
                self.itemDetailView = showHeroMaterialDetail(self.itemData:getDef().id)
                self.itemDetailView:setAnchorPoint(cc.p(0.5, 0.5))
                self.itemDetailView:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
                self:addChild(self.itemDetailView)
            end
        elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
            if self.itemDetailView ~= nil then
                self.itemDetailView:removeFromParent()
                self.itemDetailView = nil
            end
        end
    end)

    self.Button_use = me.registGuiClickEventByName(self, "Button_use", function(node)
        local sellDef = self.SellDef[self.selectIndex]
        local changeData = self:getChangeId(self.itemData:getDef().id)
        NetMan:send(_MSG.worldHeroExchange(changeData.id, sellDef.tid,self.selectNum))
    end )

    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )

    me.registGuiClickEventByName(self, "btn_reduce", function()
        self.selectNum = self.selectNum - 1
        if self.selectNum <= 1 then
            self.selectNum = 1
        end
        self.Slider_worker:setPercent(self.selectNum / self.selectTotalNum * 100)
        self:setSelectItemInfo(self.selectNum,false)

        self.Text_currentNum:setString(self.selectNum.."/"..self.itemData.count)
    end )
    me.registGuiClickEventByName(self, "btn_add", function()
        self.selectNum = self.selectNum + 1
        if self.selectNum >= self.selectTotalNum then
            self.selectNum = self.selectTotalNum
        end
        self.Slider_worker:setPercent(self.selectNum / self.selectTotalNum * 100)
        self:setSelectItemInfo(self.selectNum,false)
        self.Text_currentNum:setString(self.selectNum.."/"..self.itemData.count)
    end )

    -- 监听滑动条信息
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = sender:getPercent() / 100
            self.selectNum = math.floor(percent * self.selectTotalNum)
            if self.selectNum < 1 then
                self.selectNum = 1
                self.Slider_worker:setPercent(self.selectNum / self.selectTotalNum * 100)
                return
            end
            self.Text_currentNum:setString(self.selectNum.."/"..self.itemData.count)
            self:setSelectItemInfo(self.selectNum,false)
            me.buttonState(self.Button_use, me.toNum(self.selectNum) > 0)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)

    return true
end
function fortIdentifyExchangeView:setMaterialData()
    local canUseIDs = self:getMaterialIDs(self.itemData:getDef().id)
    for key, var in pairs(canUseIDs) do
        local etc = cfg[CfgType.ETC][me.toNum(var)]
        table.insert(self.SellDef, etc)
    end
end
function fortIdentifyExchangeView:initList(msg)
    self.SellDef = msg 
    if #self.SellDef <= 0 then --无可兑换材料
        me.buttonState(self.Button_use,false)
        self.Slider_worker:setPercent(0)
        self.Text_currentNum:setString(0)
        return
    end
    self. targetList = {}
    for key, var in pairs(msg) do
       self.targetList[var.tid] = var
    end   
    local pNum = #self.SellDef
    self.listItems = {}
    for var = 1, pNum do
        local def = cfg[CfgType.ETC][self.SellDef[var].tid]
        local pSingleCell = me.assignWidget(self.Node_item,"Panel_item"):clone()
        me.assignWidget(pSingleCell, "ImageView_select"):setVisible(false)
        me.assignWidget(pSingleCell, "Image_quility"):loadTexture(getQuality(def.quality), me.localType)
        me.assignWidget(pSingleCell, "Image_itemIcon"):loadTexture(getItemIcon(def.icon), me.localType)
        me.assignWidget(pSingleCell, "Text_itemNum"):setString(self.itemData.count)
        self.Panel_scrollView:pushBackCustomItem(pSingleCell)        
        me.assignWidget(pSingleCell, "ImageView_select"):setVisible(self.selectIndex == var)
        pSingleCell.idx = var
        self.listItems[var] = pSingleCell
        me.registGuiClickEvent(pSingleCell,function (node)
           if   self.selectNode ~=  node then
                self.selectNode = node
                self.selectIndex = node.idx               
                self:setSelectItemInfo( math.min( self.itemData.count,math.floor( self.targetList[def.id].can/self.targetList[def.id].scale)),true)
           end
        end)
        if self.selectIndex == var then
             self.selectNode = pSingleCell
        end
    end    
    local target = self.targetList[self.SellDef[self.selectIndex].tid]
    self:setSelectItemInfo(math.min( self.itemData.count,math.floor( target.can/target.scale)),true)
end

function fortIdentifyExchangeView:setCurrentItemData(data)
    self.itemData = data
end
function fortIdentifyExchangeView:onEnter()
    print("fortIdentifyExchangeView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_EXCHANGE) then
            if msg.c.result == 1 then
                self:close()    
            end
        elseif checkMsg(msg.t, MsgCode.MSG_SHENJIANG_DUIHUAN) then          
               
                self:setItemInfo()
                self:initList(msg.c.list)
        end
    end )
end

function fortIdentifyExchangeView:setSelectItemInfo(count,b)   
        if b then 
            for key, var in pairs(self.listItems) do
                 me.assignWidget(var, "ImageView_select"):setVisible(self.selectIndex == var.idx)
                 me.assignWidget(var, "Image_bg_num"):setVisible(self.selectIndex == var.idx)
            end        
        end
        self.selectNum = count
        local target = self.targetList[self.SellDef[self.selectIndex].tid]
        self.selectTotalNum = math.min( self.itemData.count,math.floor(target.can/target.scale))
        me.assignWidget(self.selectNode, "Text_itemNum"):setString(count*target.scale)
        self.Slider_worker:setPercent(count / self.selectTotalNum * 100)
        self.Text_currentNum:setString(count.."/"..self.itemData.count)
        me.assignWidget(self.selectNode, "Image_bg_num"):setVisible(true)
        me.assignWidget(self,"Text_Max"):setString("目标今日剩余兑换数量："..target.can .."/"..target.max)
end

function fortIdentifyExchangeView:setItemInfo()
    local tmpDef = self.itemData:getDef()
    self.Image_UseItem:loadTexture(getQuality(tmpDef.quality), me.localType)
    me.assignWidget(self.Image_UseItem, "Image_itemIcon"):loadTexture(getItemIcon(tmpDef.icon), me.localType)
    me.assignWidget(self.Image_UseItem, "Text_itemNum"):setString(self.itemData.count)
end

function fortIdentifyExchangeView:onEnterTransitionDidFinish()
    print("fortIdentifyExchangeView onEnterTransitionDidFinish")
end
function fortIdentifyExchangeView:onExit()
    print("fortIdentifyExchangeView onExit")
    UserModel:removeLisener(self.modelkey)
end
function fortIdentifyExchangeView:close()
    self:removeFromParentAndCleanup(true)
end

function fortIdentifyExchangeView:getMaterialIDs(id)
    local useIds = {}
    for key, var in pairs(cfg[CfgType.HERO_MATERIAL]) do
        if id == me.toNum(var.soureid) then
            local strs = me.split(var.destid,",")        
            for inKey, inVar in pairs(strs) do
                useIds[#useIds+1] = me.toNum(inVar)
            end
        end
    end
    return useIds
end

function fortIdentifyExchangeView:getChangeId(id)
    for key, var in pairs(cfg[CfgType.HERO_MATERIAL]) do
        if me.toNum(var.soureid) == id then
            return var
        end
    end
end