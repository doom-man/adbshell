battleAni = class("battleAni", function(aname)
    return createArmature(aname)
end )
battleAni.__index = battleAni
function battleAni:ctor()
    print("battleAni:ctor()")
    self.loopnum = 0
    self.lisenter = nil
end
function battleAni:init()
    print("----------------")
    -- self:getAnimation():play("battle")
    
    
    return true
end
function battleAni:registLisenter(r)
    self.lisenter = r
    local function animationEvent(armatureBack, movementType, movementID)
        local id = movementID
        if movementType == ccs.MovementEventType.loopComplete then
            if id == "idle" then
                if self.loopnum >= 1 then
                    self:stopAllActions()
                    --self:removeFromParentAndCleanup(true)
                    self.lisenter(self)
                else
                    self.loopnum = self.loopnum + 1
                end
            end
        end
    end
    self:getAnimation():setMovementEventCallFunc(animationEvent)
end
function battleAni:playAni()
   self:getAnimation():playWithIndex(0)
end
function battleAni:create(ani)
    local m = battleAni.new(ani)
    if m and m:init() then
        return m
    end
    return nil
end
