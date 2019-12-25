--jnmo
foodBuildingObj = class("foodBuildingObj",buildingObj)
foodBuildingObj.__index = foodBuildingObj
function foodBuildingObj:ctor()
    super(self)  
    self.food_time = 0
    self.isResBuilding = true
end
function foodBuildingObj:init()
    superfunc(self,"init")
    self.gainBtn = me.assignWidget(self,"gainBtn")

    me.registGuiClickEvent(self.gainBtn,function (node)
       self.gainBtn:setVisible(false)
       self.resInfo = nil
       --self:foodParticl()
       mainCity:ResUIAction(1)
       --mainCity:setActionNum(1,self:getToftId())
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_FOOD_HARVEST,false)
       --todo gain msg
       NetMan:send(_MSG.getResource(self:getToftId()))
    end)
    return true
end
function foodBuildingObj:create()
    local layer = foodBuildingObj.new()
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
function foodBuildingObj:onEnter()
    print("foodBuildingObj onEnter")
    --todo  fix bug  ani state
    superfunc(self,"onEnter") 
    if self.state == BUILDINGSTATE_BUILD.key then
    --    self.ani:setVisible(false)
    elseif self.state ~= BUILDINGSTATE_LEVEUP.key and  self.gainBtn:isVisible() == false then   
        self:seeGain()
    end 
end
function foodBuildingObj:seeGain()
   local buildingLv = self:getDef().level
   if buildingLv == 1 or buildingLv == 2 then 
     self.food_time =60
   else
     self.food_time = 30
   end
   if self.m_resTimer then
       me.clearTimer(self.m_resTimer)
       self.m_resTimer=nil
   end
   self.m_resTimer = me.registTimer(self.food_time,function (dt,b)
                if b then
                    self.gainBtn:setVisible(true)                  
                    self.gainBtn:stopAllActions()
                    local pMoveBy1 = cc.MoveTo:create(1.5,cc.p(self.gainBtn:getPositionX(),self.gainBtn:getPositionY()+30))  
                    local pMoveBy2 = cc.MoveTo:create(1.5,cc.p(self.gainBtn:getPositionX(),self.gainBtn:getPositionY()-30))     
                    self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1,pMoveBy2)))                 
                end
   end,0)
end
function foodBuildingObj:buildComplete(args)
        superfunc(self,"buildComplete")
        mainCity:showPeasantPlant()
        self:seeGain()
end 
-- 收集粒子
function foodBuildingObj:foodParticl() 
    self.gainBtn:setVisible(false)
    local cItem = cc.ParticleSystemQuad:create("collection_food.plist")
    cItem:setPosition(cc.p(50*self.gainBtn:getScale(),200*self.gainBtn:getScale()))
    self:addChild(cItem, me.MAXZORDER)      
    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end
    local callback = cc.CallFunc:create(arrive)
    cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1),callback))
end
function foodBuildingObj:gainParticl()
    if self.state ~= BUILDINGSTATE_LEVEUP.key then 
          self:seeGain()
    end
    self:foodParticl()
end

-- 收集动画
function foodBuildingObj:gainAction(callback)
    if self.state ~= BUILDINGSTATE_LEVEUP.key then 
          self:seeGain()
    end
    self.gainBtn:setVisible(false)
    local _ = callback and callback()
end

function foodBuildingObj:onExit()
    print("foodBuildingObj onExit") 
    superfunc(self,"onExit")
    me.clearTimer(self.m_resTimer)
end

function  foodBuildingObj:initBuildForData(data_)
     superfunc(self,"initBuildForData",data_)
     table.insert(mainCity.foodBuildingToftId,self:getToftId())
end

function foodBuildingObj:closeGain()
  me.clearTimer(self.m_resTimer)
end


