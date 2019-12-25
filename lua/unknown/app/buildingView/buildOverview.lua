
buildOverview = class("buildOverview",function (csb)
    return cc.CSLoader:createNode(csb)
end)
buildOverview.__index = buildOverview
function buildOverview:create(csb)
    local layer = buildOverview.new(csb)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then 
                    layer:enterTransitionFinish()
                end
                print(tag)
            end)            
            return layer
        end
    end
    return nil 
end
function buildOverview:ctor()   
    print("buildOverview ctor") 

end


local overviewData = {
    {type=1, name="主城税收", icon="overview1.png"},
    {type=5, index=4001}, --主城
    {type=1, name="圣物搜寻", icon="overview2.png"},
    {type=6, index=3007}, --圣物搜寻
    {type=1, name="士兵&陷阱", icon="overview3.png"},
    {type=2, index=3001}, --军营
    {type=2, index=3002}, --靶场
    {type=2, index=3003}, --马厩
    {type=2, index=4003}, --攻城武器石
    {type=2, index=8001}, --城门
    {type=2, index=5001}, --奇迹
    {type=1, name="科技研究", icon="overview4.png"},
    {type=3, index=3004}, --铁匠铺
    {type=3, index=4004}, --大学
    {type=3, index=4002}, --城堡
    {type=3, index=1001}, --箭塔
    {type=1, name="伤兵治疗", icon="overview5.png"},
    {type=4, index=3005}, --修道院
}
function buildOverview:init()   
    print("buildOverview init")  
    self.w = 456
    self.boxOuter = me.assignWidget(self, "fixLayout")
    self.boxInner = me.assignWidget(self, "bg")
    self.outerBtn = me.assignWidget(self, "outerBtn")
    self.innerBtn = me.assignWidget(self, "innerBtn")
    me.registGuiClickEvent(self.outerBtn, handler(self, self.showBox))
    me.registGuiClickEvent(self.innerBtn, handler(self, self.showBox))

    self.timerFunc = {}
    self.dataList = {}
    self:initTable()

    self.boxOuter:setPosition(-self.w, 0)
    self.isShow = false

    self.timer = me.registTimer(-1, handler(self,self.timerUpdate), 1)
    self.redpointTimer = me.registTimer(-1, function()
        if self.isShow == false then
            self:collectData()
            if self.redPoint == false then
                me.assignWidget(self, "redpoint1"):setVisible(false)
            else
                me.assignWidget(self, "redpoint1"):setVisible(true)
            end
        end
    end, 3)

    self:checkClick()

    return true
end

function buildOverview:showBox()
    self.boxOuter:stopAllActions()
    
    if self.isShow==false then
        self.isShow = true

        buildingOptMenuLayer:getInstance():clearnButton()

        self:collectData()
        self.tableView:reloadData()
        local callback = cc.CallFunc:create(function()
            self.outerBtn:setVisible(false)
            self.innerBtn:setVisible(true)
        end)
        self.boxOuter:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-2, 0)), callback))
    else
        self.isShow = false
        self.timerFunc = {}
        self.dataList = {}
        local callback = cc.CallFunc:create(function()
            self.outerBtn:setVisible(true)
            self.innerBtn:setVisible(false)
            self.tableView:reloadData()
        end)
        self.boxOuter:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-self.w, 0)), callback))
    end
end

