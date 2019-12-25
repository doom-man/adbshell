-- 分配弹出框
allotWorkerPopOver = class("allotWorkerPopOver", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
allotWorkerPopOver.__index = allotWorkerPopOver
function allotWorkerPopOver:create(...)
    local layer = allotWorkerPopOver.new(...)
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
function allotWorkerPopOver:ctor()
    print("allotWorkerPopOver ctor")

    self.minWorker = 0
    self.oldWorker = 0
    self.maxWorker = 0
    self.curWorker = 0
    self.preWorker = 0

    self.rTime = 0
    -- 剩余时间
    self.rPercent = 0
    -- 剩余比
    -- 磨房产量
    self.foodout = 0
    -- 士兵训练时间
    self.soldierPruTime = 0
    -- 士兵训练个数
    self.soldierPruNum  = 0
    --科技研究defid
    self.tDef = nil
end
function allotWorkerPopOver:init()
    print("allotWorkerPopOver init")
    self.name = me.assignWidget(self, "name")
    self.job = me.assignWidget(self, "job")
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    self.btn_ok = me.assignWidget(self, "btn_ok")
    self.btn_reduce = me.assignWidget(self, "btn_reduce")
    self.btn_add = me.assignWidget(self, "btn_add")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    self.editBox:setFontColor(cc.c3b(212, 205,185))
    self.Text_maxWorker = me.assignWidget(self,"Text_maxWorker")

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
            mdata.build = 0 --非建筑工的调配
            table.insert(msg, mdata)
            NetMan:send(_MSG.allotMsg(msg))
        --end
        self:close()
    end
    me.registGuiClickEvent(self.btn_ok, btn_ok_callback)

    local tmp_notRightNum = false
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100
            local tempfarmer = math.floor(percent * self.maxWorker)
            print(tempfarmer)
            if self.curWorker ~= tempfarmer then
                self.curWorker = tempfarmer
                if (tempfarmer - self.oldWorker) > user.idlefarmer then
                    tmp_notRightNum  = true
                    showTips(TID_BUILDUP_NOT_ENOUGH)
                    self.editBox:setFontColor(COLOR_RED)
                elseif tempfarmer < self.minWorker then 
                    tmp_notRightNum  = true
                    showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
                    self.editBox:setFontColor(COLOR_RED)
                else
                    self.preWorker=tempfarmer
                    self.editBox:setFontColor(cc.c3b(212, 205,185))
                    tmp_notRightNum = false
                end

                if self.foodout > 0 then
                    self.foodout = getFoodOutPerHour(self.curWorker, self.data:getDef())
                    self.Text_time:setString(self.foodout)
                end 
                if self.soldierPruNum > 0 then
                    -- 士兵训练
                    if self.sdata.stype == 0 then
                        self.soldierPruTime = getCostTime(self.curWorker,self.data:getDef().infarmer,self.data:getDef().inmaxfarmer,self.sdata:getDef().traintime,self.sdata:getDef().traintime2)
                        -- 普通建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数
                        local timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime")
                        -- 奇迹建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数
                        if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
                            timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime")
                        end
                        self.Text_time:setString(me.formartSecTime(timeLeft))
                    -- 士兵升级
                    elseif self.sdata.stype == 1 then
                        -- 滑动前剩余时间所占比例 = (服务端传来的总时间 - 本地流逝时间 - 服务端流逝时间) / 服务端传来的总时间
                        local before_ratio = (self.sdata.time - self.localPassedTime * 1000 - self.sdata.ptime) / self.sdata.time
                        local oldDef = cfg[CfgType.CFG_SOLDIER][self.sdata.oid]
                        local oldPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, oldDef.traintime, oldDef.traintime2)
                        local newPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, self.sdata:getDef().traintime, self.sdata:getDef().traintime2)
                        -- 普通建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
                        local timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * 1.2 * before_ratio
                        -- 奇迹建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
                        if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
                            timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime") * 1.2 * before_ratio
                        end
                        self.Text_time:setString(me.formartSecTime(timeLeft))
                    end
                end
                if self.tDef ~= nil then
                    local time = getTechTime(self.tDef,self.curWorker)
                    self.Text_time:setString(me.formartSecTime(self.rPercent*time))
                end
                
                self.editBox:setText(tempfarmer)
                slider:setPercent(tempfarmer*100/self.maxWorker)
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
            self:resetTime()
            me.setButtonDisable(self.btn_ok, true)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
    self.Slider_worker:addTouchEventListener(sliderTouchEvent)

    me.registGuiClickEventByName(self, "btn_add", function(node)
        local tmpWorker = self.curWorker+1
        if tmpWorker > self.maxWorker then
            showTips(TID_BUILDUP_GETMAX)
        elseif tmpWorker > self.oldWorker+user.idlefarmer then
            showTips(TID_BUILDUP_NOT_ENOUGH)
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            self.editBox:setText(self.curWorker)
            self:resetTime()
        end
    end)

    me.registGuiClickEventByName(self, "btn_reduce", function(node)
        local tmpWorker = self.curWorker-1
        if tmpWorker < self.minWorker then
            showTips(TID_BUILDUP_NEEDLEAST..self.minWorker)
        else
            self.curWorker = tmpWorker
            self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
            self.editBox:setText(self.curWorker)
            self:resetTime()
        end
    end)

    return true
end
function allotWorkerPopOver:onEnter()
    print("allotWorkerPopOver:onEnter()")
    me.doLayout(self,me.winSize)  
end
function allotWorkerPopOver:close()
    -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)
end
function allotWorkerPopOver:setLeftTime(t, maxt)
    if t and maxt and t > 0 and maxt > 0 then
        self.rTime = t
        self.Text_time:setString(me.formartSecTime(t))
        self.rPercent = t / maxt
    else
        me.assignWidget(self, "Text_desc"):setVisible(false)
    end
