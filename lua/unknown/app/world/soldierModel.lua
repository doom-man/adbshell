soldierBattleMoudle = class("soldierBattleMoudle", mAnimation)
soldierBattleMoudle.__index = soldierBattleMoudle
SOLDIER_STATE_IDLE = 1
SOLDIER_STATE_SEARCH = 2
SOLDIER_STATE_ATTACK = 3
SOLDIER_STATE_DEATH = 4
SOLDIER_STATE_GETTARGET= 5
function soldierBattleMoudle:ctor()
    super(self)
    self.battlestate = SOLDIER_STATE_IDLE
    self.target = nil
    self.camp = 0
end
function soldierBattleMoudle:createAni(aname)
    local layer = soldierBattleMoudle.new(aname)
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
function soldierBattleMoudle:init()
    self.speed = me.getRandom(40) + 30
    return true
end
function soldierBattleMoudle:updateLogic(dt)
    if self.battlestate == SOLDIER_STATE_IDLE then
        self:stopAllActions()
        self.battlestate = SOLDIER_STATE_SEARCH
        self:moveToTarget( function()
            
        end )
    elseif self.battlestate == SOLDIER_STATE_SEARCH then   
        local p_ = cc.p(self.target:getPosition())
        local lp = cc.p(self:getPositionX(), self:getPositionY())
         local dis = cc.pGetDistance(lp, p_)
        if dis < 50 then
            self:stopAllActions()
            self.battlestate = SOLDIER_STATE_ATTACK
            local p_ = cc.p(self.target:getPosition())
            self:dirToPoint(p_)
            self:doAction("att")
        end  
        
    elseif self.battlestate == SOLDIER_STATE_ATTACK then
        if self.camp == 1 then
            if me.getRandom(100)<30 then            
                self.battlestate = SOLDIER_STATE_DEATH
                self:doAction("dead")
                self:setLocalZOrder(1)
            end
        elseif self.camp == 0 then
            if me.getRandom(100)<10 then            
                self.battlestate = SOLDIER_STATE_DEATH
                self:doAction("dead")
                self:setLocalZOrder(1)
            end
        end
    end
end
function soldierBattleMoudle:moveToTarget(callfunc, animName_)
    local p_ = cc.p(self.target:getPosition())
    self:dirToPoint(p_)
    local lp = cc.p(self:getPositionX(), self:getPositionY())
    local dis = cc.pGetDistance(lp, p_)
    if dis > 300 then
        p_.x = me.getRandom(10) - me.getRandom(20) + p_.x
        p_.y = me.getRandom(10) - me.getRandom(20) + p_.y
    elseif dis > 50 then
        self.speed = 70
        p_.x = me.getRandom(20) - me.getRandom(40) + p_.x
        p_.y = me.getRandom(20) - me.getRandom(40) + p_.y
    else    
        callfunc()
        return
    end
    local moveto = cc.MoveTo:create(dis / self.speed, p_)
    local call
    local function endmove(node)
        self:doAction(MANI_STATE_IDLE)
    end
    if callfunc == nil then
        call = cc.CallFunc:create(endmove)
    else
        call = cc.CallFunc:create(callfunc)
    end
    local seq = cc.Sequence:create(moveto, call)
    self:runAction(seq)
    --  self:getAnimation():setSpeedScale(1)
    self:doAction(animName_ or "move")    
end
function soldierBattleMoudle:getTarget(batte)

end
function soldierBattleMoudle:onEnter()
    print("soldierBattleMoudle:onEnter")
end
function soldierBattleMoudle:onExit()

end




