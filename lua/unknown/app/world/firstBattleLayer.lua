-- [Comment]
-- jnmo
firstBattleLayer = class("firstBattleLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
firstBattleLayer.__index = firstBattleLayer
function firstBattleLayer:create(...)
    local layer = firstBattleLayer.new(...)
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
function firstBattleLayer:ctor()
    print("firstBattleLayer ctor")
end
function firstBattleLayer:init()
    print("firstBattleLayer init")
    self.mineMoudles = { }
    self.otherMoudles = { }
    self.Image_bg = me.assignWidget(self, "Image_bg")
    self.Button_Ok = me.registGuiClickEventByName(self, "Button_Ok", function(node)
        self:close()
    end )
    guideHelper.saveGuideIndex(guideHelper.guideIndex + 1)
    return true
end
function firstBattleLayer:initBattle()
    local nums = 5
    for var = 0, 29 do
        self.mineMoudles[var] = soldierBattleMoudle:createAni("soldier_mine")
        self.Image_bg:addChild(self.mineMoudles[var])
        self.mineMoudles[var]:setPosition(150 + 30 * math.floor(var / nums), 500 - 50 *(var % nums))
        self.mineMoudles[var]:doAction("idle", DIR_RIGHT)
        self.otherMoudles[var] = soldierBattleMoudle:createAni("soldier_other")
        self.Image_bg:addChild(self.otherMoudles[var])
        self.otherMoudles[var]:setPosition(900 - 30 * math.floor(var / nums), 500 - 50 *(var % nums))
        self.otherMoudles[var]:doAction("idle", DIR_LEFT)
        self.mineMoudles[var].target = self.otherMoudles[var]
        self.otherMoudles[var].target = self.mineMoudles[var]
        self.mineMoudles[var]:setLocalZOrder(var)
        self.mineMoudles[var].camp = 0
        self.otherMoudles[var]:setLocalZOrder(var)
        self.otherMoudles[var].camp = 1
    end
end
function firstBattleLayer:updateLogic(dt)
    local num = 0
    for var = 0, 29 do
        self.mineMoudles[var]:updateLogic(dt)
        self.otherMoudles[var]:updateLogic(dt)
        if self.otherMoudles[var].battlestate == SOLDIER_STATE_DEATH then
            num = num + 1
        end
    end
    if num > 25 then
        local ani = createArmature("battle_win")
        ani:setPosition(me.winSize.width / 2, me.winSize.height / 2 + 50)
        ani:getAnimation():playWithIndex(0)
        self:addChild(ani, me.MAXZORDER)
        me.clearTimer(self.timer)
        self.Button_Ok:setVisible(true)
        for var = 0, 29 do
            if self.mineMoudles[var].battlestate ~= SOLDIER_STATE_DEATH then
                self.mineMoudles[var]:stopAllActions()
                self.mineMoudles[var]:doAction("idle")
            end
            if self.otherMoudles[var].battlestate ~= SOLDIER_STATE_DEATH then
                self.otherMoudles[var]:setVisible(false)
            end
        end
    end
end 
function firstBattleLayer:onEnter()
    print("firstBattleLayer onEnter")
    me.doLayout(self, me.winSize)
    self:initBattle()
    self.timer = me.registTimer(-1, function(dt)
        self:updateLogic(dt)
    end , 0.2)
end
function firstBattleLayer:onEnterTransitionDidFinish()
    print("firstBattleLayer onEnterTransitionDidFinish")
end
function firstBattleLayer:onExit()
    print("firstBattleLayer onExit")
    pWorldMap:cloudOpen( function(args)
        local guide = guideView:getInstance()
        guide:showDialog(10, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        pWorldMap:addChild(guide, me.GUIDEZODER)        
        guideHelper.removeWaitLayer()        
    end )
    me.clearTimer(self.timer)
end
function firstBattleLayer:close()
    self:removeFromParent()
end