end
function allotWorkerPopOver:resetTime()
    if self.foodout > 0 then
        self.foodout = getFoodOutPerHour(self.curWorker, self.data:getDef())
        self.Text_time:setString(self.foodout)
    end 
    if self.soldierPruNum > 0 then
        -- 士兵训练
        if self.sdata.stype == 0 then
            self.soldierPruTime = getCostTime(self.curWorker,self.data:getDef().infarmer,self.data:getDef().inmaxfarmer,self.sdata:getDef().traintime,self.sdata:getDef().traintime2)
            -- 普通建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数
            local timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime")
            -- 奇迹建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数
            if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
                timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime")
            end
            self.Text_time:setString(me.formartSecTime(timeLeft))
        -- 士兵升级
        elseif self.sdata.stype == 1 then
            -- 滑动前剩余时间所占比例 = (服务端传来的总时间 - 本地流逝时间 - 服务端流逝时间) / 服务端传来的总时间
            local before_ratio = (self.sdata.time - self.localPassedTime * 1000 - self.sdata.ptime) / self.sdata.time
            local oldDef = cfg[CfgType.CFG_SOLDIER][self.sdata.oid]
            local oldPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, oldDef.traintime, oldDef.traintime2)
            local newPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, self.sdata:getDef().traintime, self.sdata:getDef().traintime2)
            -- 普通建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
            local timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * 1.2 * before_ratio
            -- 奇迹建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
            if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
                timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime") * 1.2 * before_ratio
            end
            self.Text_time:setString(me.formartSecTime(timeLeft))
        end
    end
    if self.tDef ~= nil then
        local time = getTechTime(self.tDef,self.curWorker)
        self.Text_time:setString(me.formartSecTime(self.rPercent*time))
    end
end
function allotWorkerPopOver:initWithData(data)
    self.data = data
    local def = data:getDef()
    self.minWorker = def.infarmer
    self.maxWorker = def.inmaxfarmer
    self.oldWorker = data.worker
    self.curWorker = data.worker
    self.preWorker = data.worker
    self.editBox:setText(self.curWorker)
    self.Text_maxWorker:setString("/"..self.maxWorker)
    self.Slider_worker:setPercent(self.curWorker * 100 / self.maxWorker)
    self.name:setString(def.name)
    self.job:setString(allotPopOverJob[getJobByType(def.type)])
    
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
function allotWorkerPopOver:createEditBox()
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
function allotWorkerPopOver:initForFood(bState_)
    self.foodout = getFoodOutPerHour(self.data.worker, self.data:getDef())
    self.Text_desc = me.assignWidget(self, "Text_desc"):setVisible(bState_ ~= BUILDINGSTATE_NORMAL.key)
    self.Text_desc:setString(TID_ALLOTWORK_PER)
    self.Text_time:setString(self.foodout)
end
function allotWorkerPopOver:initForBarrack(sdata, bState, localPassedTime)  
    self.sdata = sdata
    -- 本地流逝的时间
    self.localPassedTime = localPassedTime
    --dump(self.sdata, "self.sdata")
    --dump(self.data, "self.data")
    self.Text_desc = me.assignWidget(self, "Text_desc"):setVisible(bState ~= BUILDINGSTATE_NORMAL.key)
    self.soldierPruNum = sdata.num
    -- 士兵训练
    if self.sdata.stype == 0 then
        self.soldierPruTime = getCostTime(self.curWorker,self.data:getDef().infarmer,self.data:getDef().inmaxfarmer,self.sdata:getDef().traintime,self.sdata:getDef().traintime2)
        -- 普通建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数
        local timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime")
        -- 奇迹建筑：总时间 = 单个兵种训练时间 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数
        if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
            timeLeft = self.soldierPruTime * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime")
        end
        self.Text_time:setString(me.formartSecTime(timeLeft))
    -- 士兵升级
    elseif self.sdata.stype == 1 then
        -- 滑动前剩余时间所占比例 = (服务端传来的总时间 - 本地流逝时间 - 服务端流逝时间) / 服务端传来的总时间
        local before_ratio = (self.sdata.time - self.localPassedTime * 1000 - self.sdata.ptime) / self.sdata.time
        local oldDef = cfg[CfgType.CFG_SOLDIER][self.sdata.oid]
        local oldPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, oldDef.traintime, oldDef.traintime2)
        local newPerTime = getCostTime(self.curWorker, self.data:getDef().infarmer, self.data:getDef().inmaxfarmer, self.sdata:getDef().traintime, self.sdata:getDef().traintime2)
        -- 普通建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
        local timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * 1.2 * before_ratio
        -- 奇迹建筑：总时间 = 单个兵种升级时间差 * 兵的个数 * 普通建筑加速系数 * 奇迹建筑加速系数 * 1.2 * 之前剩余时间比列，1.2为升级损耗系数
        if self.data:getDef().type == cfg.BUILDING_TYPE_WONDER then
            timeLeft = (newPerTime - oldPerTime) * self.soldierPruNum * getTimePercentByPropertyValue("TrainTime") * getTimePercentByPropertyValue("WonderTrainTime") * 1.2 * before_ratio
        end
        self.Text_time:setString(me.formartSecTime(timeLeft))
    end
end
function allotWorkerPopOver:initForTech(def_)
    self.tDef = def_
    self.Text_desc = me.assignWidget(self, "Text_desc"):setVisible(bState ~= BUILDINGSTATE_NORMAL.key)
end
function allotWorkerPopOver:onEnter()
    print("allotWorkerPopOver onEnter")
    me.doLayout(self, me.winSize)
end
function allotWorkerPopOver:onExit()
    print("allotWorkerPopOver onExit")
end


