--僧侣
monkBuildingObj = class("monkBuildingObj",buildingObj)
monkBuildingObj.__index = monkBuildingObj
function monkBuildingObj:ctor()
    super(self)  
    self.awardsData = {}
    self.packageId = 0
end
function monkBuildingObj:init()
    superfunc(self,"init")
    self.gainBtn = me.assignWidget(self,"gainBtn")
    self.gainBtn:setPosition(180,210) 
    self.originX = self.gainBtn:getPositionX()
    self.originY = self.gainBtn:getPositionY()
    self.gainImg = me.assignWidget(self.gainBtn,"gain_img"):loadTexture("zhucheng_caijie_shichang.png", me.localType)
    me.registGuiClickEvent(self.gainBtn,function (node)
        if user.guard_patrol_status==2 then
            local patrol = defSoldierPatrol:create("defSoldierPatrol.csb")
            me.popLayer(patrol)
            NetMan:send(_MSG.guard_patrol_init())
        elseif user.guard_resist_status==1 then
            local promotionView = promotionView:create("promotionView.csb")
            promotionView:setViewTypeID(1)
            promotionView:setTaskGuideIndex(ACTIVITY_ID_RESIST_INVASION_NEW)
            me.runningScene():addChild(promotionView, me.MAXZORDER)
            me.showLayer(promotionView, "bg_frame")
        end
    end)

    return true
end
function monkBuildingObj:create()
    local layer = monkBuildingObj.new()
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

function monkBuildingObj:onEnter()
    print("monkBuildingObj onEnter")
    --todo  fix bug  ani state
    superfunc(self,"onEnter") 
    
end

function monkBuildingObj:seeGain()
    if user.guard_patrol_status==2 then  --优先禁卫军巡逻领奖状态
        self.gainImg = me.assignWidget(self.gainBtn,"gain_img"):loadTexture("zhucheng_caijie_shichang.png", me.localType)
    elseif user.guard_resist_status==1 then  --抵御蛮族攻城状态
        self.gainImg = me.assignWidget(self.gainBtn,"gain_img"):loadTexture("boss_82.png", me.localType)
    else
        self.gainBtn:setVisible(false)
        self.gainBtn:stopAllActions()
        return
    end

    self.gainBtn:setPosition(cc.p(self.originX - 40, self.originY))
    self.gainBtn:setVisible(true)
    self.gainBtn:stopAllActions()
    local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() + 30))
    local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(self.gainBtn:getPositionX(), self.gainBtn:getPositionY() -30))
    self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
end


function monkBuildingObj:onExit()
    print("woodBuildingObj onExit") 
    superfunc(self,"onExit")
end

 
