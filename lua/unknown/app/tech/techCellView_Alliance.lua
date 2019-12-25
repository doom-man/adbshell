techCellView_Alliance = class("techCellView_Alliance ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techCellView_Alliance._index = techCellView_Alliance
function techCellView_Alliance:create(csb)
    local layer = techCellView_Alliance.new(csb)
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

function techCellView_Alliance:ctor()
    self.dataId=nil
    self.progressT = nil --积分进度对象
end

function techCellView_Alliance:init()
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
    self.Node_Progress = me.assignWidget(self,"Node_Progress")
    self.Node_Progress:setVisible(false)
    return true
end

function techCellView_Alliance:setCellDataID(dataId_)
    self.dataId = dataId_
end

function techCellView_Alliance:getCellDataID()
    return self.dataId
end

--1:当前等级/最大等级,2:科技名字颜色 3:png名字 4:是否在升级  5:是否开启  6:科技数据
function techCellView_Alliance:flushCellView(...)
    local args = {...}
    local tmpDef = args[6]:getDef()
    self.Text_Level:setString(args[1])
    self.Text_Name:setTextColor(args[2])
    self.Image_Level:loadTexture(args[3],me.localType)
    --设置升级时间
    if args[4] then
        self.leftTime = args[6]:getUpdateTime()-(me.sysTime() - args[6]:getStartTime())
        self.leftTime = me.getIntNum(self.leftTime/1000)
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

--设置积分进度圈
function techCellView_Alliance:setProgressTimer(data,def)
    local currentP = data:getPoint()
    local totalP = def.point
    if data:getLockStatus() ~= allianceTechData.lockStatus.TECH_GIVEN then
        if def.nextid ~= 0 then
            totalP = cfg[CfgType.TECH_FAMILY][def.nextid].point
        end
    end

    if currentP>0 then
        if self.progressT == nil then
            local sp = me.createSprite("keji_tubiankuang_liang_guang.png")
            self.progressT = cc.ProgressTimer:create(sp)
            self.progressT:setAnchorPoint(cc.p(0.5,0.5))
            self.Node_Progress:addChild(self.progressT)
            self.progressT:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        end
        local per = math.ceil(currentP/totalP*100)
        if per>100 then
            per = 100
        end
        self.progressT:setPercentage(per)
    end
    self.Node_Progress:setVisible(currentP>0)
end

function techCellView_Alliance:initData()
    local def = cfg[CfgType.TECH_FAMILY][self.dataId]
    local tmpData = user.familyTechDatas[def.techid]
    if tmpData == nil then
        print("self.dataId = "..self.dataId)
        return
    end
    local tmpStatus = tmpData:getLockStatus()
    local tmpDef = tmpData:getDef()
    if nil == tmpDef then
        __G__TRACKBACK__("cellData is nil !!!!")
        return
    end    

    self.Node_Anim:removeAllChildren()
    self:setProgressTimer(tmpData,tmpDef)
    local maxLv = techDataMgr.getMaxFamilyTechLevelByTechId(tmpDef.techid)
    --解锁状态
    if tmpStatus == allianceTechData.lockStatus.TECH_UNLOCKED then
        local tmpLv = 0
        if tmpDef.level > 1 then
            tmpLv = tmpDef.level
        end
        --添加解锁动画
        print("解锁动画 name = "..tmpDef.name)
        local ani = createArmature("keji_jiesuo")
        self.Node_Anim:addChild(ani)
        self.Node_Anim:setVisible(true)
        ani:getAnimation():play("donghua")
        self.Button_Center:loadTextureNormal(techData.Img.TECH_ENABLE, me.localType)
        self:flushCellView(tmpLv.."/"..maxLv, COLOR_WHITE,techData.Img.TECH_TITLE_UNENABLE,false,false,tmpData)
    --未开启状态
    elseif tmpStatus == allianceTechData.lockStatus.TECH_UNUSED then
        self:flushCellView("0/"..maxLv, COLOR_WHITE,techData.Img.TECH_TITLE_UNENABLE,false,false,tmpData)
    --开启状态
    elseif tmpStatus == allianceTechData.lockStatus.TECH_USED then
        self:flushCellView(tmpDef.level.."/"..maxLv, COLOR_ORANGE,techData.Img.TECH_TITLE_ENABLE,false,true,tmpData)
    --正在升级状态(0级升级)
    elseif tmpStatus == allianceTechData.lockStatus.TECH_TECHING_UNSED  then
        local tmpLv = tmpDef.level-1
        self:flushCellView(tmpLv.."/"..maxLv, COLOR_ORANGE,techData.Img.TECH_TITLE_ENABLE,true,true,tmpData)
    --正在升级状态(非0级升级)
    elseif tmpStatus == allianceTechData.lockStatus.TECH_TECHING then        
        self:flushCellView(tmpLv.."/"..maxLv, COLOR_ORANGE,techData.Img.TECH_TITLE_ENABLE,true,true,tmpData)
    --捐赠状态
    elseif tmpStatus == allianceTechData.lockStatus.TECH_GIVEN then
        local tmpLv = tmpDef.level-1
        print("捐赠状态 = "..tmpDef.id)
        self:flushCellView(tmpLv.."/"..maxLv, COLOR_ORANGE,techData.Img.TECH_TITLE_ENABLE,false,false,tmpData)
    end
end

function techCellView_Alliance:onEnter()
    self:initData()
    self.listener = UserModel:registerLisener(function (msg)
        self:updateData(msg)
    end)
end

function techCellView_Alliance:updateData(msg)
    if checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN) then
        self:flushProgressTimer()
    elseif checkMsg(msg.t, MsgCode.FAMILY_FINISH_UPDATING) then
        local msgTechid = cfg[CfgType.TECH_FAMILY][me.toNum(msg.c.id)].techid
        local dataTechid = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)].techid
        if msgTechid == dataTechid then
            self:setCellDataID(msg.c.id)
            self:initData()
        end

        if techDataMgr.getUnlockedTechID_Alliance(msgTechid,dataTechid) then --升级完的科技类型，可能解锁到的科技刷新数据
            self:initData()
        end
    elseif checkMsg(msg.t, MsgCode.UPDATE_FAMILY_TECH) then
        local msgTechid = cfg[CfgType.TECH_FAMILY][me.toNum(msg.c.id)].techid
        local dataTechid = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)].techid
        if msgTechid == dataTechid then
            self:setCellDataID(msg.c.id)
            self:initData()
        end
    end
