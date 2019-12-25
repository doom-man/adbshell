wallBuildingObj = class("wallBuildingObj", buildingObj)
wallBuildingObj.__index = wallBuildingObj
function wallBuildingObj:ctor()
    super(self)
  
end
function wallBuildingObj:init()
    superfunc(self, "init")
    return true
end
function wallBuildingObj:create()
    local layer = wallBuildingObj.new()
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
function wallBuildingObj:onEnter()
    print("wallBuildingObj onEnter")
    superfunc(self, "onEnter")
end
function wallBuildingObj:onExit()
    print("wallBuildingObj onExit")
    superfunc(self, "onExit") 
end
function wallBuildingObj:produceSoldier(sid_)
    self.produceLayer:setVisible(true) 
    self.state = BUILDINGSTATE_WORK_PRODUCE.key
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_PRODUCE.key
    self.isBusy = true
    if  mainCity.train then
        mainCity.train:close()
    end
    print(sid_)
    local pdata = user.produceSoldierData[self:getToftId()]
    local sdata = cfg[CfgType.CFG_SOLDIER][me.toNum(sid_)]
    self.produce_time =(pdata.time - pdata.ptime)/ 1000
    self.fLoadbar:setPercent(0)
    self.pNum = pdata.num
    print("+++++++++++pdata.time="..pdata.time.." pdata.ptime="..pdata.ptime)
    self.produce_timer = me.registTimer(-1, function(dt)
         pdata = user.produceSoldierData[self:getToftId()]         
        if self.pNum == pdata.num and pdata.num > 0  then            
            self.produce_time = self.produce_time - dt
            local per = math.floor(100 - self.produce_time * 100 / (pdata.time/1000))
            self.fInfo:setString(sdata.name .. "x" .. pdata.num)
            self.fInfo_num:setString(per.."%")         
            self.fLoadbar:setPercent(per)
            self.curTime = self.curTime + dt
        elseif (self.pNum - pdata.num) == 1 and pdata.num >0  then 
            self.pNum = pdata.num
            self.curTime = 0
            self.produce_time =dt + (pdata.time - pdata.ptime)/ 1000
            self.fLoadbar:setPercent(0)
        elseif  pdata.num >0  then
            self.pNum = pdata.num
            self.produce_time =(pdata.time - pdata.ptime)/ 1000
            local per = math.floor(100 - self.produce_time * 100 / (pdata.time/1000))           
            self.fInfo:setString(sdata.name .. "x" .. pdata.num)
            self.fInfo_num:setString(per.."%")         
            self.fLoadbar:setPercent(per)
            self.curTime = self.curTime + dt
        end
    end, 0)
end 
function wallBuildingObj:produceSoldierComplete() 
    local pdata = user.produceSoldierData[self:getToftId()] 
    local def = pdata:getDef()
    local kind = def.bigType
    -- 声音
    local pMusicStr = nil
    if kind ==  1  then   -- 步兵
      pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_INFANTRY
    elseif kind == 2 then -- 骑兵
      pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_SOWAR
    elseif kind == 3 then -- 弓兵
      pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_SAPPER
    elseif kind == 4 then -- 车兵
      pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_V_SOLDIER
    end
    if pMusicStr ~= nil then
       mAudioMusic:setPlayEffect(pMusicStr,false)
    end
    --todo
    self.produce_time =   pdata.time - pdata.ptime
    if pdata.num <= 0 then
        self:stopTraining()
    end
end
--function buildingObj:getTrainImmeCost()
--    if self.state == BUILDINGSTATE_BUILD.key or self.state == BUILDINGSTATE_LEVEUP.key then
--        local x = 1 - self.time / self.maxTime
--        print("self.time .."..self.time.." self.maxTime =  "..self.maxTime)
--        local minTime = self:getDef().time2
--        local xtime = minTime * x
--        print("price+++"..getXresPrice(1, xtime))
--        local tprice = getXresPrice(1, xtime) * xtime
--        print("self.time1111++++"..(self.maxTime-self.time))
--        print(' minTime='..minTime..' self.time='..self.time..'  self.maxTime='..self.maxTime..'   xtime='..xtime..'   tprice='..tprice..' x='..x)
--        return math.ceil(tprice)
--    end
--    return nil
--end