function buildOverview:collectData()
    self.dataList = {}
    local head = nil
    local tmp = {}
    local idx = 0
    self.redPoint = false
    for _, v in ipairs(overviewData) do
        if v.type==1 then
            if head~=nil and #tmp>0 then
                table.insert(self.dataList, head)
                table.insertto(self.dataList, tmp)
                idx=0
            end
            head=v
            tmp={}
        elseif v.type==2 then
            if user.building[v.index] then
                local data = user.building[v.index]
                if (v.index==8001 and data.def.level>5) or v.index~=8001 then 
                    table.insert(tmp, v)
                    local soldierData = user.produceSoldierData[v.index]  --是否在训练中
                    if soldierData==nil or soldierData.num <= 0 then
                        v.trainData = nil

                        if v.index~=5001 and  not(data.state==3 or data.state==4) then ---建筑升级中
                            self.redPoint = true
                            if self.isShow == false then  --没有展示时只检测是否有红点
                                break
                            end
                        end
                    else
                        v.trainData = soldierData
                        v.isNew = true              --表示重新初始化，重算时间
                    end
                    v.idx=idx
                    idx=idx+1
                end
            end
        elseif v.type==3 then
            if user.building[v.index] then
                table.insert(tmp, v)
                local tData = techDataMgr.getTechingTechDataByTofId(v.index)
                if tData==nil then
                    v.techData = nil
                    if v.index~=1001 and user.building[v.index].state~=3 then
                        self.redPoint = true
                        if self.isShow == false then  --没有展示时只检测是否有红点
                            break
                        end
                    end
                else
                    v.techData = tData
                    v.isNew = true              --表示重新初始化，重算时间
                end
                v.idx=idx
                idx=idx+1
            end
        elseif v.type==4 then
            if user.building[v.index] then
                table.insert(tmp, v)
                local tData = user.revertingSoldiers[v.index]
                if tData==nil then
                    v.revertingData = nil
                else
                    v.revertingData = tData
                    v.isNew = true              --表示重新初始化，重算时间
                end
                v.idx=idx
                idx=idx+1
            end
        elseif v.type==5 then 
            if user.building[v.index] and user.newBtnIDs[me.toStr(OpenButtonID_Tax)] ~= nil then
                table.insert(tmp, v)
                v.idx=idx
                idx=idx+1

                if user.taxInfo.newFreeCount and (user.taxInfo.newFreeCount+user.taxInfo.newPayCount)<user.taxInfo.maxCount then
                    self.redPoint = true
                    if self.isShow == false then  --没有展示时只检测是否有红点
                        break
                    end
                end
            end
        elseif v.type==6 then
            if user.building[v.index] then
                table.insert(tmp, v)
                v.idx=idx
                idx=idx+1

                if user.runeNormalSearch.freeTime~=nil and user.runeNormalSearch.freeTime<=0 and user.runeNormalSearch.free~=user.runeNormalSearch.freeNum then
                    self.redPoint = true
                    if self.isShow == false then  --没有展示时只检测是否有红点
                        break
                    end
                end
            end
        end
    end
    
    if self.isShow == false then
        return
    end
    if head~=nil and #tmp>0 then
        table.insert(self.dataList, head)
        table.insertto(self.dataList, tmp)
    end
end



function buildOverview:initTable()
    self.tableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        self:onTableLineJump(cell:getIdx())
    end
    local function cellSizeForTable(table, idx)
        return 415, 37
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()           
            local cellData = self.dataList[idx+1]
            if cellData then
                if cellData.type>1 then
                    local leftCell = me.assignWidget(self,"cell"):clone():setVisible(true)
                    leftCell:setName('normal')  
                    self:fillNormal(idx, leftCell, cellData)
                    leftCell:setPositionX(5)
                    local optBtn = me.assignWidget(leftCell,"optBtn")
                    optBtn:setSwallowTouches(false)
                    optBtn.idx=idx
                    --me.registGuiClickEvent(optBtn, handler(self, self.onJump))
                    leftCell:setPosition(cc.p(0, 0))
                    cell:addChild(leftCell)
                elseif cellData.type==1 then
                    local leftCell = me.assignWidget(self,"cell1"):clone():setVisible(true)
                    leftCell:setName('head')  
                    self:fillHead(leftCell, cellData)
                    leftCell:setPosition(cc.p(0, 0))
                    cell:addChild(leftCell)
                end
             end
        else 
            local cellData = self.dataList[idx+1]
            if cellData then
                if cellData.type>1 then
                    local leftCell = cell:getChildByName('normal')
                    if leftCell==nil then
                        leftCell = me.assignWidget(self,"cell"):clone():setVisible(true)
                        leftCell:setName('normal') 
                        leftCell:setPositionX(5)
                        local optBtn = me.assignWidget(leftCell,"optBtn")
                        optBtn:setSwallowTouches(false)
                        optBtn.idx=idx
                        --me.registGuiClickEvent(optBtn, handler(self, self.onJump)) 
                        leftCell:setPosition(cc.p(0, 0))
                        cell:addChild(leftCell)
                    else
                        local optBtn = me.assignWidget(leftCell,"optBtn")
                        local oldIdx = optBtn.idx
                        local oldCellData = self.dataList[oldIdx+1]
                        if oldCellData~=nil and oldCellData.index~=nil then
                            self.timerFunc[oldCellData.index]=nil      --删除可能存在的到计时
                        end
                        optBtn.idx=idx
                    end
                    self:fillNormal(idx, leftCell, cellData)
                    cell:removeChildByName('head')
                elseif cellData.type==1 then  --占位
                    local leftCell = cell:getChildByName('head')
                    if leftCell==nil then
                        leftCell = me.assignWidget(self,"cell1"):clone():setVisible(true)
                        leftCell:setName('head')  
                        leftCell:setPosition(cc.p(0, 0))
                        cell:addChild(leftCell)
                    end
                    self:fillHead(leftCell, cellData)

                    local normalCell = cell:getChildByName('normal')
                    if normalCell then
                        local oldIdx = me.assignWidget(normalCell,"optBtn").idx
                        local oldCellData = self.dataList[oldIdx+1]
                        if oldCellData~=nil and oldCellData.index~=nil then
                            self.timerFunc[oldCellData.index]=nil      --UI被移除时同时删除到计时
                        end
                        cell:removeChildByName('normal')
                    end
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.dataList
    end

    local tableView = cc.TableView:create(cc.size(427, 375))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView = tableView
  
