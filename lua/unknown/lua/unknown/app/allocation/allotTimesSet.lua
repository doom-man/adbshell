--[Comment]
--jnmo
allotTimesSet = class("allotTimesSet",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
allotTimesSet.__index = allotTimesSet
function allotTimesSet:create(...)
    local layer = allotTimesSet.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function allotTimesSet:ctor()   
    print("allotTimesSet ctor") 
    self.curWorker = 1
    self.maxWorker = 25
    self.minWorker = 1
end
function allotTimesSet:init()   
    print("allotTimesSet init")
	me.registGuiClickEventByName(self,"fixLayout",function (node)
        self:close()     
    end)  
    self.Slider_worker = me.assignWidget(self,"Slider_worker") 
    self.btn_ok = me.assignWidget(self,"btn_ok") 
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    self.editBox:setFontColor(cc.c3b(212, 205,185))
    self.Text_maxWorker = me.assignWidget(self,"Text_maxWorker")  
    local function btn_ok_callback(node)  
        NetMan:send(_MSG.setwave(self.curWorker))      
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
            self.curWorker = math.max(tempfarmer ,1)
            self.editBox:setText(self.curWorker)
            slider:setPercent(self.curWorker*100/self.maxWorker)           
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
     me.registGuiClickEventByName(self, "btn_add", function(node)
        local tmpWorker = self.curWorker+1
        if tmpWorker > self.maxWorker then
            showTips(TID_BUILDUP_GETMAX)       
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            self.editBox:setText(self.curWorker)
        end
    end )

    me.registGuiClickEventByName(self, "btn_reduce", function(node)
        local tmpWorker = self.curWorker-1
        if tmpWorker < 1 then
            
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            self.editBox:setText(self.curWorker)
        end
    end )
    
    return true
end
function allotTimesSet:setCur(c)
    self.curWorker = c
    self.minWorker = math.max(user.activityDetail.wave ,1)
    self.editBox:setText(self.curWorker)
    self.Slider_worker:setPercent(self.curWorker*100/self.maxWorker)
end
function allotTimesSet:createEditBox()
    local function editFiledCallBack(strEventName,pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return 
            end
            
            if me.isPureNumber(text) then
                if me.toNum(text) <= self.maxWorker then                    
                    if me.toNum(text) < self.minWorker then
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
    local eb = me.addInputBox(50,40,24,"alliance_alpha_bg.png",editFiledCallBack,cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.Node_EditBox:addChild(eb)
    return eb
end
function allotTimesSet:onEnter()
    print("allotTimesSet onEnter") 
	me.doLayout(self,me.winSize)  
end
function allotTimesSet:onEnterTransitionDidFinish()
	print("allotTimesSet onEnterTransitionDidFinish") 
end
function allotTimesSet:onExit()
    print("allotTimesSet onExit")    
end
function allotTimesSet:close()
    self:removeFromParent()  
end
