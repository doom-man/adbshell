--jnmo
houseBuildingObj = class("houseBuildingObj",buildingObj)
houseBuildingObj.__index = houseBuildingObj
function houseBuildingObj:ctor()
    super(self)  
    
end
function houseBuildingObj:init()
    superfunc(self,"init")
    return true
end
function houseBuildingObj:create()
    local layer = houseBuildingObj.new()
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
function houseBuildingObj:onEnter()
    print("houseBuildingObj onEnter")
    superfunc(self,"onEnter")    
end
function houseBuildingObj:onExit()
    print("houseBuildingObj onExit") 
    superfunc(self,"onExit")
end

function houseBuildingObj:ProduceFarmerComplete()
    mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_CITY_WORKER,false)
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
end


