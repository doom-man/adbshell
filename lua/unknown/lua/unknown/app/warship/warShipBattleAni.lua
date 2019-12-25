-- [Comment]
-- jnmo
warShipBattleAni = class("warShipBattleAni", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warShipBattleAni.__index = warShipBattleAni
function warShipBattleAni:create(...)
    local layer = warShipBattleAni.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function warShipBattleAni:ctor()
    print("warShipBattleAni ctor")
end
local aninames = {
    [1] = "fly",
    [2] = "fly_small",
}
function warShipBattleAni:init()
    print("warShipBattleAni init")
    self.anis = { }
--    me.registGuiClickEventByName(self, "fixLayout", function(node)
--        self:close()
--    end )
    self.Image_myship = me.assignWidget(self, "Image_myship")
    self.Image_enemy = me.assignWidget(self, "Image_enemy")
    return true
end
function warShipBattleAni:setResult(r)
    
    self.battleResult = r
     local myshipDef = cfg[CfgType.SHIP_DATA][self.battleResult.atkShipId]
    local othershipDef = cfg[CfgType.SHIP_DATA][self.battleResult.defShipId]
    self.Image_myship:loadTexture(getWarshipImageTexture(myshipDef.type), me.localType) 
    self.Image_enemy:loadTexture(getWarshipImageTexture(othershipDef.type), me.localType)  
    self.Image_enemy:setScaleX(-1)
    self.Image_myship:ignoreContentAdaptWithSize(true)
    self.Image_enemy:ignoreContentAdaptWithSize(true)
    local function bmobcall(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then
            armatureBack:removeFromParentAndCleanup()
        end
    end
    local function animationEvent(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then
            me.assignWidget(self, "bmob" .. armatureBack.id):getAnimation():play("bmob")
            me.assignWidget(self, "bmob" .. armatureBack.id):setVisible(true)
            me.assignWidget(self, "bmob" .. armatureBack.id):getAnimation():setMovementEventCallFunc(bmobcall)
            armatureBack:removeFromParentAndCleanup()
        end
    end
    for var = 1, 11 do
        self.anis[var] = me.assignWidget(self, "ani" .. var)
        me.DelayRun( function(args)
            self.anis[var]:setVisible(true)
            self.anis[var]:getAnimation():play(aninames[me.getRandom(2)])
            self.anis[var]:getAnimation():setMovementEventCallFunc(animationEvent)
            self.anis[var].id = var
        end , me.getRandom(2000) / 1000)
    end
    me.DelayRun(function (node)
         local res = warshipPVPReslutView:create("warshipPVPResult.csb")
         res:initWithData(self.battleResult)
         me.popLayer(res)
         self:close()
    end,4)
end
function warShipBattleAni:onEnter()
    print("warShipBattleAni onEnter")
    me.doLayout(self, me.winSize)
end
function warShipBattleAni:onEnterTransitionDidFinish()
    print("warShipBattleAni onEnterTransitionDidFinish")
end
function warShipBattleAni:onExit()
    print("warShipBattleAni onExit")
end
function warShipBattleAni:close()
    self:removeFromParent()
end
