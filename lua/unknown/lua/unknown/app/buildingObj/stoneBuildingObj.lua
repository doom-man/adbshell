--jnmo
stoneBuildingObj = class("stoneBuildingObj",buildingObj)
stoneBuildingObj.__index = stoneBuildingObj
function stoneBuildingObj:ctor()
    super(self)  
    self.stone_time = 0
    self.isResBuilding = true
end
function stoneBuildingObj:init()
    superfunc(self,"init")
    self.gainBtn = me.assignWidget(self,"gainBtn")
    me.assignWidget(self.gainBtn,"gain_img"):loadTexture("gongyong_tubiao_shitou.png", me.localType)
    me.registGuiClickEvent(self.gainBtn,function (node)
       self.gainBtn:setVisible(false)
       self.resInfo = nil       
       --self:stoneParticl()
       mainCity:ResUIAction(3)
       --mainCity:setActionNum(1,self:getToftId())
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_STONE_HAVREST,false)
       --todo gain msg
       NetMan:send(_MSG.getResource(self:getToftId()))
    end)
    return true
end
function stoneBuildingObj:create()
    local layer = stoneBuildingObj.new()
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
function stoneBuildingObj:onEnter()
    print("stoneBuildingObj onEnter")
    --todo  fix bug  ani state
    superfunc(self,"onEnter") 
        self.icon:removeAllChildren()
    --    self.ani = buildingAni:createById(1121)
     --   self.ani:getAnimation():play("idle")
     --   self.icon:addChild(self.ani)   
    if self.state == BUILDINGSTATE_BUILD.key then
      --  self.ani:setVisible(false)
    elseif self.state ~= BUILDINGSTATE_LEVEUP.key and  self.gainBtn:isVisible() == false then       
        self:seeGain()
    end 
end
function stoneBuildingObj:seeGain()
    local buildingLv = self:getDef().level
    if buildingLv == 1 or buildingLv == 2 then
        self.stone_time = 60
    else
        self.stone_time = 30
    end
    self.m_resTimer = me.registTimer(self.stone_time, function(dt, b)
        if b and not tolua.isnull(self) then
            self.gainBtn:setVisible(true)
            self.gainBtn:stopAllActions()
            local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() + 30))
            local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() -30))
            self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
            me.clearTimer(self.m_resTimer)
        end
    end , 0)
end
-- 收集粒子
function stoneBuildingObj:stoneParticl() 
    self.gainBtn:setVisible(false)
    local cItem = cc.ParticleSystemQuad:create("collection_stone.plist")
    cItem:setPosition(cc.p(50*self.gainBtn:getScale(),200*self.gainBtn:getScale()))
    self:addChild(cItem, me.MAXZORDER)
      
    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    local callback = cc.CallFunc:create(arrive)
    cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1),callback))
end
function stoneBuildingObj:gainParticl()
    if self.state ~= BUILDINGSTATE_LEVEUP.key then 
          self:seeGain()
    end
    self:stoneParticl()
end

-- 收集动画
function stoneBuildingObj:gainAction(callback)
    if self.state ~= BUILDINGSTATE_LEVEUP.key then 
          self:seeGain()
    end
    self.gainBtn:setVisible(false)
    local _ = callback and callback()
end

function stoneBuildingObj:buildComplete(args)
        superfunc(self,"buildComplete")
        mainCity:showMinerWork()
        self:seeGain()
end
function stoneBuildingObj:onExit()
    print("stoneBuildingObj onExit") 
    superfunc(self,"onExit")
    me.clearTimer(self.m_resTimer)
end
function  stoneBuildingObj:initBuildForData(data_)
     superfunc(self,"initBuildForData",data_)
     table.insert(mainCity.stoneBuildingToftId,self:getToftId())
end
function stoneBuildingObj:closeGain()
  me.clearTimer(self.m_resTimer)
end