end

function buildOverview:fillNormal(idx, cell, data)
    if data.idx%2==0 then
        me.assignWidget(cell, "bg"):setVisible(false)
    else
        me.assignWidget(cell, "bg"):setVisible(true)
    end
    local buildData = user.building[data.index]
    local buildDef = buildData:getDef()
    me.assignWidget(cell, "nameTxt"):setString(buildDef.name)
    
    me.assignWidget(cell, "redpoint"):setVisible(false)

    local timeTxt = me.assignWidget(cell, "timeTxt")
    timeTxt:setString("")
    if data.type==2 then
        if data.trainData == nil then
            local buildData = user.building[data.index]
            
            if buildData.state==3 or buildData.state==4 then ---建筑升级中
                local statusTxt = me.assignWidget(cell, "statusTxt")
                statusTxt:setVisible(true)
                if buildData.state==4 then
                    statusTxt:setString("转换中")
                else
                    statusTxt:setString("升级中")
                end
                timeTxt:setVisible(true)
                me.assignWidget(cell, "optBtn"):setVisible(false)

                local totalTime = user.buildingDateLine[data.index].countdown / 1000- (me.sysTime()-user.buildingDateLine[data.index].recvTime)/1000
                self.timerFunc[data.index]={txt=timeTxt, totalTime=totalTime}
                timeTxt:setString(me.formartSecTime(totalTime))
            else
                timeTxt:setVisible(false)
                me.assignWidget(cell, "statusTxt"):setVisible(false)
                me.assignWidget(cell, "optBtn"):setVisible(true)
                if data.index~=5001 then
                    me.assignWidget(cell, "redpoint"):setVisible(true)
                end
            end
        else
            local statusTxt = me.assignWidget(cell, "statusTxt")
            statusTxt:setVisible(true)
            if data.index==8001 then
                statusTxt:setString("建造中")
            else
                if data.trainData.stype == 1 then
                    statusTxt:setString("升级中")
                else
                    statusTxt:setString("训练中")
                end
            end
            timeTxt:setVisible(true)
            me.assignWidget(cell, "optBtn"):setVisible(false)
            --local totalTime = mainCity.buildingMoudles[data.index]:getTrainTotalTime()
            local totalTime=0
            if data.trainData.stype == 1 then
                totalTime = data.trainData.time/1000 -data.trainData.ptime/1000- (me.sysTime()-data.trainData.recvTime)/1000
            else
                totalTime = data.trainData.time*(data.trainData.num-1)/1000+(data.trainData.time-data.trainData.ptime)/1000 - (me.sysTime()-data.trainData.recvTime)/1000
            end
            self.timerFunc[data.index]={txt=timeTxt, totalTime=totalTime}
            timeTxt:setString(me.formartSecTime(totalTime))
        end
    elseif data.type==3 then
        if data.techData == nil then
            local buildData = user.building[data.index]
            if buildData.state==3 then ---建筑升级中
                local statusTxt = me.assignWidget(cell, "statusTxt")
                statusTxt:setVisible(true)
                statusTxt:setString("升级中")
                timeTxt:setVisible(true)
                me.assignWidget(cell, "optBtn"):setVisible(false)

                local totalTime = user.buildingDateLine[data.index].countdown / 1000- (me.sysTime()-user.buildingDateLine[data.index].recvTime)/1000
                self.timerFunc[data.index]={txt=timeTxt, totalTime=totalTime}
                timeTxt:setString(me.formartSecTime(totalTime))
            else
                timeTxt:setVisible(false)
                me.assignWidget(cell, "statusTxt"):setVisible(false)
                me.assignWidget(cell, "optBtn"):setVisible(true)

                if data.index~=1001 then
                    me.assignWidget(cell, "redpoint"):setVisible(true)
                end
            end
        else
            local statusTxt = me.assignWidget(cell, "statusTxt")
            statusTxt:setVisible(true)
            statusTxt:setString("研究中")
            timeTxt:setVisible(true)
            me.assignWidget(cell, "optBtn"):setVisible(false)
            local ctime = data.techData:getBuildTime()/1000 
            ctime = ctime-(me.sysTime()-data.techData.startTime)/1000
            ctime = me.getIntNum(ctime)-1
            self.timerFunc[data.index]={txt=timeTxt, totalTime=ctime}
            timeTxt:setString(me.formartSecTime(ctime))
        end
    elseif data.type==4 then
        if data.revertingData == nil then
            local buildData = user.building[data.index]
            if buildData.state==3 then ---建筑升级中
                local statusTxt = me.assignWidget(cell, "statusTxt")
                statusTxt:setVisible(true)
                statusTxt:setString("升级中")
                timeTxt:setVisible(true)
                me.assignWidget(cell, "optBtn"):setVisible(false)

                local totalTime = user.buildingDateLine[data.index].countdown / 1000- (me.sysTime()-user.buildingDateLine[data.index].recvTime)/1000
                self.timerFunc[data.index]={txt=timeTxt, totalTime=totalTime}
                timeTxt:setString(me.formartSecTime(totalTime))
            else
                timeTxt:setVisible(false)
                me.assignWidget(cell, "statusTxt"):setVisible(false)
                me.assignWidget(cell, "optBtn"):setVisible(true)
            end
        else
            local statusTxt = me.assignWidget(cell, "statusTxt")
            statusTxt:setVisible(true)
            statusTxt:setString("治疗中")
            timeTxt:setVisible(true)
            me.assignWidget(cell, "optBtn"):setVisible(false)
            local ctime = (data.revertingData.time - data.revertingData.ptime)/ 1000
            ctime = me.getIntNum(ctime-(me.sysTime()-data.revertingData.recvTime)/1000)
            self.timerFunc[data.index]={txt=timeTxt, totalTime=ctime}
            timeTxt:setString(me.formartSecTime(ctime))
        end
    elseif data.type==5 then
        local statusTxt = me.assignWidget(cell, "statusTxt")
        if (user.taxInfo.newFreeCount+user.taxInfo.newPayCount)>=user.taxInfo.maxCount then
            me.assignWidget(cell, "optBtn"):setVisible(false)
            statusTxt:setVisible(true)
            statusTxt:setString("已完成")
            timeTxt:setVisible(true)
            timeTxt:setString(" "..(user.taxInfo.newFreeCount+user.taxInfo.newPayCount).."/"..user.taxInfo.maxCount)
        else
            me.assignWidget(cell, "optBtn"):setVisible(true)
            me.assignWidget(cell, "redpoint"):setVisible(true)
            timeTxt:setVisible(true)
            timeTxt:setString(" "..(user.taxInfo.newFreeCount+user.taxInfo.newPayCount).."/"..user.taxInfo.maxCount)
            statusTxt:setVisible(false)
        end
    elseif data.type==6 then
        local statusTxt = me.assignWidget(cell, "statusTxt")
        if user.runeNormalSearch.free==user.runeNormalSearch.freeNum then
            me.assignWidget(cell, "optBtn"):setVisible(false)
            statusTxt:setVisible(true)
            statusTxt:setString("已完成")
            timeTxt:setVisible(true)
            timeTxt:setString(" "..user.runeNormalSearch.freeNum.."/"..user.runeNormalSearch.free)
        elseif user.runeNormalSearch.freeTime>0 then
            me.assignWidget(cell, "optBtn"):setVisible(false)
            statusTxt:setVisible(true)
            statusTxt:setString("冷却中")
            timeTxt:setVisible(true)
            local ctime = user.runeNormalSearch.freeTime
            ctime = me.getIntNum(ctime-(me.sysTime()-user.runeNormalSearch.recvTime)/1000)
            local callback=function()
                user.runeNormalSearch.freeTime=0
                me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
            end
            self.timerFunc[data.index]={txt=timeTxt, totalTime=ctime, callback=callback}
            timeTxt:setString(me.formartSecTime(ctime))
        else
            me.assignWidget(cell, "optBtn"):setVisible(true)
            me.assignWidget(cell, "redpoint"):setVisible(true)
            timeTxt:setVisible(true)
            timeTxt:setString(" "..user.runeNormalSearch.freeNum.."/"..user.runeNormalSearch.free)
            statusTxt:setVisible(false)
        end
    end
