techView = class("techView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
techView._index = techView

techView.techViewInstance = nil
function techView:getInstance()
    return techView:create("techView.csb")
end

function techView:create(csb)
    if techView.techViewInstance ~= nil then
        return techView.techViewInstance 
    end

    techView.techViewInstance = techView.new(csb)
    if techView.techViewInstance then
        if techView.techViewInstance:init() then
            techView.techViewInstance:registerScriptHandler(function(tag)
                if "enter" == tag then
                    techView.techViewInstance:onEnter()
                elseif "exit" == tag then
                    techView.techViewInstance:onExit()
                end
            end )
            return techView.techViewInstance
        end
    end
    return nil
end

function techView:ctor()
    self.buildType = 0
    self.cellViews = {}
    self.listener = nil
    self.toftid = nil
end

function techView:init()
    self.titleName = me.assignWidget(self, "title")
    self.ScrollView_conent = me.assignWidget(self, "ScrollView_conent")
    self.Image_Arrow = me.assignWidget(self, "Image_Arrow")
    self.Text_workersType = me.assignWidget(self,"Text_workersType")
    self.Text_FarmerNum = me.assignWidget(self,"Text_FarmerNum")
    self.Node_Workers = me.assignWidget(self,"Node_Workers")
    me.assignWidget(self,"Image_farmer"):setVisible(true)
    me.assignWidget(self,"Image_given"):setVisible(false)
    me.assignWidget(self,"Image_attacked"):setVisible(false)

    self.curIdleFarmer = user.idlefarmer 
    me.registGuiClickEventByName(self, "addBtn", function(node)
        self:openAllotPopover(node)
    end )
    me.registGuiClickEventByName(self, "addBtn1", function(node)
        self:openAllotPopover(node)
    end )

        -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    return true
end

function techView:openAllotPopover(node)
    local bdata = node.bdata
    local allotPopLayer = allotPopOver:create("allotPopover.csb")
    allotPopLayer:initWithData(bdata, self)
    mainCity:addChild(allotPopLayer,me.MAXZORDER)
    me.showLayer(allotPopLayer,"bg")
end

function techView:updateData(msg)
    if nil == msg then
        return
    end
    if checkMsg(msg.t, MsgCode.CITY_TECH_VIEW) then

    elseif checkMsg(msg.t, MsgCode.CITY_TECH_INIT) then

    elseif checkMsg(msg.t, MsgCode.CITY_TECH_UPLEVEL) then
        self:resetCellView(msg.c.techDefId, MsgCode.CITY_TECH_UPLEVEL)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_FINISH) then
        self:resetCellView(msg.c.defId, MsgCode.CITY_TECH_FINISH)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) then
        for key, var in pairs(msg.c.list) do
            local def = techDataMgr.getTechDefByTofId(var.index)
            if def ~= nil then
                self:resetCellView(def.id, MsgCode.CITY_BUILDING_FARMERCHANGE)
            end
        end
    end
end

function techView:initData(buildId_, toftid_)
    self.toftid = toftid_
    techDataMgr.clearAllData()
    if buildId_ and toftid_ then
        techDataMgr.setCurToftid(toftid_)
        techDataMgr.setCurbuildId(buildId_)
        local buildDef = cfg[CfgType.BUILDING][me.toNum(buildId_)]
        local ext = buildDef.ext
        local _, _, _, buildType = string.find(ext, "%s*(%a+)%s*:%s*(%d+)%s*")
        self.buildType = buildType
        self.titleName:setString(buildDef.name)
    else
        __G__TRACKBACK__("buildID is nil ！！！！")
    end

    self.cthread = coroutine.create(function ()
        --这里为调用的方法 然后在该方法中加入coroutine.yield()
        self:initCellViews()
        self:initLines()
       end)
    self.schid = me.coroStart(self.cthread,0,function ()
        --任务或者新人引导的跳转
        self:setGuideView()
    end)
    self:setWorkersInfo(true)
end

