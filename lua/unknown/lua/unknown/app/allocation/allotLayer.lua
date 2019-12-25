allotLayer = class("allotLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
allotLayer.__index = allotLayer
allotLayer.JOB_FARMER = 1
allotLayer.JOB_TIMBERJACK = 2
allotLayer.JOB_HEWER = 3
allotLayer.JOB_COLLECTER = 4
allotLayer.JOB_MILITARY = 5
allotLayer.JOB_TECH = 6
allotLayer.JOB_BUILDER = 7
function allotLayer:create(...)
    local layer = allotLayer.new(...)
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
function allotLayer:ctor()   
    print("allotLayer ctor") 
end
function allotLayer:init()   
    print("allotLayer init")
    
    --注册点击事件
    self.closeBtn = me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)       
    return true
end
function allotLayer:initialize()   
   self.farmer_num = me.assignWidget(self,"farmer_num")
   self.farmer_num_use = me.assignWidget(self,"farmer_num_use")
   self.free_num = me.assignWidget(self,"free_num")
   self.farmer_free = me.assignWidget(self,"farmer_free")
   self.allotItems = {}
   self.workLabels = {}
   self.works = {}
   self.oldWorkers = {}
   self.maxWorkers = {}
   self.curWorkers = {}
   self.smallObjs = {}
   self.curIdleFarmer = 0
   self.guideBtn = nil
   self.guideBtnFather = nil
   local function reducecallback(node)
      print("----reduce---"..node.allotId)
   end
   local function addcallback(node)
      print("----add---"..node.allotId)
   end
   for var = 1, 7 do
       self.allotItems["allotItem_"..var] = me.assignWidget(self,"allotItem_"..var)
       --self.allotItems["allotItem_"..var]["btn_reduce"] = me.assignWidget(self.allotItems["allotItem_"..var],"btn_reduce")
       local btn_reduce = me.assignWidget(self.allotItems["allotItem_"..var],"btn_reduce")
       btn_reduce.allotId = var
       me.registGuiClickEvent(btn_reduce,reducecallback)
       local btn_add = me.assignWidget(self.allotItems["allotItem_"..var],"btn_add")
       btn_add.allotId = var
       me.registGuiClickEvent(btn_add,addcallback)
       self.workLabels[var] = me.assignWidget(self.allotItems["allotItem_"..var],"num")
       self.works[var] = 0
   end
  self:initUI()
end
function allotLayer:addItemAni(node_, curNum_, def_, isBuildingLine_)
    if node_ == nil then
        return
    end
    local panel = me.assignWidget(node_,"Panel_ani")
    panel:removeAllChildren()
    local maxF = def_.inmaxfarmer
    local minF = def_.infarmer
    if isBuildingLine_ then
        maxF = def_.maxfarmer
        minF = def_.farmer
    end
    -- 只有右侧未到达满效率才有光圈提示
    local jobType = getJobByType(def_.type)
    if (jobType == allotLayer.JOB_MILITARY or jobType == allotLayer.JOB_TECH or jobType == allotLayer.JOB_BUILDER)
      and curNum_ < maxF then
        local anim = createArmature("fenpeikuang_guang")
        anim:setScale(1.1)
        anim:getAnimation():play("move1")
        --anim:setAnchorPoint(cc.p(0.5,0.5))
        anim:setPosition(cc.p(panel:getContentSize().width / 2, panel:getContentSize().height / 2 + 5))
        panel:addChild(anim)
    end
end
function allotLayer:cleanAllList()
    for i = 1, 7 do
        local list = me.assignWidget(self.allotItems["allotItem_"..i],"list")
        list:removeAllChildren()    
    end
end
function allotLayer:jumpToHouse()
    local limit = user.centerBuild:getDef().extValue["house"] 
    local buildNum = 0
    local totalNum = 0
    local buildingNum = 0
    if user.buildingTypeNum["house"] and user.buildingTypeNum["house"] > 0 then
        buildNum = me.toNum(user.buildingTypeNum["house"])
    end
    buildingNum = me.toNum(UserModel:getBuildingLineTypeNumWithStatus("house",BUILDINGSTATE_BUILD.key))
    totalNum = buildNum+buildingNum
    if totalNum < limit then --跳转至建造商城
         TASK_JUMPTYPE[TASK_TYPE.CREBUILDING]("house|1")
    else --跳转至升级
        local tar = nil
        for key, var in pairs(mainCity.buildingMoudles) do
            local tmp = var:getData():getDef()
            if tmp.type == "house" then
                tar = var
            end
        end
        cameraLookAtNode(tar,function()
            tar:showBuildingMenu()
        end)
    end
    if mainCity.bLevelUpLayer and mainCity.bLevelUpLayer.close then
        mainCity.bLevelUpLayer:close()
    end
    self:close()
