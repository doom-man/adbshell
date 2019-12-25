treatBuildingObj = class("treatBuildingObj", buildingObj)
treatBuildingObj.__index = treatBuildingObj
function treatBuildingObj:ctor()
    super(self)
  
end
function treatBuildingObj:init()
    superfunc(self, "init")
    return true
end
function treatBuildingObj:create()
    local layer = treatBuildingObj.new()
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
function treatBuildingObj:onEnter()
    print("treatBuildingObj onEnter")
    superfunc(self, "onEnter")
end
function treatBuildingObj:onExit()
    print("treatBuildingObj onExit")
    me.clearTimer(self.produce_timer)
    superfunc(self, "onExit") 
end

function treatBuildingObj:revertSoldier()
    print("treatBuildingObj:revertSoldier()!!!")
    self.produceLayer:setVisible(true) 
    self.state = BUILDINGSTATE_WORK_TREAT.key
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_TREAT.key
    self.isBusy = true
    self.fLoadbar:setPercent(0)
    local treatData = user.revertingSoldiers[self:getToftId()]
    self.TDTime = 0
    self.time =(treatData.time - treatData.ptime)/ 1000
    local per = math.floor(100 - self.time * 100 / (treatData.time/1000))  
    self.fInfo:setString(self:getNameByState()..me.formartSecTime(self.time))
    self.fInfo_num:setString(per.."%")         
    self.fIcon:loadTexture("icon_b6.png",me.plistType)
    self.produce_timer = me.registTimer(-1, function(dt)
        treatData = user.revertingSoldiers[self:getToftId()]
        if treatData == nil then
            me.clearTimer(self.produce_timer)
            __G__TRACKBACK__("user.revertingSoldiers["..self:getToftId().."]".."is nil !!!!!")
            return
        end

        self.time =(treatData.time - treatData.ptime)/ 1000
        self.TDTime = self.TDTime + dt
        self.time = self.time - self.TDTime
        if self.time <= 0 then
            self.time = 0
        end
        local per = math.floor(100 - self.time * 100 / (treatData.time/1000))  
        self.fInfo:setString(self:getNameByState()..me.formartSecTime(self.time))
        self.fInfo_num:setString(per.."%")         
        self.fLoadbar:setPercent(per)
    end,1)
end 
function treatBuildingObj:revertSoldier_c()
    print("treatBuildingObj:revertSoldier()!!!")
    self.produceLayer:setVisible(true) 
    self.state = BUILDINGSTATE_WORK_TREAT.key
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_TREAT.key
    self.isBusy = true
    self.fLoadbar:setPercent(0)
    local treatData = user.revertingSoldiers_c[self:getToftId()]
    self.TDTime = 0
    self.time =(treatData.time - treatData.ptime)/ 1000
    local per = math.floor(100 - self.time * 100 / (treatData.time/1000))  
    self.fInfo:setString(self:getNameByState()..me.formartSecTime(self.time))
    self.fInfo_num:setString(per.."%")         
    self.fIcon:loadTexture("icon_b6.png",me.plistType)
    self.produce_timer = me.registTimer(-1, function(dt)
        treatData = user.revertingSoldiers_c[self:getToftId()]
        if treatData == nil then
            me.clearTimer(self.produce_timer)
            __G__TRACKBACK__("user.revertingSoldiers["..self:getToftId().."]".."is nil !!!!!")
            return
        end

        self.time =(treatData.time - treatData.ptime)/ 1000
        self.TDTime = self.TDTime + dt
        self.time = self.time - self.TDTime
        if self.time <= 0 then
            self.time = 0
        end
        local per = math.floor(100 - self.time * 100 / (treatData.time/1000))  
        self.fInfo:setString(self:getNameByState()..me.formartSecTime(self.time))
        self.fInfo_num:setString(per.."%")         
        self.fLoadbar:setPercent(per)
    end,1)
end 
function treatBuildingObj:revertSoldierComplete() 
    mAudioMusic:setPlayEffect(MUSIC_EFFECT_CITY_END_STUDY,false)
    --todo
    self.isBusy = false
    self.state = BUILDINGSTATE_NORMAL.key
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
    me.clearTimer(self.produce_timer)
    self.produceLayer:setVisible(false)
end
function treatBuildingObj:faseRevertComplete()
    local anim = allAnimation:createAnimation("scene_build_work_3_05")
    anim:WoundedSoldier(true)
    anim:setPosition(cc.p(self.icon:getContentSize().width/2,self.icon:getContentSize().height/2))
    self:addChild(anim)
end
-- 
-- 获取加速时间
--
function treatBuildingObj:getAccelerateTime() 
       if self:getState()==BUILDINGSTATE_LEVEUP.key or self:getState()==BUILDINGSTATE_BUILD.key then
            return self.time, self.maxTime
       else
           if  user.revertingSoldiers[self:getToftId()] then
                local treatData = user.revertingSoldiers[self:getToftId()]
                local time =(treatData.time - treatData.ptime)/ 1000-self.TDTime
                return time, nil  
           elseif user.revertingSoldiers_c[self:getToftId()] then
                local treatData = user.revertingSoldiers_c[self:getToftId()]
                local time =(treatData.time - treatData.ptime)/ 1000-self.TDTime
                return time, nil  
           end
       end
end
--function treatBuildingObj:getTrainImmeCost()
--    if self.state == BUILDINGSTATE_WORK_TREAT.key then
--        local x = 1 - self.time / self.maxTime
--        local minTime = self:getDef().time2
--        local xtime = minTime * x
--        local tprice = getXresPrice(1, xtime) * xtime
--        return math.ceil(tprice)
--    end
--    return nil
--end
function treatBuildingObj:getProduceTime()
    return self.time
end