end
function buildOverview:fillHead(cell, data)
    me.assignWidget(cell, "nameTxt"):setString(data.name)
    me.assignWidget(cell, "icon"):loadTexture(data.icon, me.localType)
    me.resizeImage(me.assignWidget(cell, "icon"), 36, 36)
end

function buildOverview:onTableLineJump(idx)
    self:onJump({idx=idx})
end
function buildOverview:onJump(sender)
    local data = self.dataList[sender.idx+1]
    local buildData = mainCity.buildingMoudles[data.index]
    if data.type==2 then
        local function callBack(node)
            if user.buildingDateLine[data.index] then
                buildData:showBuildingMenu()
            else
                NetMan:send(_MSG.prodSoldierView(data.index))
            end
        end
        cameraLookAtNode(buildData, callBack)
    elseif data.type==3 then
        local function callBack(node)
            if user.buildingDateLine[data.index] then
                buildData:showBuildingMenu()
            else
                if data.index==1001 then
                    local converge = convergeView:create("convergeView.csb")
                    mainCity:addChild(converge,me.MAXZORDER)
                    me.showLayer(converge,"bg")         
                else
                    local tv = techView:getInstance()
                    tv:initData(buildData:getDef().id, data.index)
                    mainCity:addChild(tv, 100)
                    me.showLayer(tv, "bg")
                end
            end
        end
        cameraLookAtNode(buildData, callBack)
    elseif data.type==4 then
        local function callBack(node)
            if user.buildingDateLine[data.index] then
                buildData:showBuildingMenu()
            else
                if user.revertingSoldiers[data.index] then
                    local treat = treatView:getInstance()
                    treat:setBuildTofid(data.index)
                    mainCity:addChild(treat,100)
                    me.showLayer(treat, "bg")
                else
                    buildData:showBuildingMenu()
                end
            end
        end
        cameraLookAtNode(buildData, callBack)
    elseif data.type==5 then
        local function callBack(node)
            NetMan:send(_MSG.taxInfo()) 
        end
        cameraLookAtNode(buildData, callBack)
    elseif data.type==6 then
        local function callBack(node)
            mainCity.runeSearch = runeSearch:create("rune/runeSearch.csb")
            mainCity:addChild(mainCity.runeSearch, me.MAXZORDER)        
            me.showLayer(mainCity.runeSearch,"bg")
        end
        cameraLookAtNode(buildData, callBack)
    end

    self:showBox()
