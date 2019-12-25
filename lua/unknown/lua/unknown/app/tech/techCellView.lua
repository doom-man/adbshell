techCellView = class("techCellView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techCellView._index = techCellView
function techCellView:create(csb)
    local layer = techCellView.new(csb)
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

function techCellView:ctor()
    self.dataId=nil
end

function techCellView:init()
    self.Layer = me.assignWidget(self,"Layer")
    self.Button_Center = me.assignWidget(self, "Button_Center")
    local moveDis = 0
    local function btnTouchEvent(node, event)
        if event == ccui.TouchEventType.ended then        
            local mp =  node:getTouchMovePosition()
            local sp = node:getTouchBeganPosition()   
            if math.abs(mp.x-sp.x) <= 25 or math.abs(mp.x) == 0  then
                self:btnCenterOnClick()
            end
        end
    end
    self.Button_Center:addTouchEventListener(btnTouchEvent)
    self.Button_Center:setSwallowTouches(false) 
    self.Image_TimeBoard = me.assignWidget(self, "Image_TimeBoard")
    self.Text_Time = me.assignWidget(self, "Text_Time")
    self.Image_Level = me.assignWidget(self, "Image_Level")
    self.Text_Level = me.assignWidget(self, "Text_Level")
    self.Node_Anim = me.assignWidget(self, "Node_Anim")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Image_NeedLv = me.assignWidget(self, "Image_NeedLv")

    return true
end

function techCellView:setCellDataID(dataId_)
    self.dataId = dataId_
end

function techCellView:getCellDataID()
    return self.dataId
end

--1:当前等级/最大等级,2:科技名字颜色 3:png名字 4:是否在升级  5:是否开启  6:科技数据
function techCellView:flushCellView(...)
    local args = {...}
    local tmpDef = args[6]:getDef()
    self.Text_Level:setString(args[1])
    self.Text_Name:setTextColor(args[2])
    self.Image_Level:loadTexture(args[3],me.localType)
    --设置升级时间
    if args[4] then
        self.leftTime = args[6]:getBuildTime()-(me.sysTime() - args[6].startTime)
        self.leftTime = me.getIntNum(self.leftTime/1000)
--        print("self.leftTime = "..self.leftTime)
        if self.leftTime and self.leftTime > 0 then
            me.clearTimer(self.cellTimer)
            self.cellTimer = me.registTimer(self.leftTime ,function (dt,b)
                self.leftTime = self.leftTime - dt
                self.Text_Time:setString(me.formartSecTime(self.leftTime))
                if b then
                    --可以解锁
                    self.Image_TimeBoard:setVisible(false)
                end
            end,1)
            -- 设置科技所在的建筑物的升级时间
            local tarBuild = mainCity.buildingMoudles[techDataMgr:getCurToftid()]
            if tarBuild then
                tarBuild:showTechingBar(args[6]:getBuildTime()/1000-(me.sysTime() - args[6].startTime)/1000)
            else
                print("mainCity.buildingMoudles tofId = "..techDataMgr:getCurToftid().." is nil !!!")
            end
        else 
            me.clearTimer(self.cellTimer)
            self.Text_Time:setString("00:00:00")
            self.Image_TimeBoard:setVisible(false)
        end
        self.Image_TimeBoard:setVisible(true)
    else
        me.clearTimer(self.cellTimer)
        self.Image_TimeBoard:setVisible(false)
    end
    self.spImage = me.assignWidget(self,"Image_icon")    
    self.spImage:loadTexture(techIcon(tmpDef.icon),me.localType)
    if args[5]==false then --未开启
        self.Button_Center:loadTextureNormal(techData.Img.TECH_UNENABLE, me.localType)
        me.Helper:grayImageView(self.spImage)
    else --已开启
        self.Button_Center:loadTextureNormal(techData.Img.TECH_ENABLE, me.localType)
        me.Helper:normalImageView(self.spImage)
    end
    self.Text_Name:setString(tmpDef.name)
end

function techCellView:initData()
    local tmpData = user.techTypeDatas[self.dataId]
    if tmpData == nil then
        print("self.dataId = "..self.dataId)
    end
    local tmpStatus = tmpData:getLockStatus()
    local tmpDef = tmpData:getDef()
    
    if nil == tmpDef then
        __G__TRACKBACK__("cellData is nil !!!!")
        return
    end    

    self.Node_Anim:removeAllChildren()
    local maxLv = techDataMgr.getMaxLevelByTechId(tmpDef.techid)
    --解锁状态
    if tmpStatus == techData.lockStatus.TECH_UNLOCKED then
        local tmpLv = 0
        if tmpDef.level > 1 then
            tmpLv = tmpDef.level
        end
        --添加解锁动画
        local ani = createArmature("keji_jiesuo")
        self.Node_Anim:addChild(ani)
        ani:getAnimation():play("donghua")
        self:flushCellView(tmpLv.."/"..maxLv, me.convert3Color_("fff2d3"),techData.Img.TECH_TITLE_UNENABLE,false,false,tmpData)        
        self.Button_Center:loadTextureNormal(techData.Img.TECH_ENABLE, me.localType)
    --未开启状态
    elseif tmpStatus == techData.lockStatus.TECH_UNUSED then
        self:flushCellView("0/"..maxLv, me.convert3Color_("fff2d3"),techData.Img.TECH_TITLE_UNENABLE,false,false,tmpData)
    --开启状态
    elseif tmpStatus == techData.lockStatus.TECH_USED then
        self:flushCellView(tmpDef.level.."/"..maxLv, me.convert3Color_("fff2d3"),techData.Img.TECH_TITLE_ENABLE,false,true,tmpData)
    --正在升级状态
    elseif tmpStatus == techData.lockStatus.TECH_TECHING then
        local tmpLv = 0
        if tmpDef.level > 1 then
            tmpLv = tmpDef.level
        else
            --需要特殊判断下，是0级未解锁升级到1级，还是1级升级到2级,因为界面表现是一样的
            local tmpId = techDataMgr.getTechIDByTypeAndLV(tmpDef.techid,tmpDef.level+1)
            if user.techServerDatas[tmpId] then
                tmpLv = tmpDef.level
            end
        end
        self:flushCellView(tmpLv.."/"..maxLv, me.convert3Color_("fff2d3"),techData.Img.TECH_TITLE_ENABLE,true,true,tmpData)
    --升级完成状态
    elseif tmpStatus == techData.lockStatus.TECH_FINISH then
        self:flushCellView(tmpDef.level.."/"..maxLv, me.convert3Color_("fff2d3"),techData.Img.TECH_TITLE_ENABLE,false,true,tmpData)
    end
end

function techCellView:onEnter()
    self:initData()
end

function techCellView:onExit()
    me.clearTimer(self.cellTimer)
end

function techCellView:btnCenterOnClick()
    local tmpData = user.techTypeDatas[self.dataId]
    if tmpData == nil then
        __G__TRACKBACK__("self.dataId = "..self.dataId.." is nil")
        return
    end

    if tmpData:getLockStatus() ~= techData.lockStatus.TECH_TECHING then
        local tmpView = techDetailView:create("techUpgradeView.csb")
        tmpView:setTechDataID(self.dataId)
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    else
        local tmpView = techingView:create("techingView.csb")
		tmpView:setRelatedObj(self)
        tmpView:setItemData(self.dataId, self.leftTime)
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")    
    end
end


---
-- 获取加速时间
--
function techCellView:getAccelerateTime()
    self:initData()
    local tofid = techDataMgr.getCurToftid()
    local dataId = 0
    if user.techServerDatas[me.toNum(self.dataId)] then
        local tmpData = user.techServerDatas[me.toNum(self.dataId)]
        if tmpData:getLockStatus() == techData.lockStatus.TECH_TECHING then
            dataId = self.dataId
        else
            local tmpdef = cfg[CfgType.TECH_UPDATE][me.toNum(self.dataId)]
            dataId = tmpdef.nextid
        end
    end
    local def = cfg[CfgType.TECH_UPDATE][me.toNum(dataId)]
    if def == nil then
        return 0, 0
    end
    if user.techServerDatas[def.id] == nil then
        return 0, 0
    end

    self.totalTime = getTechTime(def,user.building[tofid].worker)
    return self.totalTime-self.leftTime,self.totalTime
end
---
-- 获取免费时间
--
function techCellView:getFreeTime()
    return 0
end