end

function techCellView_Alliance:flushProgressTimer()
    local def = cfg[CfgType.TECH_FAMILY][self.dataId]
    local tmpData = user.familyTechDatas[def.techid]
    local tmpDef = tmpData:getDef()
    self:setProgressTimer(tmpData,tmpDef)
    if me.toNum(tmpData:getPoint())>0 then
        self.Node_Anim:removeAllChildren()
    end
end

function techCellView_Alliance:onExit()
    UserModel:removeLisener(self.listener)
    me.clearTimer(self.cellTimer)
end

function techCellView_Alliance:btnCenterOnClick()
    local def = cfg[CfgType.TECH_FAMILY][self.dataId]
    local tmpData = user.familyTechDatas[def.techid]
    if tmpData == nil then
        __G__TRACKBACK__("self.dataId = "..self.dataId.." is nil")
        return
    end
    local pParect = mainCity
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then    
        pParect = pWorldMap        
    end
    if tmpData:getLockStatus() == allianceTechData.lockStatus.TECH_USED then --已经升级过的联盟科技，点击查看下一级
        local tmpView = techDetailView_Alliance:create("techUpgradeView_Alliance.csb")
        tmpView:setTechDataID(self.dataId)        
        pParect:addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    elseif tmpData:getLockStatus() == allianceTechData.lockStatus.TECH_TECHING or 
    tmpData:getLockStatus() == allianceTechData.lockStatus.TECH_TECHING_UNSED then --正在升级中，查看加速界面
        local tmpView = techingView_Alliance:create("techingView_Alliance.csb")
        tmpView:setItemData(self.dataId, self.leftTime)
        pParect:addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")   
    else -- 0等级，查看的是1级的联盟科技
        local tmpView = techDetailView_Alliance:create("techUpgradeView_Alliance.csb")
        tmpView:setTechDataID(self.dataId)
        pParect:addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    end
end
