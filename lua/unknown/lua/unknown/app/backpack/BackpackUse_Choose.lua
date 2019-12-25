-- 道具使用    2015-12-03
BackpackUse_Choose = class("BackpackUse_Choose", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
BackpackUse_Choose.__index = BackpackUse_Choose
function BackpackUse_Choose:create(...)
    local layer = BackpackUse_Choose.new(...)
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
function BackpackUse_Choose:ctor()
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.itemNum = 0
end
function BackpackUse_Choose:setTypee(pType)
    self.BackUseType = pType
end
function BackpackUse_Choose:close()
    self:removeFromParentAndCleanup(true)
end
function BackpackUse_Choose:init()
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    me.registGuiClickEventByName(self, "btn_ok", function(node)
        self:GoodsUse()
        self:close()
    end )
    me.registGuiClickEventByName(self, "maxBtn", function(node)
        self.pUseNum = self.pHaveNum
        local pPercent =(self.pUseNum / self.pHaveNum) * 100
        self.pSliber:setPercent(pPercent)
        self:setUI(self.pUseNum)
    end )
    self.chooseEvt = me.RegistCustomEvent("BackpackUse_Choose_Evt",function (evt)
             local defid = tonumber( evt._userData )
             if   self.chooseDefid ~=  defid then
                        self.chooseDefid =  defid                         
                        self:setUI(self.pUseNum)
             end
    end)
    return true
end
function BackpackUse_Choose:GoodsUse()
    if me.toNum(self.pUseNum) >= 1 then
        NetMan:send(_MSG.itemUse(self.itemid,self.pUseNum,self.chooseDefid))
    end
end
-- 点击的物品数据
function BackpackUse_Choose:setData(pData,callback)
    if pData ~= nil then
        self.pHaveNum = me.toNum(pData["count"])
        -- 拥有的道具数量
        self.data = pData
        self.itemid = pData.uid
        self.listitems = { }
        local items = me.split(pData:getDef().useEffect, ",")
        if items then
            for key, var in pairs(items) do
                local is = me.split(var, ":")
                if is then
                    table.insert(self.listitems, is)
                end
            end
        end        
        self.listmodels = { }
        local list = me.assignWidget(self, "list")
        local tmp = me.createNode("Node_UseCell.csb")
        self.chooseDefid = nil
        local num = #self.listitems
        for key, var in pairs(self.listitems) do
            local cell = me.assignWidget(tmp,"cell"):clone()          
            local cfg = cfg[CfgType.ETC][ tonumber(var[1])]
            if cfg then
                cell.pUseNum = tonumber( var[2]  )
                cell.pDefid = tonumber( var[1] )
                me.assignWidget(cell, "num"):setString(var[2])
                me.assignWidget(cell, "Goods_Icon"):loadTexture(getItemIcon(cfg.id), me.localType)
                me.assignWidget(cell, "Goods_Icon"):ignoreContentAdaptWithSize(true)            
                me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(cfg.quality), me.localType)
                me.registGuiClickEventByName(cell, "Goods_Icon", function(node)
                    local defId = tonumber( var[1] )
                    local pNum = tonumber( var[2] ) * self.pUseNum
                    showPromotionChoose(defId, pNum)
                end )
                if  self.chooseDefid == nil then
                     self.chooseDefid = tonumber( var[1] )
                     me.assignWidget(cell,"chooseBox"):setSelected(true)
                end
                local function choose(node)
                     if   self.chooseDefid ~=  tonumber( var[1] ) then
                        self.chooseDefid =  tonumber( var[1] )                        
                     end
                     self:setUI(self.pUseNum)
                end
                me.assignWidget(cell,"chooseBox"):addEventListener(choose)
                list:pushBackCustomItem(cell)
                table.insert(self.listmodels,cell)
            end
        end
        if num <= 3 then
            local w = 650 -  num *162 
            list:setPositionX( 315 + w/2)
        else
            list:setPositionX( 315)
        end
        self.pUseNum = me.toNum(self.pHaveNum)
        -- 要使用的道具数量
        local pCfgid = pData["defid"]
        self.mCfgid = pCfgid
        self.pCfgData = pData:getDef()
        -- 道具的配置数据
        self:setUI(1)
        callback(1)
        local pMaxLabel = me.assignWidget(self, "max_label")
        pMaxLabel:setString("/" .. self.pHaveNum)
        local function sliderEvent(sender, eventType)
            if eventType == ccui.SliderEventType.percentChanged then
                local slider = sender
                local percent = slider:getPercent() / 100
                local pUseNum = math.floor(percent * self.pHaveNum)
                self:setUI(pUseNum)
                callback(pUseNum)
            end
        end
        local function sliderTouchEvent(sender, eventType)
            local slider = sender
            if eventType == ccui.TouchEventType.ended and self.pHaveNum > 0 then
                if self.pUseNum == 0 then
                    self.pSliber:setPercent(1 / self.pHaveNum * 100)
                    self:setUI(1)
                    callback(1)
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
                callback(self.pUseNum)
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
                callback(self.pUseNum)
            end
        end )
    end
end
-- 参数：要使用的数量
function BackpackUse_Choose:setUI(pUseNum)
    self.pUseNum = me.toNum(pUseNum)
    for key, var in pairs(self.listmodels) do
         me.assignWidget(var,"num"):setString(var.pUseNum*pUseNum)
         me.assignWidget(var,"chooseBox"):setSelected( self.chooseDefid == tonumber( var.pDefid ))
    end    
    self.editBox:setText(me.toStr(pUseNum))
end
function BackpackUse_Choose:onEnter()
    print("BackpackUse_Choose:onEnter()")
    me.doLayout(self, me.winSize)
end
function BackpackUse_Choose:onExit()
    print("BackpackUse_Choose:onExit()")
    me.RemoveCustomEvent(self.chooseEvt)
end
function BackpackUse_Choose:createEditBox()
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