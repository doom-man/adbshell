soldierMoudle = class("soldierMoudle",mAnimation)
soldierMoudle.__index = soldierMoudle
function soldierMoudle:ctor()
     super(self)
end
function soldierMoudle:createSoldierById(id)
    local sdata = user.soldierData[id]
    local layer
    if sdata then
     print("create ".."bing_"..id.."ani "..sdata:getDef().icon)
     layer = soldierMoudle.new("bing_"..sdata:getDef().icon)
     else
     layer = soldierMoudle.new("bing_"..cfg[CfgType.CFG_SOLDIER][id].icon)
    end
    if layer then
        layer.id = id
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
function soldierMoudle:init()
    return true
end
function soldierMoudle:getDef() 
    if self.def == nil  then
        self.def = cfg[CfgType.CFG_SOLDIER][self.id]
    end
    return self.def
end
function soldierMoudle:onEnter()    
    print("soldierMoudle:onEnter")
end
function soldierMoudle:standby()
     local function aniend(node)
        node:getAnimation():setSpeedScale(0.5)
        node:doAction(MANI_STATE_IDLE)        
    end
    self.m_timer = me.registTimer(-1,function (dt)
          if self.state == MANI_STATE_IDLE then
               if me.getRandom(2) == 1 then
                   local p = me.randInRect(mainCity["crowds_army"..self:getDef().bigType],100,100)
                   self:getAnimation():setSpeedScale(1)
                   self:moveToPoint(p,aniend)  
               end      
          end
    end,me.getRandom(15)+15)  
end
function soldierMoudle:onExit()
    me.clearTimer(self.m_timer) 
end