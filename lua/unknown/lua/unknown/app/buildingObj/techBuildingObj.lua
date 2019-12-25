--jnmo
techBuildingObj = class("techBuildingObj",buildingObj)
techBuildingObj.__index = techBuildingObj
function techBuildingObj:ctor()
    super(self)  
    self.food_time = 0
end
function techBuildingObj:init()
    superfunc(self,"init")
    return true
end
function techBuildingObj:create()
    local layer = techBuildingObj.new()
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
function techBuildingObj:onEnter()
    print("techBuildingObj onEnter")
    superfunc(self,"onEnter") 
end

function techBuildingObj:hideTechingBar()
    self:setState(BUILDINGSTATE_NORMAL.key)
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
    self.levelupani:setVisible(false)
end

-- 更新分配后升级时间
function techBuildingObj:updateTechAllot()
    local techData = techDataMgr.getTechDataByTofId(self:getToftId())
    local ctime = techData:getBuildTime()/1000 
   -- -(me.sysTime() - techData.startTime)/1000  
    local ctime = techData:getBuildTime()/1000
    --(me.sysTime() - techData.startTime)/1000
    self:showTechingBar(ctime)
end

function techBuildingObj:showTechingBar(ctime)
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
        if self.maxTime-self.time <= self.maxTime and self.maxTime-self.time > 0 then
            timebar:setPercent(100 * self.time / self.maxTime)
            time:setString(self:getNameByState()..me.formartSecTime(self.maxTime-self.time))
        end
    end
    if self.produce_timer == nil then
        self.produce_timer = me.registTimer(self.maxTime-self.time, update,1)
    end
    time:setString(self:getNameByState()..me.formartSecTime(self.maxTime-self.time))
    self.levelupani:setVisible(true)
end 

function techBuildingObj:onExit()
    print("techBuildingObj onExit") 
    me.clearTimer(self.produce_timer)
    superfunc(self,"onExit")
end



  


