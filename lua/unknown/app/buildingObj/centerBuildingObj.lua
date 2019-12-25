--jnmo
centerBuildingObj = class("centerBuildingObj",buildingObj)
centerBuildingObj.__index = centerBuildingObj
function centerBuildingObj:ctor()
    super(self)  
    
end
function centerBuildingObj:init()
    superfunc(self,"init")
    return true
end
function centerBuildingObj:create()
    local layer = centerBuildingObj.new()
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
function centerBuildingObj:onEnter()
    print("centerBuildingObj onEnter")

    superfunc(self,"onEnter")    
end
function centerBuildingObj:onExit()
    print("centerBuildingObj onExit") 
    superfunc(self,"onExit")
end
function centerBuildingObj:ProduceFarmer()
    self.produceLayer:setVisible(true)
    self.state = BUILDINGSTATE_WORK_TRAIN.key    
    user.building[self:getToftId()].state = BUILDINGSTATE_WORK_TRAIN.key
    if self.produce_timer == nil then
        print(user.produceframerdata.time)
        print(user.produceframerdata.ptime)
        self.produce_time = user.produceframerdata.time - user.produceframerdata.ptime
        self.produce_timer = me.registTimer(-1, function(dt)
            if self.produce_time - dt > 0 then
                --       print(self.produce_time.."---"..user.produceframerdata.time)
                self.produce_time = self.produce_time - dt
                local per = math.floor(100 - self.produce_time * 100 / user.produceframerdata.time)
                self.fInfo:setString("农民x" .. user.produceframerdata.num)
                 self.fInfo_num:setString(per.."%")
                self.fLoadbar:setPercent(per)
                -- print(per)
            end
        end , 0)
    end
end
function centerBuildingObj:ProduceFarmerComplete()
    if user.produceframerdata.num <= 0 then       
        mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_CITY_WORKER,false)
        user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
        me.clearTimer(self.produce_timer)
        self.produce_timer = nil
        self.produceLayer:setVisible(false)
    end
end


