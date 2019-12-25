--分配弹出框
allotPopOver = class("allotPopOver",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
allotPopOver.__index = allotPopOver
function allotPopOver:create(...)
    local layer = allotPopOver.new(...)
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
function allotPopOver:ctor()   
    print("allotPopOver ctor") 
    self.minWorker = 0
    self.oldWorker = 0
    self.maxWorker = 0
    self.curWorker = 0
    self.preWorker = 0
end
allotPopOverJob ={
    [1] = TID_ALLOTPOP_JOB1,
    [2] = TID_ALLOTPOP_JOB2,
    [3] = TID_ALLOTPOP_JOB3,
    [4] = TID_ALLOTPOP_JOB4,
    [5] = TID_ALLOTPOP_JOB5,
    [6] = TID_ALLOTPOP_JOB6,
    [7] = TID_ALLOTPOP_JOB7,
}
function allotPopOver:init()   
    self.Panel_guide = me.assignWidget(self,"Panel_guide")
    self.name = me.assignWidget(self,"name")  
    self.job = me.assignWidget(self,"job") 
    self.Slider_worker = me.assignWidget(self,"Slider_worker") 
    self.btn_ok = me.assignWidget(self,"btn_ok") 
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    self.editBox:setFontColor(cc.c3b(212, 205,185))
    self.Text_maxWorker = me.assignWidget(self,"Text_maxWorker")
    self.Text_tips = me.assignWidget(self,"Text_tips")
    me.assignWidget(self, "Text_desc"):setVisible(false)
    me.registGuiClickEventByName(self,"fixLayout",function (args)
         self:close()
    end)
    local function btn_ok_callback(node)
        --if self.curWorker ~= self.oldWorker then 
            if self.visitor then
                self.visitor:updateUI(self.data.index,self.curWorker)
            end
            local msg = {}
            local mdata = {}
            mdata.bid = self.data.index
            mdata.num = self.curWorker
            mdata.build = 0 --非建筑工的调配
            table.insert(msg,mdata)  
            NetMan:send(_MSG.allotMsg(msg))    
        --end  
        self:close()
    end
    me.registGuiClickEvent(self.btn_ok,btn_ok_callback) 
    
    local tmp_notRightNum = false
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100            
            local tempfarmer = math.floor(percent * self.maxWorker)
            if self.curWorker == tempfarmer then
                return
            end
            if (tempfarmer - self.oldWorker) > self.visitor.curIdleFarmer then
                if self.visitor.curIdleFarmer < 0 then -- 对vip消失后导致农民为负数的特殊判断
                    if (tempfarmer - self.oldWorker) > 0 then
                        tmp_notRightNum  = true
                        showTips(TID_BUILDUP_NOT_ENOUGH)
                        self.editBox:setFontColor(COLOR_RED)
                    elseif tempfarmer < self.minWorker then
                        tmp_notRightNum  = true
                        showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
                        self.editBox:setFontColor(COLOR_RED)
                    end
                else       
                    tmp_notRightNum  = true
                    showTips(TID_BUILDUP_NOT_ENOUGH)
                    self.editBox:setFontColor(COLOR_RED)
                end
            elseif tempfarmer < self.minWorker then 
                tmp_notRightNum  = true
                showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
                self.editBox:setFontColor(COLOR_RED)
            else
                self.preWorker=tempfarmer
                self.editBox:setFontColor(cc.c3b(212, 205,185))
                tmp_notRightNum = false
            end
            self.curWorker = tempfarmer
            self.editBox:setText(tempfarmer)
            slider:setPercent(tempfarmer*100/self.maxWorker)
            if guideHelper.getGuideIndex() == guideHelper.guideAllot+3 and me.toNum(self.curWorker-self.oldWorker) == math.min(self.maxWorker-self.oldWorker, self.visitor.curIdleFarmer) then
                slider:setTouchEnabled(false)
                guideHelper.nextStepByOpt(false,self.btn_ok)
            end
        end
    end

    local function sliderTouchEvent(sender, eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended and tmp_notRightNum then
            tmp_notRightNum = false
            self.curWorker = self.preWorker
            slider:setPercent(self.curWorker/self.maxWorker*100) 
            self.editBox:setText(self.curWorker)
            self.editBox:setFontColor(cc.c3b(212, 205,185))
            me.setButtonDisable(self.btn_ok, true)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
    self.Slider_worker:addTouchEventListener(sliderTouchEvent)

     me.registGuiClickEventByName(self, "btn_add", function(node)
        local tmpWorker = self.curWorker+1
        if tmpWorker > self.maxWorker then
            showTips(TID_BUILDUP_GETMAX)
        elseif tmpWorker > self.oldWorker+self.visitor.curIdleFarmer then
            showTips(TID_BUILDUP_NOT_ENOUGH)
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
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
            self.editBox:setText(self.curWorker)
        end
    end )

    return true
end
function allotPopOver:close()
   -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)  
end
function allotPopOver:initWithData(data,node)   
    self.data = data
    self.visitor = node
    local def = data:getDef()    
    self.minWorker = def.infarmer
    self.maxWorker = def.inmaxfarmer
    self.oldWorker = self.data.worker
    self.curWorker = self.data.worker
    self.preWorker = self.data.worker
    self.editBox:setText(self.curWorker)
    self.Text_maxWorker:setString("/"..self.maxWorker)
    self.Slider_worker:setPercent(self.curWorker*100/self.maxWorker)
    self.name:setString(def.name)
    self.job:setString(allotPopOverJob[getJobByType(def.type)])
    self:setTipsByBuildingData(self.data)
end
function allotPopOver:setTipsByBuildingData(data)
       --根据当前建筑物的状态，和类型显示提示语
    local b = user.building[self.data.index]
    local str = nil
    self.Text_tips:setVisible(false)
    if b then
        local def = b:getDef()
        for key, var in pairs(cfg[CfgType.BUILDING_TIPS]) do
            if def.type == var.type then
                self.Text_tips:setVisible(true)
                self.Text_tips:setString(var.tips)
            end
        end
    end    
end
function allotPopOver:onEnter()
    print("allotPopOver onEnter") 
	me.doLayout(self,me.winSize)  
    guideHelper.nextStepByOpt(false,self.Panel_guide)
end
function allotPopOver:onExit()
    print("allotPopOver onExit")    
end

function allotPopOver:createEditBox()
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