end
function allotLayer:initUI()
    self:cleanAllList()  
    me.registGuiClickEvent(me.assignWidget(self,"Button_add"),function ()
        if CUR_GAME_STATE == GAME_STATE_CITY then
            if mainCity.bshopBox then
                mainCity.bshopBox:close()
            end
            if mainCity.bLevelUpLayer then
                mainCity.bLevelUpLayer:close()
            end
        end
        self:jumpToHouse()
    end)
    self.farmer_num:setString(user.maxfarmer)
    self.farmer_num_use:setString(user.maxfarmer-user.idlefarmer)
    if me.toNum(user.idlefarmer) <= 0 then
        self.free_num:setTextColor(COLOR_RED)
        self.farmer_free:setTextColor(COLOR_RED)
    else
        self.free_num:setTextColor(COLOR_GREEN)
        self.farmer_free:setTextColor(COLOR_GREEN)
    end
    self.free_num:setString(user.idlefarmer)
    self.curIdleFarmer = user.idlefarmer 
    local function allotcallback(node)
        local bdata = node.bdata
        local allotPopLayer = allotPopOver:create("allotPopover.csb")
        allotPopLayer:initWithData(bdata,self)
        mainCity:addChild(allotPopLayer,me.MAXZORDER)
        me.showLayer(allotPopLayer,"bg")
    end
    local function allotMin(node)            
          NetMan:send(_MSG.allotMsg(node.minMsg))
    end
    local function allotMax(node)
          NetMan:send(_MSG.allotMsg(node.maxMsg))
    end
    local globalItems = me.createNode("Node_allotItem.csb")
    local minMsgs = {}
    local maxMsgs = {}
    for key, var in pairs(user.building) do
        local def = var:getDef()
        local job = getJobByType(def.type)
        if job then
            if minMsgs[job] == nil then
                minMsgs[job] = {}
            end
            if maxMsgs[job] == nil then
                maxMsgs[job] = {}
            end
            self.works[job] = self.works[job] + var.worker
            self.curWorkers[var.index] = var.worker
            self.oldWorkers[var.index] = var.worker
            self.maxWorkers[var.index] = def.inmaxfarmer
            self.smallObjs[var.index] = me.assignWidget(globalItems,"allotItem"):clone()
            local icon = me.assignWidget(self.smallObjs[var.index],"icon")
            local a_num = me.assignWidget(self.smallObjs[var.index],"a_num")
            icon:loadTexture(buildSmallIcon(def),me.plistType)
            a_num:setString(var.worker.."/"..def.inmaxfarmer)
            me.fixFontWidth(a_num,82)
            if var.worker==def.inmaxfarmer then
                me.assignWidget(self.smallObjs[var.index], "xiaolv"):setVisible(true)
            else
                me.assignWidget(self.smallObjs[var.index], "xiaolv"):setVisible(false)
            end
            local mdata = { }
            mdata.bid = var.index
            mdata.num = def.infarmer
            mdata.build = 0 
            table.insert(minMsgs[job],mdata)
        
            local maxdata = { }
            maxdata.bid = var.index
            maxdata.num = def.inmaxfarmer
            maxdata.build = 0
            table.insert(maxMsgs[job],maxdata)

            local list = me.assignWidget(self.allotItems["allotItem_"..job],"list")
            self.smallObjs[var.index].bdata = var
            me.registGuiClickEvent(self.smallObjs[var.index],allotcallback)
            list:pushBackCustomItem(self.smallObjs[var.index])
            list:setScrollBarEnabled(false)
            self:addItemAni(self.smallObjs[var.index],var.worker,def)
            if me.toNum(var.worker) < me.toNum(def.inmaxfarmer) then
                self:setGuideTargetBtn(self.smallObjs[var.index],list)
            end
        end
   end
   local index = 1
   local Button_AllotMin = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMin",allotMin)
   Button_AllotMin.minMsg = minMsgs[index]
   Button_AllotMin:setVisible(minMsgs[index] and #minMsgs[index]>0)
   local Button_AllotMax = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMax",allotMax)
   Button_AllotMax.maxMsg = maxMsgs[index]
   Button_AllotMax:setVisible( maxMsgs[index] and  #maxMsgs[index]>0)
   index = 2
   local Button_AllotMin = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMin",allotMin)
   Button_AllotMin.minMsg = minMsgs[index]
   Button_AllotMin:setVisible(minMsgs[index] and #minMsgs[index]>0)
   local Button_AllotMax = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMax",allotMax)
   Button_AllotMax.maxMsg = maxMsgs[index]
   Button_AllotMax:setVisible( maxMsgs[index] and  #maxMsgs[index]>0)
   index = 3
   local Button_AllotMin = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMin",allotMin)
   Button_AllotMin.minMsg = minMsgs[index]
   Button_AllotMin:setVisible(minMsgs[index] and #minMsgs[index]>0)
   local Button_AllotMax = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMax",allotMax)
   Button_AllotMax.maxMsg = maxMsgs[index]
   Button_AllotMax:setVisible( maxMsgs[index] and  #maxMsgs[index]>0)
   index = 5
   local Button_AllotMin = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMin",allotMin)
   Button_AllotMin.minMsg = minMsgs[index]
   Button_AllotMin:setVisible(minMsgs[index] and #minMsgs[index]>0)
   local Button_AllotMax = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMax",allotMax)
   Button_AllotMax.maxMsg = maxMsgs[index]
   Button_AllotMax:setVisible( maxMsgs[index] and  #maxMsgs[index]>0)
   index = 6
   local Button_AllotMin = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMin",allotMin)
   Button_AllotMin.minMsg = minMsgs[index]
   Button_AllotMin:setVisible(minMsgs[index] and #minMsgs[index]>0)
   local Button_AllotMax = me.registGuiClickEventByName(self.allotItems["allotItem_"..index],"Button_AllotMax",allotMax)
   Button_AllotMax.maxMsg = maxMsgs[index]
   Button_AllotMax:setVisible( maxMsgs[index] and  #maxMsgs[index]>0)
   local function allot_builder_callback(node)    
        local bdata = node.bdata
        allotPopLayer_ = allotBuilderPopOver:create("allotPopover.csb")
        local data = user.buildingDateLine[bdata.index]
        local building = mainCity.buildingMoudles[bdata.index]
        allotPopLayer_:initWithData(data)
        allotPopLayer_:setLeftTime(building.maxTime - building.time, building.maxTime)
        mainCity:addChild(allotPopLayer_,me.MAXZORDER)
        me.showLayer(allotPopLayer_,"bg")
   end
   local minMsg = {}
   local maxMsg = {}
   for key, var in pairs(user.buildingDateLine) do
        local def = var:getDef()
        local job = allotLayer.JOB_BUILDER
        self.works[job] = self.works[job] + var.builder
        self.curWorkers[var.index] = var.builder
        self.oldWorkers[var.index] = var.builder
        self.smallObjs[var.index] = me.assignWidget(globalItems,"allotItem"):clone()
        local icon = me.assignWidget(self.smallObjs[var.index],"icon")
        local a_num = me.assignWidget(self.smallObjs[var.index],"a_num")
        icon:loadTexture(buildSmallIcon(def),me.plistType)   
        a_num:setString(var.builder.."/"..def.maxfarmer)
        if var.builder==def.maxfarmer then
            me.assignWidget(self.smallObjs[var.index], "xiaolv"):setVisible(true)
        else
            me.assignWidget(self.smallObjs[var.index], "xiaolv"):setVisible(false)
        end
        local list = me.assignWidget(self.allotItems["allotItem_"..job],"list")
        self.smallObjs[var.index].bdata = var
        me.registGuiClickEvent(self.smallObjs[var.index],allot_builder_callback)
        list:pushBackCustomItem(self.smallObjs[var.index])
        list:setScrollBarEnabled(false)
        self:addItemAni(self.smallObjs[var.index],var.builder,def,true)
        local mdata = { }
        mdata.bid = var.index
        mdata.num = def.farmer
        mdata.build = 1 
        table.insert(minMsg,mdata)
        
        local maxdata = { }
        maxdata.bid = var.index
        maxdata.num = def.maxfarmer
        maxdata.build = 1 
        table.insert(maxMsg,maxdata)
        if me.toNum(var.builder) < me.toNum(def.maxfarmer) then
            self:setGuideTargetBtn(self.smallObjs[var.index],list)
        end
   end  
   local Button_AllotMin7 = me.registGuiClickEventByName(self.allotItems["allotItem_7"],"Button_AllotMin",allotMin)
   Button_AllotMin7.minMsg = minMsg
   Button_AllotMin7:setVisible(#minMsg>0)
   local Button_AllotMax7 = me.registGuiClickEventByName(self.allotItems["allotItem_7"],"Button_AllotMax",allotMax)
   Button_AllotMax7.maxMsg = maxMsg
   Button_AllotMax7:setVisible(#maxMsg>0)
    local function allot_collocter_callback(args)
        showTips(TID_ALLOT_CANNOT)
    end
   for key, var in pairs(user.cityRandResource) do
         local def = var:getDef()
         local job = allotLayer.JOB_COLLECTER
         if var.work ~= 3 then
             self.smallObjs[var.place] = me.assignWidget(globalItems,"allotItem"):clone()
             local icon = me.assignWidget(self.smallObjs[var.place],"icon")
             local a_num = me.assignWidget(self.smallObjs[var.place],"a_num")              
             icon:loadTexture(resSmallIcon(def),me.plistType)      
             if resMoudle.RES_STATE_WORK == var.work then
                self.works[job] = self.works[job] + def.worker         
                a_num:setString(def.worker.."/"..def.worker)
                me.assignWidget(self.smallObjs[var.place], "xiaolv"):setVisible(true)
             else
                a_num:setString("0/"..def.worker)
                me.assignWidget(self.smallObjs[var.place], "xiaolv"):setVisible(false)
             end
             local list = me.assignWidget(self.allotItems["allotItem_"..job],"list")
             self.smallObjs[var.place].bdata = var
             me.registGuiClickEvent(self.smallObjs[var.place],allot_collocter_callback)
             list:pushBackCustomItem(self.smallObjs[var.place])
             list:setScrollBarEnabled(false)
             self:addItemAni(self.smallObjs[var.index],def.worker,def)
         end
   end
    for key, var in pairs(self.workLabels) do
        self.workLabels[key]:setString(self.works[key] or 0)
    end
end
function allotLayer:addWorkerChangeAni(num_)
    local textCol = nil
    if num_ == 0 then
        return
    elseif num_ > 0 then
        num_ = "-"..math.abs(num_)
        textCol = COLOR_RED
    elseif num_ < 0 then
        num_ = "+"..math.abs(num_)
        textCol = COLOR_GREEN
    end

    local function callback()
        if self.animText then
            self.animText:stopAllActions()
            self.animText:removeFromParentAndCleanup(true)
            self.animText = nil
        end
    end
    if self.animText == nil then
        self.animText = cc.Label:createWithSystemFont(num_,"",24)
        self.animText:setTextColor(textCol)
        self.animText:setAnchorPoint(cc.p(0.5, 0))
        self.free_num:addChild(self.animText)
        self.animText:setPosition(self.free_num:getContentSize().width/2, self.free_num:getContentSize().height)        
    end
    self.animText:setString(num_)
    local aniTime = 0.6
    local curX, curY = self.animText:getPosition()          
    local seq1 = cc.Sequence:create(cc.MoveTo:create(aniTime,cc.p(curX, curY+28)),cc.FadeOut:create(aniTime))
    local seq2 = cc.Sequence:create(cc.DelayTime:create(aniTime),cc.CallFunc:create(callback))
    self.animText:runAction(seq1)
    self.animText:runAction(seq2)
end
function allotLayer:updateUI(bindex,num)
    local xnum = num - self.curWorkers[bindex]
    self:addWorkerChangeAni(xnum)
    self.curWorkers[bindex] = num
    local a_num = me.assignWidget(self.smallObjs[bindex],"a_num")
    local def = user.building[bindex]:getDef()
    a_num:setString(num.."/"..def.inmaxfarmer)
    if num==def.inmaxfarmer then
        me.assignWidget(self.smallObjs[bindex], "xiaolv"):setVisible(true)
    else
        me.assignWidget(self.smallObjs[bindex], "xiaolv"):setVisible(false)
    end

    self:addItemAni(self.smallObjs[bindex],num,def)
    self.curIdleFarmer = self.curIdleFarmer - xnum
    if me.toNum(self.curIdleFarmer) <= 0 then
        self.free_num:setTextColor(COLOR_RED)
        self.farmer_free:setTextColor(COLOR_RED)
    else
        self.free_num:setTextColor(COLOR_GREEN)
        self.farmer_free:setTextColor(COLOR_GREEN)
    end
    self.free_num:setString(self.curIdleFarmer)
    local job = getJobByType(def.type)
    self.works[job] =  self.works[job] + xnum
    self.workLabels[job]:setString(self.works[job] or 0)
    self.farmer_num:setString(user.maxfarmer)
    self.farmer_num_use:setString(user.maxfarmer-self.curIdleFarmer)
end
function allotLayer:updateUIforBuilder(bindex,num)
    local xnum = num - self.curWorkers[bindex]
    self.curWorkers[bindex] = num
    local a_num = me.assignWidget(self.smallObjs[bindex],"a_num")
    local def = user.buildingDateLine[bindex]:getDef()
    self:addItemAni(self.smallObjs[bindex],num,def)
    a_num:setString(num.."/"..def.maxfarmer)
    if num==def.maxfarmer then
        me.assignWidget(self.smallObjs[bindex], "xiaolv"):setVisible(true)
    else
        me.assignWidget(self.smallObjs[bindex], "xiaolv"):setVisible(false)
    end
    self.curIdleFarmer = self.curIdleFarmer - xnum
    if me.toNum(self.curIdleFarmer) <= 0 then
        self.free_num:setTextColor(COLOR_RED)
        self.farmer_free:setTextColor(COLOR_RED)
    else
        self.free_num:setTextColor(COLOR_GREEN)
        self.farmer_free:setTextColor(COLOR_GREEN)
    end
    self.free_num:setString(self.curIdleFarmer)
    local job = getJobByType(def.type)
    self.works[7] =  self.works[7] + xnum
    self.workLabels[7]:setString(self.works[7] or 0)
    self.farmer_num:setString(user.maxfarmer)
    self.farmer_num_use:setString(user.maxfarmer-self.curIdleFarmer)
end
function getJobByType(type_)
    if type_ == cfg.BUILDING_TYPE_FOOD then
        return allotLayer.JOB_FARMER
    elseif type_ == cfg.BUILDING_TYPE_BARRACK or type_ == cfg.BUILDING_TYPE_RANGE or type_ == cfg.BUILDING_TYPE_HORSE
        or type_ == cfg.BUILDING_TYPE_SIEGE or type_ == cfg.BUILDING_TYPE_WONDER or type_ == cfg.BUILDING_TYPE_DOOR then
        return allotLayer.JOB_MILITARY
    elseif type_ == cfg.BUILDING_TYPE_BLACKSMITH or type_ == cfg.BUILDING_TYPE_CASTLE or type_ == cfg.BUILDING_TYPE_COLLEGE then
        return allotLayer.JOB_TECH
    elseif type_ == cfg.BUILDING_TYPE_LUMBER then
        return allotLayer.JOB_TIMBERJACK
    elseif type_ == cfg.BUILDING_TYPE_STONE then
        return allotLayer.JOB_HEWER
   -- elseif type_ == cfg.BUILDING_TYPE_BARRACK then
   --     return allotLayer.JOB_TECH
   -- elseif type_ == cfg.BUILDING_TYPE_BARRACK then
   --     return allotLayer.JOB_TECH
    end
end

function allotLayer:setGuideTargetBtn(btn,btnFather)
--    if guideHelper.getGuideIndex() >= guideHelper.guideAllot and guideHelper.getGuideIndex() < guideHelper.guideConquest
--    and self.guideBtn == nil and self.guideBtnFather == nil then
--        self.guideBtn = btn
--        self.guideBtnFather = btnFather
--    end
end
function allotLayer:getGuideTargetBtn()
    local Image =  me.assignWidget(self,"allotItem_5")
    local list1 = me.assignWidget(Image,"list")
    local tar = list1:getChildren()
    return tar[1],list1
end
function allotLayer:onEnterTransitionDidFinish()
    self:initialize()
    self.reg = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.CITY_UPDATE) then --checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) 
            self:initialize()  
        end
    end)
    if guideHelper.getGuideIndex() ==  guideHelper.guideAllot+1  then
        guideHelper.nextStepByOpt(false,self:getGuideTargetBtn())
    end
end
function allotLayer:onEnter()
    print("allotLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function allotLayer:close()
   -- me.hideLayer(self,true,"shopbg")
    mainCity.allot = nil
    if self.animText then
        self.animText:stopAllActions()
    end
    UserModel:removeLisener(self.reg)
    self:removeFromParentAndCleanup(true) 
end
function allotLayer:onExit()
    print("allotLayer onExit")    
end
