-- jnmo
barrackBuildingObj = class("barrackBuildingObj", buildingObj)
barrackBuildingObj.__index = barrackBuildingObj
function barrackBuildingObj:ctor()
    super(self)
  
end
function barrackBuildingObj:init()
    superfunc(self, "init")

    return true
end
function barrackBuildingObj:create()
    local layer = barrackBuildingObj.new()
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
function barrackBuildingObj:onEnter()
    print("barrackBuildingObj onEnter")
    superfunc(self, "onEnter")
end
function barrackBuildingObj:onExit()
    print("barrackBuildingObj onExit")
    superfunc(self, "onExit") 
end
function barrackBuildingObj:produceSoldier(sid_)    
    self.produceLayer:setVisible(true) 
    self:setState(BUILDINGSTATE_WORK_TRAIN.key)
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_TRAIN.key
    self.isBusy = true
    if  mainCity.train then
        mainCity.train:close()
    end
    print(sid_)
    local pdata = user.produceSoldierData[self:getToftId()]
    local sdata = cfg[CfgType.CFG_SOLDIER][me.toNum(sid_)]
    if  sdata.bigType  == 90 then
           self.fIcon:loadTexture("icon_b5.png",me.plistType)    
    else
           self.fIcon:loadTexture("icon_b"..sdata.bigType..".png",me.plistType)    
    end
    self.produce_time =(pdata.time - pdata.ptime)/ 1000
    self.fLoadbar:setPercent(0)
    self.pNum = pdata.num
    self.produce_timer = me.registTimer(-1, function(dt)
         pdata = user.produceSoldierData[self:getToftId()]  
         self.produce_time =(pdata.time - pdata.ptime)/ 1000 - self.curTime   
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
               self.produce_time =dt + (pdata.time - pdata.ptime)/ 1000 - self.curTime
               self.fLoadbar:setPercent(0)
        elseif  pdata.num >0  then
            self.pNum = pdata.num
            self.produce_time =(pdata.time - pdata.ptime)/ 1000 - self.curTime
            local per = math.floor(100 - self.produce_time * 100 / (pdata.time/1000))           
            self.fInfo:setString(sdata.name .. "x" .. pdata.num)
            self.fInfo_num:setString(per.."%")         
            self.fLoadbar:setPercent(per)
            self.curTime = self.curTime + dt
        end
    end, 0)
end
function barrackBuildingObj:produceSoldierComplete() 
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
--    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE then
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