--根据服务器下发新的数据，更改对应的cellview界面信息
function techView:resetCellView(defid, msgType)
    local tmpDef = cfg[CfgType.TECH_UPDATE][defid]
    local oldId = techDataMgr.getTechIDByTypeAndLV(tmpDef.techid,tmpDef.level-1)  
    --重新刷新数据  
    if msgType == MsgCode.CITY_TECH_UPLEVEL or msgType == MsgCode.CITY_BUILDING_FARMERCHANGE then
        if self.cellViews[defid] then
            self.cellViews[defid]:initData()
        elseif self.cellViews[oldId] then
            self.cellViews[oldId]:initData()
        end
    elseif msgType == MsgCode.CITY_TECH_FINISH then 
        --有新升级的科技完毕，找到老科技View，重新赋值给一个key为新科技id, 作为新的索引
        if self.cellViews[defid] then
            self.cellViews[defid]:initData()
        elseif self.cellViews[oldId] then 
            self.cellViews[defid] = self.cellViews[oldId]
            self.cellViews[oldId] = nil
            self.cellViews[defid]:setCellDataID(defid)
            self.cellViews[defid]:initData()
        else
            __G__TRACKBACK__("self.cellViews[oldId] oldid = "..oldid.." not found !!!")
        end

        --查看是否有新的解锁科技
        local defids = techDataMgr.setAndGetTechUnlockDatas()
        for key, var in pairs(defids) do
            if self.cellViews[key] then
                self.cellViews[key]:initData()
            else
                __G__TRACKBACK__("self.cellViews[oldId] new unlock id ="..KEYS.." not found!!!")
            end
        end
    end
end

--初始化所有的cell节点
function techView:initCellViews()
    local techTab = techDataMgr.getTechTypeDatas(self.buildType)
    print("#techTab = "..#techTab)
    if techTab == nil then
        __G__TRACKBACK__("init cell views by build type error !!!")    
    end
    local posXMax,tmpViewW = 0
    for key, var in pairs(techTab) do
        local tmpView = techCellView:create("techIconView.csb")
        local def = var:getDef()
        if tmpView and def then
            tmpView:setCellDataID(def.id)
            self.ScrollView_conent:addChild(tmpView)
            self.cellViews[def.id]=tmpView
            --按照百分比适配Y坐标
            tmpViewW = tmpView:getContentSize().width
            local viewY = 0
            local viewX = 160*(def.posi-1)
            if posXMax < viewX then
                posXMax = viewX
            end
            if def.sort == 1 then
                viewY = 0
            elseif def.sort == 2 then
                viewY = self.ScrollView_conent:getContentSize().height/2-tmpView:getContentSize().height/2
            elseif def.sort == 3 then 
                viewY = self.ScrollView_conent:getContentSize().height-tmpView:getContentSize().height
            end
            tmpView:setPosition(viewX, viewY)
        else 
            __G__TRACKBACK__("techIconView.csb or data is nil  !!!")
        end
        coroutine.yield()
    end
    
    if posXMax > self.ScrollView_conent:getContentSize().width then
        self.ScrollView_conent:setInnerContainerSize(cc.size(posXMax+tmpViewW,self.ScrollView_conent:getContentSize().height))
    end
end

--根据已有的节点连线
function techView:initLines()
    for key, var in pairs(self:getCellViews()) do
        local def = cfg[CfgType.TECH_UPDATE][key]
        local preids = techDataMgr.getPreNodePos(def)
        local startPosX, startPosY= var:getPosition()
        if preids then
            for idKey, idVar in pairs(preids) do
                local imgLine = ccui.ImageView:create("keji_xian_9png.png",me.localType)
                var:getParent():addChild(imgLine,-1)
                local tmpDef1=cfg[CfgType.TECH_UPDATE][idVar]
                local view = nil
                for cellKey, cellVar in pairs(self:getCellViews()) do
                    local cellId = cellVar:getCellDataID()
                    local tmpDef2 = cfg[CfgType.TECH_UPDATE][cellId]
                    if me.toNum(tmpDef1.techid) == me.toNum(tmpDef2.techid) then
                        local endPosX, endPosY = cellVar:getPosition() 
                        local len = cc.pGetDistance(cc.p(endPosX,endPosY), cc.p(startPosX,startPosY))
                        imgLine:setScale9Enabled(true)
                        imgLine:setContentSize(cc.size(len, imgLine:getContentSize().height))
                        imgLine:setRotation(me.getAngleWith2Pos(cc.p(startPosX,startPosY), cc.p(endPosX,endPosY))) 
                        imgLine:setAnchorPoint(cc.p(0, 0.5))
                        imgLine:setPosition(cc.p(startPosX+var:getContentSize().width/2,startPosY+var:getContentSize().height/2))
                        break
                    end
                end
                coroutine.yield()
            end
        end
    end
end

function techView:setWorkersInfo(visable)
    self.Node_Workers:setVisible(visable)
    if not visable then
        return
    end
    local data= user.building[self.toftid]
    local buildDef = cfg[CfgType.BUILDING][me.toNum(techDataMgr.getCurbuildId())]
    self.Text_workersType:setString(buildDef.name..TID_TECH_EXPRO)

    local def = data:getDef()
    self.Text_FarmerNum:setString(data.worker.."/"..def.inmaxfarmer)
    self.Text_FarmerNum:setPositionX(self.Text_workersType:getPositionX()+self.Text_workersType:getContentSize().width)
--    if data.worker<def.inmaxfarmer then
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn1"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+3)
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(false)
--    else
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+3)
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(false)
--    end
end

