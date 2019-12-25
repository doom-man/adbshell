farmerMoudle = class("farmerMoudle", mAnimation)
farmerMoudle.__index = farmerMoudle
FARMER_JOB_PLANT = 1   -- 种田
PARMER_JOB_WOOD = 2 -- 伐木
FARMER_JOB_MINER = 3  -- 采矿
FARMER_JOB_STROLL = 4   -- 闲逛
FARMER_JOB_STANDBY = 5 --
FARMER_JOB_WORKER = 6 --
function farmerMoudle:ctor()
    super(self)
    self.tagbId = -1
    self.basePoint = cc.p(0, 0)
    self.farmerJob = 0
    -- 1 农民种植
    -- 活动中心点
    self.centre = nil
    self.woodPointId = 0
end
function farmerMoudle:setCentre(p)
    self.centre = p
end
function farmerMoudle:setFarmerJob(j)
   self.farmerJob = j
end
function farmerMoudle:getFarmerJob()
   return self.farmerJob
end
function farmerMoudle:createAni(aname)
    local layer = farmerMoudle.new(aname)
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
function farmerMoudle:init()

    return true
end
function farmerMoudle:onEnter()
    print("farmerMoudle:onEnter")
    --  local pp =  cc.p(mainCity.crowds:getPositionX(), mainCity.crowds:getPositionY())
    local function aniend(node)
        node:getAnimation():setSpeedScale(0.5)
        node:doAction(MANI_STATE_IDLE)
    end
    local function plantEnd(node)
        node:getAnimation():setSpeedScale(1)
        node:doAction(MANI_STATE_PLANT)
    end
    local function mingEnd(node)
        node:getAnimation():setSpeedScale(1)
        node:doAction(MANI_STATE_MINING)
    end
    local function woodEnd(node)
        node:getAnimation():setSpeedScale(1)
        if node.woodPointId == 1 then 
          node.direction = DIR_RIGHT
        elseif node.woodPointId == 2 then
          node.direction = DIR_LEFT
        elseif node.woodPointId == 3 then
          node.direction = DIR_RIGHT_TOP
        elseif node.woodPointId == 4 then
          node.direction = DIR_TOP
        end
        node:doAction(MANI_STATE_WOOD)
    end
    self.m_timer = me.registTimer(-1, function(dt)
        if self.farmerJob == FARMER_JOB_STROLL then
            if self.state == MANI_STATE_IDLE then
                if me.getRandom(2) == 1 then
                    local p = me.randInRect(self.centre, me.rand()%100, me.rand()%100)
                    self:moveToPoint(p, aniend)
                end
            end
        elseif self.farmerJob == FARMER_JOB_PLANT then
            if self.state == MANI_STATE_PLANT then
                if me.getRandom(2) == 1 then
                    local p = me.randInRect(self.centre, 100, 100)
                    self:moveToPoint(p, plantEnd)
                else
                    if #mainCity.foodBuildingToftId > 0  then
                      local toftId = mainCity.foodBuildingToftId[me.getRandom(#mainCity.foodBuildingToftId)]
                      local obj = mainCity.buildingMoudles[toftId]
                      local lp = cc.p(self:getPositionX(),self:getPositionY())
                      local pos = self:getGoToBuildingPos(lp,obj)
                      if user.building[toftId] and user.building[toftId].state ~= BUILDINGSTATE_BUILD.key and pos then
                          local pQ1 = Queue.new()
                          local pQ2 = Queue.new()
                          Queue.push(pQ1,pos)
                          Queue.push(pQ2,lp)
                          self:carryToBuilding(pQ1,pQ2,plantEnd,MANI_STATE_CARRY)
                      end
                    --  self:moveToBuilding(obj, plantEnd)
                    end
                end
            end
        elseif self.farmerJob == FARMER_JOB_MINER then 
              if self.state == MANI_STATE_MINING then
                if me.getRandom(2) == 1 then
                  local p = me.randInRect(self.centre, 100, 100)
                  self:moveToPoint(p, mingEnd)
                else
                    if #mainCity.stoneBuildingToftId > 0  then
                        local p = me.randInRect(self.centre, 100, 100)
                        local toftId = mainCity.stoneBuildingToftId[me.getRandom(#mainCity.stoneBuildingToftId)]
                        local obj = mainCity.buildingMoudles[toftId]
                        --local pos = cc.p(obj:getPositionX()+obj.icon:getPositionX(),obj:getPositionY()+obj.icon:getPositionY())
                        local lp = cc.p(self:getPositionX(),self:getPositionY())
                        local pos = self:getGoToBuildingPos(lp,obj)
                        local pQ1 = Queue.new()
                        local pQ2 = Queue.new()
                        Queue.push(pQ1,pos)
                        Queue.push(pQ2,lp)
                        self:carryToBuilding(pQ1,pQ2,mingEnd,MANI_STATE_CARRY)
                    --self:moveToBuilding(obj, mingEnd)
                    end
                end
            end
        elseif self.farmerJob == PARMER_JOB_WOOD then 
              if self.state == MANI_STATE_WOOD then
                if me.getRandom(2) == 1 then
--                    local p = me.randInRect(self.centre, 100, 100)
--                    self:moveToPoint(p, woodEnd)
                else
                    if #mainCity.woodBuildingToftId > 0  then
                       --local p = me.randInRect(self.centre, 100, 100)
                       local pQ1,pQ2 = self:getWoodCarryPath()
                       self:carryToBuilding(pQ1, pQ2, woodEnd, MANI_STATE_CARRY)              
                    end
                
                end
            end
        end
    end , me.getRandom(10) + 10)
end
function farmerMoudle:moveToPoint(p_, callfunc,aname_)
    self:getAnimation():setSpeedScale(2.0)
    superfunc(self, "moveToPoint", p_, callfunc,aname_)
end
function farmerMoudle:gobackAndIdle()
    self:stopAllActions()
    self:doAction("idle")
    self:setPosition(self.basePoint)
    self.tagbId = -1
    self:setState(MANI_STATE_IDLE)
    self:setFarmerJob(FARMER_JOB_STANDBY)
  --  self:getAnimation():setSpeedScale(0.5)
    self:setVisible(false)
end  
function farmerMoudle:setBasePoint(b)
    self.basePoint = b
end
function farmerMoudle:getBasePoint()
    return self.basePoint
end
function farmerMoudle:setTagBuildingId(id)
    self.tagbId = id
end
function farmerMoudle:getTagBuildingId()
    return self.tagbId
end
function farmerMoudle:onExit()
    me.clearTimer(self.m_timer)
end

function farmerMoudle:getGoToBuildingPos(lp,obj)
    if obj == nil then
        return nil
    end
    local cp = cc.p(obj:getPositionX()+obj.icon:getPositionX(),obj:getPositionY()+obj.icon:getPositionY())
    local dis = cc.pGetDistance(lp,cp)
    local radius = obj.icon:getContentSize().width-100
    local disNew = cc.pGetDistance(lp,cp) - radius
    local sina = (cp.y - lp.y) / dis
    local cosa = (cp.x - lp.x) / dis
    local pos = cc.p(lp.x + disNew * cosa, lp.y + disNew * sina)
    return pos 
end

function farmerMoudle:getWoodCarryPath()
  local pQ1 = Queue.new()
  local pQ2 = Queue.new()
  local lp = cc.p(self:getPositionX(),self:getPositionY())
  if self.woodPointId == 1 then 
        local toftId = mainCity.woodBuildingToftId[me.getRandom(#mainCity.woodBuildingToftId)]
        if toftId % 10 == 3 then toftId = toftId - 1 end
        local obj = mainCity.buildingMoudles[toftId]
        if toftId == 200004 then 
            local pos = self:getGoToBuildingPos(lp,obj)
            local mid = cc.p(pos.x + 50, pos.y - 100)
            Queue.push(pQ1,mid)
            Queue.push(pQ1,pos)
            Queue.push(pQ2,mid)
            Queue.push(pQ2,lp)
        else
        --local pos = cc.p(obj:getPositionX()+obj.icon:getPositionX(),obj:getPositionY()+obj.icon:getPositionY())
            local pos = self:getGoToBuildingPos(lp,obj)
            Queue.push(pQ1,pos)
            Queue.push(pQ2,lp)
        end
  elseif self.woodPointId == 2 then 
        local toftId = 200002
        local obj = mainCity.buildingMoudles[toftId]
        if obj then
            local p = me.assignWidget(mainCity,"woodPath2_1")
            local mid = cc.p(lp.x + p:getPositionX(), lp.y + p:getPositionY())
            local pos = self:getGoToBuildingPos(mid,obj)
            Queue.push(pQ1,mid)
            Queue.push(pQ1,pos)
            Queue.push(pQ2,mid)
            Queue.push(pQ2,lp)
        else 
            local pos = self:getGoToBuildingPos(lp,mainCity.buildingMoudles[toftId-1]) 
            if pos then
                Queue.push(pQ1,pos)
                Queue.push(pQ2,lp)
            end
        end
  elseif self.woodPointId == 3 then 
        local toftId = 200003
        local obj = mainCity.buildingMoudles[toftId]
        if obj then
            local pos = self:getGoToBuildingPos(lp,obj)
            Queue.push(pQ1,pos)
            Queue.push(pQ2,lp)
        else
            local pos = nil
            local p1 = me.assignWidget(mainCity,"woodPath3_1")
            local mid1 = cc.p(lp.x + p1:getPositionX(), lp.y + p1:getPositionY())
            local p2 = me.assignWidget(mainCity,"woodPath3_2")
            local mid2 = cc.p(lp.x + p2:getPositionX(), lp.y + p2:getPositionY())
            if mainCity.buildingMoudles[toftId-1] then 
                pos = self:getGoToBuildingPos(mid2,mainCity.buildingMoudles[toftId-1])
            else
                pos = self:getGoToBuildingPos(mid2,mainCity.buildingMoudles[toftId-2])
            end
            if pos then 
                Queue.push(pQ1,mid1)
                Queue.push(pQ1,mid2)
                Queue.push(pQ1,pos)
                Queue.push(pQ2,mid2)
                Queue.push(pQ2,mid1)
                Queue.push(pQ2,lp)
            end
        end                                  
  elseif self.woodPointId == 4 then 
        local toftId = 200001
        local obj = mainCity.buildingMoudles[toftId]
        local p1 = me.assignWidget(mainCity,"woodPath4_1")
        local mid1 = cc.p(lp.x + p1:getPositionX(), lp.y + p1:getPositionY())
        local p2 = me.assignWidget(mainCity,"woodPath4_2")
        local mid2 = cc.p(lp.x + p2:getPositionX(), lp.y + p2:getPositionY())
        local pos = self:getGoToBuildingPos(mid2,obj)
        Queue.push(pQ1,mid1)
        Queue.push(pQ1,mid2)
        Queue.push(pQ1,pos)
        Queue.push(pQ2,mid2)
        Queue.push(pQ2,mid1)
        Queue.push(pQ2,lp)
  end
  return pQ1, pQ2   
end

