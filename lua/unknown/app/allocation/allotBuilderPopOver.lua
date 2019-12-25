-- 分配弹出框
allotBuilderPopOver = class("allotBuilderPopOver", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
allotBuilderPopOver.__index = allotBuilderPopOver
function allotBuilderPopOver:create(...)
    local layer = allotBuilderPopOver.new(...)
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
function allotBuilderPopOver:ctor()
    self.minWorker = 0
    self.oldWorker = 0
    self.maxWorker = 0
    self.curWorker = 0
    self.preWorker = 0
    -- 剩余时间
    self.rTime = 0
    -- 剩余比
    self.rPercent = 0
end
function allotBuilderPopOver:init()
    print("allotBuilderPopOver init")
    self.Panel_guide = me.assignWidget(self,"Panel_guide")
    self.name = me.assignWidget(self, "name")
    self.job = me.assignWidget(self, "job")
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    self.btn_ok = me.assignWidget(self, "btn_ok")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.Text_maxWorker = me.assignWidget(self,"Text_maxWorker")
    self.editBox = self:createEditBox()
    self.editBox:setFontColor(cc.c3b(212, 205,185))
    self.Text_tips = me.assignWidget(self,"Text_tips")

    me.registGuiClickEventByName(self, "fixLayout", function(args)
        self:close()
    end )
    local function btn_ok_callback(node)
        --if self.curWorker ~= self.oldWorker then
            local msg = { }
            local mdata = { }
            mdata.bid = self.data.index
            mdata.num = self.curWorker
            mdata.build = 1 --建筑工的调配
            table.insert(msg, mdata)
            NetMan:send(_MSG.allotMsg(msg))
        --end
        self:close()
    end
    me.registGuiClickEvent(self.btn_ok, btn_ok_callback)

    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    local tmp_notRightNum = false 
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100
            local tempfarmer = math.floor(percent*self.maxWorker)
            if self.curWorker ~= tempfarmer then
                if tempfarmer > self.oldWorker+user.idlefarmer then
                    self.editBox:setFontColor(COLOR_RED)
                    showTips(TID_BUILDUP_NOT_ENOUGH)
                    tmp_notRightNum = true
                elseif tempfarmer < self.minWorker then
                    self.editBox:setFontColor(COLOR_RED)
                    tmp_notRightNum = true
                    showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
                else
                    self.preWorker = tempfarmer
                    tmp_notRightNum = false
                    self.editBox:setFontColor(cc.c3b(212, 205,185))
                end
                self.curWorker = tempfarmer
                slider:setPercent(tempfarmer * 100 / self.maxWorker)
                self.editBox:setText(tempfarmer)
                if self.rPercent > 0 then
                    local maxtime = getCurFarmerBuildCostTime(tempfarmer, self.data:getDef())
                    self.Text_time:setString(me.formartSecTime(math.floor(self.rPercent * maxtime)))
                end
                me.setButtonDisable(self.btn_ok, not tmp_notRightNum)
                if guideHelper.getGuideIndex() == guideHelper.guideAllot+3 and me.toNum(self.curWorker-self.oldWorker) == math.min(self.maxWorker-self.oldWorker, user.idlefarmer) then
                    slider:setTouchEnabled(false)
                    guideHelper.nextStepByOpt(false,self.btn_ok)
                end
            end
        end
    end

    local function sliderTouchEvent(sender, eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended and tmp_notRightNum then
            tmp_notRightNum = false
            self.curWorker = self.preWorker
            slider:setPercent(self.curWorker/self.maxWorker*100) 
            local maxtime = getCurFarmerBuildCostTime(self.curWorker, self.data:getDef())
            self.Text_time:setString(me.formartSecTime(math.floor(self.rPercent * maxtime)))
            self.editBox:setText(self.curWorker)
            self.editBox:setFontColor(cc.c3b(212, 205,185))
            me.setButtonDisable(self.btn_ok, true)
        end
    end

    me.registGuiClickEventByName(self, "btn_add", function(node)
        local tmpWorker = self.curWorker+1
        if tmpWorker > self.maxWorker then
            showTips(TID_BUILDUP_GETMAX)
        elseif tmpWorker > self.oldWorker+user.idlefarmer then
            showTips(TID_BUILDUP_NOT_ENOUGH)
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            local maxtime = getCurFarmerBuildCostTime(self.curWorker, self.data:getDef())
            self.Text_time:setString(me.formartSecTime(math.floor(self.rPercent * maxtime)))
            self.editBox:setText(self.curWorker)
        end
    end )

    me.registGuiClickEventByName(self, "btn_reduce", function(node)
        local tmpWorker = self.curWorker-1
        if tmpWorker < self.minWorker then
            showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            local maxtime = getCurFarmerBuildCostTime(self.curWorker, self.data:getDef())
            self.Text_time:setString(me.formartSecTime(math.floor(self.rPercent * maxtime)))
            self.editBox:setText(self.curWorker)
        end
    end )

    self.Slider_worker:addEventListener(sliderEvent)
    self.Slider_worker:addTouchEventListener(sliderTouchEvent)

    return true
end
function allotBuilderPopOver:close()
    -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)
end
function allotBuilderPopOver:initWithData(data)
    self.data = data
    local def = data:getDef()
    self.minWorker = def.farmer
    self.maxWorker = def.maxfarmer
    self.oldWorker = data.builder
    self.curWorker = data.builder
    self.preWorker = data.builder
    self.editBox:setText(self.curWorker)
    self.Text_maxWorker:setString("/"..self.maxWorker)
    self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
    self.name:setString(def.name)
    self.job:setString(allotPopOverJob[7])

    --根据当前建筑物的状态，和类型显示提示语
    local b = user.buildingDateLine[self.data.index]
    local str = nil
    self.Text_tips:setVisible(false)
    if b then
        self.Text_tips:setVisible(true)
        self.Text_tips:setString("建筑工人越多，建筑效率越高")
    else
        b = user.building[self.data.index]
        local def = b:getDef()
        for key, var in pairs(cfg[CfgType.BUILDING_TIPS]) do
            if def.type == var.type then
                self.Text_tips:setVisible(true)
                self.Text_tips:setString(var.tips)
            end
        end
    end    
    me.assignWidget(self, "Text_desc"):setVisible(b.state ~= BUILDINGSTATE_NORMAL.key)
end
function allotBuilderPopOver:setLeftTime(t, maxt)
    local  Text_desc  = me.assignWidget(self, "Text_desc")
    if t and maxt and t > 0 and maxt > 0 then       
        Text_desc:setVisible(true)
        self.rTime = t
        self.Text_time:setString(me.formartSecTime(t))
        self.rPercent = t / maxt
    else  
        Text_desc:setVisible(false)
    end
end
function allotBuilderPopOver:onEnter()
    print("allotBuilderPopOver onEnter")
    me.doLayout(self, me.winSize)
    guideHelper.nextStepByOpt(false,self.Panel_guide)
end
function allotBuilderPopOver:onExit()
    print("allotBuilderPopOver onExit")
end
function allotBuilderPopOver:createEditBox()
    local function editFiledCallBack(strEventName,pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return 
            end
            if me.isPureNumber(text) then
                if me.toNum(text) <= self.maxWorker then
                    if me.toNum(text) > self.oldWorker+user.idlefarmer then
                        showTips(TID_BUILDUP_NOT_ENOUGH) 
                        pSender:setText(self.curWorker)
                    elseif me.toNum(text) < self.minWorker then
                        showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
                        pSender:setText(self.curWorker)
                    else
                        self.curWorker = me.toNum(text)
                    end
                else
                    showTips("超出上限")
                end
            else    
                showTips("请输入有效数字")
            end

            pSender:setText(self.curWorker)
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
        end
    end
    local eb = me.addInputBox(50, 40, 24, "ui_bb_number_bg.png", editFiledCallBack, cc.EDITBOX_INPUT_MODE_NUMERIC)
    eb:setAnchorPoint(cc.p(0, 0.5))
    eb:setPosition(cc.p(0, 0))
    self.Node_EditBox:addChild(eb)
    eb:setPlaceholderFontColor(cc.c3b(0xf5, 0xf5, 0xf5))
    eb:setFontColor(cc.c3b(0xf5, 0xf5, 0xf5))
    return eb
end
