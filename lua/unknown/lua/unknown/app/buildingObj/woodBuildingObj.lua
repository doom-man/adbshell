-- jnmo  -- 伐木场的收获
woodBuildingObj = class("woodBuildingObj", buildingObj)
woodBuildingObj.__index = woodBuildingObj
function woodBuildingObj:ctor()
    super(self)
    self.wood_time = 0
    self.isResBuilding = true
end
function woodBuildingObj:init()
    superfunc(self, "init")
    self.gainBtn = me.assignWidget(self, "gainBtn")
    me.assignWidget(self.gainBtn, "gain_img"):loadTexture("gongyong_tubiao_mucai.png", me.localType)
    me.registGuiClickEvent(self.gainBtn, function(node)
        self.resInfo = nil
        -- self:woodParticl()
        mainCity:ResUIAction(2)
        -- mainCity:setActionNum(1,self:getToftId())
        mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_WOOD_HARVEST, false)
        -- todo gain msg
        NetMan:send(_MSG.getResource(self:getToftId()))
    end )
    return true
end
function woodBuildingObj:create()
    local layer = woodBuildingObj.new()
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

function woodBuildingObj:onEnter()
    print("woodBuildingObj onEnter")
    -- todo  fix bug  ani state
    superfunc(self, "onEnter")
    if self.state == BUILDINGSTATE_BUILD.key then
        --  self.ani:setVisible(false)
    elseif self.state ~= BUILDINGSTATE_LEVEUP.key and self.gainBtn:isVisible() == false then
        self:seeGain()
    end
end
function woodBuildingObj:seeGain()
    local buildingLv = self:getDef().level
    if buildingLv == 1 or buildingLv == 2 then
        self.wood_time = 60
    else
        self.wood_time = 30
    end
    self.m_resTimer = me.registTimer(self.wood_time, function(dt, b)
        if b and self.gainBtn  then
            self.gainBtn:setVisible(true)
            self.gainBtn:stopAllActions()
            local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() + 30))
            local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() -30))
            self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
        end
    end , 0)
end

-- 收集粒子
function woodBuildingObj:woodParticl()
    self.gainBtn:setVisible(false)
    local cItem = cc.ParticleSystemQuad:create("collection_wood.plist")
    cItem:setPosition(cc.p(50 * self.gainBtn:getScale(), 200 * self.gainBtn:getScale()))
    self:addChild(cItem, me.MAXZORDER)
    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end
    local callback = cc.CallFunc:create(arrive)
    cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1), callback))
end
function woodBuildingObj:gainParticl()
    if self.state ~= BUILDINGSTATE_LEVEUP.key then
        self:seeGain()
    end
    self:woodParticl()
end

-- 收集动画
function woodBuildingObj:gainAction(callback)
    if self.state ~= BUILDINGSTATE_LEVEUP.key then 
          self:seeGain()
    end
    self.gainBtn:setVisible(false)
    local _ = callback and callback()
end

function woodBuildingObj:buildComplete(args)
    superfunc(self, "buildComplete")
    mainCity:showWoodWork()
    self:seeGain()
end
function woodBuildingObj:onExit()
    print("woodBuildingObj onExit")
    superfunc(self, "onExit")
    me.clearTimer(self.m_resTimer)
end


function woodBuildingObj:initBuildForData(data_)
    superfunc(self, "initBuildForData", data_)
    table.insert(mainCity.woodBuildingToftId, self:getToftId())
end

function woodBuildingObj:closeGain()
    me.clearTimer(self.m_resTimer)
end

 
