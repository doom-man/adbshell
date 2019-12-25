selectNumberView = class("selectNumberView",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function selectNumberView:create(...)
    local layer = selectNumberView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function selectNumberView:ctor()
    self.rangeMax = 0
end

function selectNumberView:onEnter()
end

function selectNumberView:onExit()
    if self.editCurNum then
        self.editCurNum:unregisterScriptEditBoxHandler()
    end
end

function selectNumberView:init()
    print("selectNumberView init")
    me.doLayout(self, me.winSize)
    me.registGuiTouchEventByName(self, "fixLayout", function(sender, eventType)
        if eventType ~= TOUCH_EVENT_ENDED then
            return
        end
        self:removeFromParentAndCleanup(true)
    end )

    self.sliderBar    = me.assignWidget(self, "slider_worker")
    local editBoxNode   = me.assignWidget(self, "editBoxNum")

    local function editBoxTextEventHandle (eventName, sender)
        if eventName == "return" then
            if self.rangeMax <= 0 then return end
            local text = sender:getText ()
            local inputNumber = tonumber (text)
            if inputNumber ~= nil and inputNumber <= self.rangeMax and inputNumber > 0 then
                self.curSelectNum = inputNumber
            end
            local percent = self.curSelectNum / self.rangeMax * 100
            self.sliderBar:setPercent(percent)
            self:updateSelectView ()
        end
    end
    self.editCurNum = ccui.EditBox:create(cc.size(70, 40), "gongyong_beijing_shuzi_9png.png")
    self.editCurNum:setAnchorPoint(cc.p(0.5, 0.5))
    self.editCurNum:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editCurNum:setFontSize(24)
    self.editCurNum:setPlaceholderFontSize(24)
    editBoxNode:addChild (self.editCurNum)
    self.editCurNum:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self.listTitle    = me.assignWidget(self, "list_title")
    self.listTitle:setScrollBarEnabled (false)
    self.textMaxNum   = me.assignWidget(self, "max_label")
    self.btnAddNum    = me.assignWidget(self, "btn_add")
    self.btnReduceNum = me.assignWidget(self, "btn_reduce")
    self.btnOK        = me.assignWidget(self, "btn_ok")
    -- 增加
    me.registGuiClickEventByName(self, "btn_add", function(node)
        if self.rangeMax <= 0 then return end
        self.curSelectNum = self.curSelectNum + 1
        local percent = self.curSelectNum / self.rangeMax * 100
        self.sliderBar:setPercent(percent)
        self:updateSelectView ()
    end )
    -- 减少
    me.registGuiClickEventByName(self, "btn_reduce", function(node)
        if self.rangeMax <= 0 then return end
        self.curSelectNum = self.curSelectNum - 1
        local percent = self.curSelectNum / self.rangeMax * 100
        if self.curSelectNum == 1 then
            percent = 0
        end
        self.sliderBar:setPercent(percent)
        self:updateSelectView ()
    end )
    local function sliderEvent(sender, eventType)
        if eventType == 0 then
            local percent = sender:getPercent()
            local curNum = math.ceil (self.rangeMax * percent / 100)
            if curNum <= 0 then
                curNum = 1
            end
            self.curSelectNum = curNum
            self:updateSelectView ()
        end
    end
    local function sliderTouchEvent(sender, eventType)
    end
    self.sliderBar:addEventListener(sliderEvent)
    self.sliderBar:addTouchEventListener(sliderTouchEvent)
    -- 确认选择
    me.registGuiClickEventByName(self, "btn_ok", function(node)
        if self.confirmCallback then
            self.confirmCallback(self.curSelectNum)
            self:removeFromParentAndCleanup(true)
        end
    end )

    return true
end

function selectNumberView:registerConfirmCallback(confirmCallback)
    self.confirmCallback = confirmCallback
end

function selectNumberView:setBtnConfirmText(btnTextData)
    self.btnOK:setTitleText(btnTextData.text)
    -- color
    -- fontSize ..
end

function selectNumberView:setTitleData(titleData, titleMargin)
    self.listTitle:removeAllItems ()
    if titleMargin then
        self.listTitle:setItemsMargin(titleMargin)
    end
    for k, v in pairs (titleData) do
        local strTitle = v.strTitle or ""
        local font = v.font or "Arail"
        local fontSize = v.fontSize or 24
        local hAlignment = v.hAlignment or cc.TEXT_ALIGNMENT_LEFT
        local anchorPoint = v.anchorPoint or cc.p (0.5, 0.5)
        local textColor = v.textColor or cc.c4b(255, 255, 255, 255)

        local textTitle = ccui.Text:create(strTitle, font, 24)
        textTitle:setTextHorizontalAlignment(hAlignment)
        textTitle:setAnchorPoint(anchorPoint)
        textTitle:setTextColor (textColor)
        textTitle:setFontSize (fontSize)
        if v.size then
        end
        self.listTitle:pushBackCustomItem(textTitle)
    end
end

function selectNumberView:setSliderMaxNum(max)
    self.rangeMax = math.floor(max) or 0

    self:initSelectView ()
end

function selectNumberView:initSelectView()
    if self.rangeMax <= 0 then
        self.curSelectNum = 0
        self.sliderBar:setPercent(0)
        self.editCurNum:setText ("0")
        self.textMaxNum:setString ("0")

        self.btnAddNum:setBright(false)
        self.btnReduceNum:setBright(false)
        self.btnAddNum:setTouchEnabled(false)
        self.btnReduceNum:setTouchEnabled(false)
        self.btnOK:setBright(false)
        self.btnOK:setTouchEnabled(false)
    else
        self.curSelectNum = 1
        local percent = self.curSelectNum / self.rangeMax * 100
        self.sliderBar:setPercent(percent)
        self.editCurNum:setText (tostring(self.curSelectNum))
        self.textMaxNum:setString ("/" .. self.rangeMax)
        self.btnReduceNum:setBright(false)
        self.btnReduceNum:setTouchEnabled(false)

        if self.rangeMax <= self.curSelectNum then
            self.btnAddNum:setBright(false)
            self.btnAddNum:setTouchEnabled(false)
        end
    end
end

function selectNumberView:updateSelectView()
    if self.rangeMax <= 0 then
        return
    end
    if self.curSelectNum == 0 then
        self.curSelectNum = 1
    end
    if self.curSelectNum > self.rangeMax then
        self.curSelectNum = self.rangeMax
    end
    if self.curSelectNum <= 1 then
        self.btnReduceNum:setBright(false)
        self.btnReduceNum:setTouchEnabled(false)
    else
        self.btnReduceNum:setBright(true)
        self.btnReduceNum:setTouchEnabled(true)
    end
    if self.curSelectNum >= self.rangeMax then
        self.btnAddNum:setBright(false)
        self.btnAddNum:setTouchEnabled(false)
    else
        self.btnAddNum:setBright(true)
        self.btnAddNum:setTouchEnabled(true)
    end
    self.editCurNum:setText (tostring(self.curSelectNum))
end