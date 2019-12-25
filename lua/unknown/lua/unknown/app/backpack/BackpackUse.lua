-- 道具使用    2015-12-03
BackpackUse = class("BackpackUse", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
BackpackUse.__index = BackpackUse
function BackpackUse:create(...)
    local layer = BackpackUse.new(...)
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
BackpackUse.WarshipTech = 2  -- 战舰科技升级
function BackpackUse:ctor()
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        local pTouch = node:getTouchBeganPosition()
        local pNode = me.assignWidget(self, "Node_size")
        pNode:setContentSize(cc.size(700, 386))
        pNode:setAnchorPoint(cc.p(0.5, 0.5))
        local pPoint = self:contains(pNode, pTouch.x, pTouch.y)
        if pPoint then
            -- 点击在节点中
        else
            -- 点击在节点外
            self:close()
        end
    end )
    self.BackUseType = 1
    --
    self.WarshipType = 0
    self.Warshiporder = 0
    self.itemNum = 0
end
function BackpackUse:setTypee(pType)
    self.BackUseType = pType
end
function BackpackUse:setWarship(type, order, itemNum)
    self.WarshipType = type
    self.Warshiporder = order
    self.itemNum = itemNum
end
-- 判断是否点击在节点中
function BackpackUse:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end
function BackpackUse:close()
    self:removeFromParentAndCleanup(true)
end
function BackpackUse:setParent(pParent)
    self.mParent = pParent
end
function BackpackUse:init()
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    me.registGuiClickEventByName(self, "btn_ok", function(node)
        if tonumber( self.editBox:getText() ) ~= self.pUseNum then
             self.pUseNum = tonumber( self.editBox:getText() ) or 1
        end
        if self.BackUseType == BackpackUse.WarshipTech then
            self.itemNum = self.pUseNum
            NetMan:send(_MSG.Ship_Tech_up(self.WarshipType, self.Warshiporder, self.mCfgid, self.itemNum))
        else
            self:GoodsUse()
        end

        self:close()
    end )

    me.registGuiClickEventByName(self, "maxBtn", function(node)
        self.pUseNum = self.pHaveNum
        local pPercent =(self.pUseNum / self.pHaveNum) * 100
        self.pSliber:setPercent(pPercent)
        self:setUI(self.pUseNum)
    end)
    return true
end
function BackpackUse:GoodsUse()
    if me.toNum(self.pUseNum) >= 1 then
        if self.mParent and self.mParent.setUseNum then
            self.mParent:setUseNum(self.pUseNum)
            self.mParent.mUseDefid = self.mCfgid
        end

        if self.pCfgData.useType== 126 then
            NetMan:send(_MSG.Ship_exp_buy(user.curSelectShipType, self.pCfgData.id, self.pUseNum))
        else
            NetMan:send(_MSG.itemUse(self.pUid, self.pUseNum))
        end
    end
end

-- 点击的物品数据
function BackpackUse:setData(pData)
    if pData ~= nil then
        self.pHaveNum = me.toNum(pData["count"])
        -- 拥有的道具数量
        --        dump(pData)
        self.pUid = pData["uid"]
        self.pUseNum = me.toNum(self.pHaveNum)
        -- 要使用的道具数量
        local pCfgid = pData["defid"]
        self.mCfgid = pCfgid
        self.pCfgData = cfg[CfgType.ETC][pCfgid]
        -- 道具的配置数据
        self:setUI(1)
        local pMaxLabel = me.assignWidget(self, "max_label")
        pMaxLabel:setString("/" .. self.pHaveNum)
        local function sliderEvent(sender, eventType)
            if eventType == ccui.SliderEventType.percentChanged then
                local slider = sender
                local percent = slider:getPercent() / 100
                local pUseNum = math.floor(percent * self.pHaveNum)
                self:setUI(pUseNum)
            end
        end
        local function sliderTouchEvent(sender, eventType)
            local slider = sender
            if eventType == ccui.TouchEventType.ended and self.pHaveNum > 0 then
                if self.pUseNum == 0 then
                    self.pSliber:setPercent(1 / self.pHaveNum * 100)
                    self:setUI(1)
                end
            end
        end

        self.pSliber = me.assignWidget(self, "Slider_worker")
        self.pSliber:setPercent(1 / self.pHaveNum * 100)
        self.pSliber:addEventListener(sliderEvent)
        self.pSliber:addTouchEventListener(sliderTouchEvent)
        -- 增加
        local pButtonAdd = me.assignWidget(self, "btn_add")
        me.registGuiClickEvent(pButtonAdd, function(node)

            if self.pUseNum < self.pHaveNum then
                self.pUseNum = self.pUseNum + 1
                local pPercent =(self.pUseNum / self.pHaveNum) * 100
                self.pSliber:setPercent(pPercent)
                self:setUI(self.pUseNum)
            end
        end )
        -- 减少
        local pButtonAdd = me.assignWidget(self, "btn_reduce")
        me.registGuiClickEvent(pButtonAdd, function(node)
            if self.pUseNum > 1 then
                self.pUseNum = self.pUseNum - 1
                local pPercent =(self.pUseNum / self.pHaveNum) * 100
                self.pSliber:setPercent(pPercent)
                self:setUI(self.pUseNum)
            end
        end )
    end
end
-- 参数：要使用的数量
function BackpackUse:setUI(pUseNum)
    self.pUseNum = me.toNum(pUseNum)
    local pLabel = me.assignWidget(self, "Goods_num")
    pLabel:setString("" .. self.pCfgData["name"])
    --      local pLabel1 = me.assignWidget(self,"label_9")
    --      pLabel1:setPosition(cc.p(pLabel:getPositionX()+pLabel:getContentSize().width+10,pLabel1:getPositionY()))
    self.editBox:setText(me.toStr(pUseNum))
end

function BackpackUse:onEnter()
    print("BackpackUse:onEnter()")
    me.doLayout(self, me.winSize)
end
function BackpackUse:onExit()
    print("BackpackUse:onExit()")
end
function BackpackUse:createEditBox()
    local function editFiledCallBack(strEventName, pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return
            end
            if me.isPureNumber(text) then
                if me.toNum(text) <= self.pHaveNum then
                    if me.toNum(text) >= 1 then
                        self.pUseNum = me.toNum(text)
                    end
                else
                    showTips("超出上限")
                end
            else
                showTips("请输入有效数字")
            end

            local pPercent =(self.pUseNum / self.pHaveNum) * 100
            self.pSliber:setPercent(pPercent)
            self:setUI(self.pUseNum)
        end
    end
    local eb = me.addInputBox(80, 35, 20, "alliance_alpha_bg.png", editFiledCallBack, cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.Node_EditBox:addChild(eb)
    return eb
end