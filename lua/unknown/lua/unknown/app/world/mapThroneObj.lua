-- jnmo
mapThroneObj = class("mapThroneObj", mapObj)
mapThroneObj.__index = mapThroneObj
function mapThroneObj:ctor()
    super(self)
    self.mTime = nil
end
-- mapCellData.id
function mapThroneObj:create(id)
    local layer = mapThroneObj.new()
    layer.m_id = id
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
THRONE_ANI = { { "lapidation", cc.p(-230, - 100) }, { "BowShoot", cc.p(-100, - 70) }, { "FuleBom", cc.p(-70, 0) }, { "Destruction", cc.p(-70, 0) } }
function mapThroneObj:init()
    superfunc(self, "init")
    -- self:setContentSize(cc.size(494,248))
    return true
end
function mapThroneObj:initObj()
    superfunc(self, "initObj")
    local data = self:getCellData()
    if data then
        self.icon:setVisible(true)
        self.nameBg:setVisible(false)
        self.icon:loadTexture(self:getIcon(), me.localType)
        self.icon:ignoreContentAdaptWithSize(true)
        self.name:setVisible(false)
        local owner = data:getCrossThroneData()
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE and owner then
            self.nameBg:setVisible(true)
            self.name:setVisible(true)
            local ptype = owner:getProtectedType()
            self.captiveIcon:loadTexture(tabImageName["3"], me.localType)
            self.captiveIcon:setVisible(owner:isCaptived())
            self.protectIcon:setVisible(false)
            --  self.protectIcon:loadTexture(tabImageName[me.toStr(ptype)], me.localType)
            local name = ""
            if owner.shorName then
                name = "[" .. owner.shorName .. "]" .. owner.name
            else
                name = owner.name
            end
            self.name:setString(name)
        end

        -- 普通、已占领状态 添加 保护罩
        if data.throneStatus and (data.throneStatus == 0 or data.throneStatus == 3) then
            self.isInCross:setVisible(true)
            self.isInCross:setScale(4.0, 3.5)
            self.isInCross:setPosition(cc.p(115, -200))
        else
            self.isInCross:setVisible(false)
        end
    end
    --    if self.mTime then
    --       me.clearTimer(self.mTime)
    --       self.mTime = 0
    --    end
    --    self.mNum = 1
    --    self.mTime =  me.registTimer(4,function (args)
    --        dump(self.mNum)
    --        local pStratAni = Throne_StrategyAni.new(1,self.mNum)
    --       -- user.ThroneStrAnimation[self.mNum] = pStratAni
    --        ThroneAnim(pStratAni)

    --       self:setAnim()
    --       self.mNum = self.mNum+1
    --   end,1)
    if (not Queue.isEmpty(ThroneAnim_itemQueue)) then
        self:setStarFire()
    end
end

function mapThroneObj:setStarFire()
    -- 策略特效
    local function playThroneAnim(itemdata_)
        local pStr = THRONE_ANI[itemdata_.id][1]
        local pPoint = THRONE_ANI[itemdata_.id][2]
        local ThroneAttack = allAnimation:createAnimation(pStr)
        ThroneAttack:Throne()
        ThroneAttack:setPosition(pPoint)
        self:addChild(ThroneAttack, me.MAXZORDER)
        local loop = 1
        local function animationEvent(armatureBack, movementType, movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                if loop > 4 then                   
                    armatureBack:removeFromParentAndCleanup(true)             
                    self:setStarFire()
                else
                    loop = loop + 1
                end
            end
        end
        ThroneAttack:getAnimation():setMovementEventCallFunc(animationEvent)
    end
    if (not Queue.isEmpty(ThroneAnim_itemQueue)) then
        local itemData = Queue.pop(ThroneAnim_itemQueue)
        playThroneAnim(itemData)
    else
        ThroneAnim_itemQueue = nil    
    end
end

function mapThroneObj:getIcon()
    return "wz.png"
end
function mapThroneObj:onEnter()
    superfunc(self, "onEnter")
    me.doLayout(self, self:getContentSize())
end
function mapThroneObj:onExit()
    if self.mTime then
        me.clearTimer(self.mTime)
        self.mTime = 0
    end
    superfunc(self, "onExit")
end
function mapThroneObj:setPos(sp)
    superfunc(self, "setPos", sp)
    local y = self:getPositionY()
    --  self.Image_Occupy:setPositionY( self.Image_Occupy:getPositionY() - cellSize.height/2)
    self:setPositionY(y + cellSize.height / 2)
end


