-- 市场礼包
towerBuildingObj = class("towerBuildingObj", buildingObj)
towerBuildingObj.__index = towerBuildingObj
function towerBuildingObj:ctor()
    super(self)
end
function towerBuildingObj:init()
    superfunc(self, "init")
    self.gainBtn = me.assignWidget(self, "gainBtn")
    self.originX = self.gainBtn:getPositionX()
    self.originY = self.gainBtn:getPositionY()
    self.gainImg = me.assignWidget(self.gainBtn, "gain_img"):loadTexture("zhucheng_mengzhang_zhengchang.png", me.localType)
    me.registGuiClickEvent(self.gainBtn, function(node)
        local converge = convergeView:create("convergeView.csb")
        mainCity:addChild(converge, me.MAXZORDER)
        me.showLayer(converge, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    return true
end
function towerBuildingObj:create()
    local layer = towerBuildingObj.new()
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

function towerBuildingObj:onEnter()
    print("towerBuildingObj onEnter")
    superfunc(self, "onEnter")

    -- self.icon:removeAllChildren()
end
function towerBuildingObj:seeGain()
    self.gainBtn:setPosition(cc.p(self.originX - 140, self.originY))
    me.assignWidget(self.gainBtn, "gain_img"):setPositionX(self.gainBtn:getContentSize().width / 2 - 3)
    me.assignWidget(self.gainBtn, "gain_img"):setContentSize(cc.size(82, 81));
    self.gainBtn:setVisible(true)
    self.gainBtn:stopAllActions()
    self:hideFreeHelpBtn()
    local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() + 30))
    local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() -30))
    self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
end
function towerBuildingObj:closeGain()
    self.gainBtn:setVisible(false)
    self.gainBtn:stopAllActions()
end
function towerBuildingObj:onExit()
    print("towerBuildingObj onExit")
    me.clearTimer(self.produce_timer)
    self.produce_timer = nil
    superfunc(self, "onExit")
end
function towerBuildingObj:getGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end

function towerBuildingObj:hideTechingBar()
    me.clearTimer(self.produce_timer)
    self.produce_timer = nil
    self:setState(BUILDINGSTATE_NORMAL.key)
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
    self.levelupani:setVisible(false)
end

function towerBuildingObj:showTechingBar(ctime)
    self.techDef = techDataMgr.getTechDefByTofId(self:getToftId())
    local def = user.building[self:getToftId()]:getDef()
    self.maxTime = getTechTime(self.techDef, self:getData().worker, def.type)
    ctime = me.getIntNum(ctime)
    self.time = 0
    if ctime then
        self.time = self.maxTime - ctime
    end
    if self.state == BUILDINGSTATE_WORK_STUDY.key then
        return
    end
    self:setState(BUILDINGSTATE_WORK_STUDY.key)
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_STUDY.key
    local timebarbg = me.assignWidget(self, "timebarbg")
    local timebar = me.assignWidget(self.levelupani, "timebar")
    local time = me.assignWidget(self.levelupani, "time")
    timebar:setPercent(self.time / self.maxTime * 100)
    local function update(dt)
        self.time = self.time + dt
        if self.maxTime - self.time <= self.maxTime and self.maxTime - self.time > 0 then

            timebar:setPercent(100 * self.time / self.maxTime)
            time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
        end
    end

    if self.produce_timer == nil then
        self.produce_timer = me.registTimer(self.maxTime - self.time, update, 1)
    end
    time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
    self.levelupani:setVisible(true)
end 

-- 更新分配后升级时间
function towerBuildingObj:updateTechAllot()
    local techData = techDataMgr.getTechDataByTofId(self:getToftId())
    local ctime = techData:getBuildTime() / 1000 -(me.sysTime() - techData:getStartTime()) / 1000
    self:showTechingBar(ctime)
end



 
