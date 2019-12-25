eagleModel = class("eagleModel",mAnimation)
eagleModel.__index = eagleModel

function eagleModel:ctor(name_,shadowName_)
    super(self)   
    self.shadowName = shadowName_
    self.speed = 88 --老鹰速度
    self.posp = 100 --阴影的偏移坐标
end

function eagleModel:createAniWithShadow(name,swName)
    local layer = eagleModel.new(name,swName)
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

function eagleModel:init()
    return true
end

function eagleModel:initShadow()
    if self.shadowName then
        self.shadow = eagleModel:createAniWithShadow(self.shadowName)    
        self:addChild(self.shadow)
        self.shadow:setPosition(cc.p(self.posp,-self.posp))
    end
end

function eagleModel:moveToPoint(p_, callfunc, animName_)    
    superfunc(self,"moveToPoint", p_,callfunc, animName_)
    if self.shadowName then
        local pDirection = self:getdirection()
        self.shadow:playToBeShadow(p_, animName_,pDirection)
       
    end
end

function eagleModel:onEnter()    
    self:initShadow()
end

function eagleModel:onExit()
end