end


function buildOverview:timerUpdate(dt)
    local delList={}
    for k, v in pairs(self.timerFunc) do
        v.totalTime = v.totalTime-dt
        if v.txt:getParent():getParent():getParent()~=nil then
            if v.totalTime>0 then
                v.txt:setString(me.formartSecTime(v.totalTime))
            else
                v.txt:setString(me.formartSecTime(0))
                if v.callback then
                    v.callback()
                end
            end
        else  --item被移除table，删除存在的到计时
            table.insert(delList, k)
        end
    end
    for _, v in ipairs(delList) do
        self.timerFunc[v]=nil
    end
end

function buildOverview:checkClick()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, me.assignWidget(self,"bg"))

end
function buildOverview:onTouchBegan(touch, event)
    
    self.moved = cc.p(0, 0)

    return self.isShow 
end

function buildOverview:onTouchMoved(touch, event)
    self.moved = cc.p(self.moved.x + touch:getDelta().x, self.moved.y + touch:getDelta().y)
end
function buildOverview:onTouchEnded(touch, event)
    local x, y = touch:getLocation().x, touch:getLocation().y
    if not cc.rectContainsPoint(me.assignWidget(self,"bg"):getBoundingBox(), cc.p(x, y)) then
        self:showBox()
        return true
    end
end

function buildOverview:updateOverview()
    if self.isShow==true then
        self:collectData()
        local offset=self.tableView:getContentOffset()
        self.tableView:reloadData()
        local size=self.tableView:getContentSize()
        if offset.y<375-size.height then
            offset.y=375-size.height
        end
        self.tableView:setContentOffset(offset)
    end
end

function buildOverview:onEnter()
    print("buildOverview onEnter")   
    self.buildOverviewListener = me.RegistCustomEvent("BUILD_OVERVIEW_UPDATE", handler(self, self.updateOverview))
    
end

function buildOverview:enterTransitionFinish()
end
function buildOverview:onExit()
    me.RemoveCustomEvent(self.buildOverviewListener)
    me.clearTimer(self.timer)
    self.timer = nil

    me.clearTimer(self.redpointTimer)
    self.redpointTimer = nil
end
function buildOverview:resetForWorldMap()

end