function techView:updateUI(bindex,curWorker)
    local data= user.building[bindex]
    local def = data:getDef()
    self.Text_FarmerNum:setString(curWorker.."/"..def.inmaxfarmer)
    self.Text_FarmerNum:setPositionX(self.Text_workersType:getPositionX()+self.Text_workersType:getContentSize().width)
--    if curWorker<def.inmaxfarmer then
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn1"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+3)
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(false)
--    else
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+3)
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(false)
--    end
end

function techView:onEnter()
    print("techView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.listener = UserModel:registerLisener(function (msg)
        self:updateData(msg)
    end)
end

function techView:onExit()
    print("techView:onExit()")
    TaskHelper.setTechIDAndType(nil)
    techView.techViewInstance = nil
end

function techView:close()
    UserModel:removeLisener(self.listener)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)
        self.schid = nil
    end
    for key, var in pairs(self.cellViews) do
        var:removeFromParentAndCleanup(true)
    end

    self:removeFromParentAndCleanup(true)
    techView.techViewInstance = nil
end

function techView:getCellViews()
    return self.cellViews
end

function techView:setGuideView()
    local techId,techType = TaskHelper.getTechIDAndType()
    if techId == nil or techType == nil then
        return
    end

    local tarCell = nil
    for key, var in pairs(self.cellViews) do
        if techType == 1 then --defid
            if me.toNum(key) == me.toNum(techId) then
                tarCell = var
                break
            end
        elseif techType == 2 then --techTypeId
            local def = cfg[CfgType.TECH_UPDATE][me.toNum(key)]
            if def and me.toNum(def.techid) == me.toNum(techId) then
                tarCell = var
                break
            end
        end
    end

    if tarCell then
        local offPosX,offPosY = tarCell:getPosition()
        local delayT = 0.5/self.ScrollView_conent:getInnerContainerSize().width*offPosX
        self.ScrollView_conent:scrollToPercentHorizontal(offPosX/self.ScrollView_conent:getInnerContainerSize().width,delayT,true)
        me.DelayRun(function ()
            local guide = guideView:getInstance()
            guide:showGuideViewForScroll(tarCell,false,false)
            mainCity:addChild(guide,me.GUIDEZODER)
        end,delayT)
    else
        showTips("没有找到对应的科技")
    end
end
