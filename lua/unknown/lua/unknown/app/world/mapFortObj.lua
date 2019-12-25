-- jnmo
mapFortObj = class("mapFortObj", mapObj)
mapFortObj.__index = mapFortObj
function mapFortObj:ctor()
    super(self)
    self.mAnimationNode = nil
end
-- mapCellData.id
function mapFortObj:create(id)
    local layer = mapFortObj.new()
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
function mapFortObj:init()
    superfunc(self, "init")
    self:setContentSize(cc.size(735, 372))
    return true
end
function mapFortObj:initObj()
    superfunc(self, "initObj")
    local data = self:getCellData()
    if data then
        self.icon:setVisible(true)
        self.icon:loadTexture(self:getIconById(data:getFortDefData()), me.plistType)
        self.icon:ignoreContentAdaptWithSize(true)
        if data.pointType == POINT_FORT then
            local fdata = data:getFortData()
            local function setState(fdata)
                self:clearGiveupTimeBar()
                if fdata.famdata and fdata.start == 1 then
                    self:setStarFire(fdata)
                else
                    self:endFire()
                end
            end
            if fdata.famdata and fdata.famdata.mine == 1 and data.giveup and data.giveup > 0 then
                -- ·ÅÆúÒªÈû
                if data:getFortId() == me.getFortIdByCoord(data.crood) then
                    self:initGiveupTimeBar()
                end
            else
                setState(fdata)
            end
        end
    end
    --self:setLocalZOrder(10)
    self.Image_Occupy:setVisible(false)
    if user.Cross_Sever_Status ~= mCross_Sever then        
        self:updateManor()
    end
end
function mapFortObj:initGiveupTimeBar()
    local data = self:getCellData()
    if self.giveupTimeBar == nil then
        local gtime = data.giveup
        self.giveupTimeBar = me.createNode("loadingBar.csb")
        local bg = me.assignWidget(self.giveupTimeBar, "bg")
        local Text_time = me.assignWidget(self.giveupTimeBar, "Text_time")
        local LoadingBar_time = me.assignWidget(self.giveupTimeBar, "LoadingBar_time")
        self.giveupTimeBar:setPosition(cc.p(self:getContentSize().width / 2 - self.giveupTimeBar:getContentSize().width / 2, self:getContentSize().height / 2))
        LoadingBar_time:setPercent(0)
        Text_time:setString(me.formartSecTime(gtime))
        self.giveupTimer = me.registTimer(gtime, function(dt)
            gtime = gtime - dt
            if gtime > 0 then
                Text_time:setString(me.formartSecTime(gtime))
                LoadingBar_time:setPercent((data.giveup - gtime) * 100 / data.giveup)
            end
        end , 1)
        self:addChild(self.giveupTimeBar, 10)
    end
end
function mapFortObj:clearGiveupTimeBar()
    if self.giveupTimeBar and self.giveupTimeBar.getPositionX then
        self.giveupTimeBar:removeFromParentAndCleanup(true)
        local chl = self.Node_MZ:getChildByTag(CELL_MIANZ_TAG)
        if chl and chl.getPositionX then
            chl:removeFromParentAndCleanup(true)
        end
        me.clearTimer(self.giveupTimer)
        self.giveupTimeBar = nil
    end
end
function mapFortObj:setStarFire(pData)
    if self.mAnimationNode == nil then
        self.mAnimationNode = cc.Node:create()
        local pConfig = pData:getDef()
        local pHeroConfig = "shenjiang_tu_texiao_" .. pConfig["herotype"] .. ".png"

        local FortHerpIcon = ccui.ImageView:create(pHeroConfig, me.plistType)
        self.mAnimationNode:addChild(FortHerpIcon)

        local pCityAttack = allAnimation:createAnimation("shenjiang_texiao_shilian")
        pCityAttack:FortExper()
        self.mAnimationNode:addChild(pCityAttack)
        self.mAnimationNode:setPosition(cc.p(392, 380))
        self:addChild(self.mAnimationNode)

        local pMoveByUp = cc.MoveBy:create(1.5, cc.p(0, 10))
        local pMoveByNext = cc.MoveBy:create(1.5, cc.p(0, -10))

        local pSequence = cc.Sequence:create(pMoveByUp, pMoveByNext)
        local rept = cc.RepeatForever:create(pSequence)
        self.mAnimationNode:runAction(rept)

    end
end
function mapFortObj:endFire()
    if self.mAnimationNode ~= nil then
        self.mAnimationNode:removeFromParentAndCleanup(true)
        self.mAnimationNode = nil
    end
end
function mapFortObj:showManor()
    print("------------------------------")
    self.Node_Manor:setVisible(true)
    self.Node_Manor:removeAllChildren()
    -- 6175 £¬3100
    self.manor_img = ccui.ImageView:create("manor1.png", me.localType)
    self.manor_img:setPositionX(244)
    self.manor_img:setPositionY(-62)
    self.Node_Manor:addChild(self.manor_img)
    local scale = cc.ScaleTo:create(20, 6100 / self.manor_img:getContentSize().width, 3025 / self.manor_img:getContentSize().height)
    local scale1 = cc.ScaleTo:create(0, 0, 0)
    local seq = cc.Sequence:create(scale, scale1)
    local rep = cc.RepeatForever:create(seq)
    self.manor_img:runAction(rep)

end
function mapFortObj:updateManor()
    local state = self:getCellData():getOccState()
    local mname = "manor1.png"
    if state == OCC_STATE_NONE then
        mname = "manor1.png"
    elseif state == OCC_STATE_HOSTILE then
        mname = "manor2.png"
    elseif state == OCC_STATE_ALLIED then
        mname = "manor3.png"
    end
    self.lastState = state
    self.Node_Manor:removeChildByTag(0xf2213)
    self.manor = ccui.ImageView:create(mname, me.localType)
    self.manor:setTag(0xf2213)
    self.Node_Manor:addChild(self.manor)
    self.manor:setScale(6150 / self.manor:getContentSize().width)
    self.manor:setPositionX(242)
    self.manor:setPositionY(-62)
end
function mapFortObj:getIconById(fdata)
    print("waicheng_yaosai_shijie_" .. fdata.icon .. ".png")
    return "waicheng_yaosai_shijie_" .. fdata.icon .. ".png"
end
function mapFortObj:onEnter()
    superfunc(self, "onEnter")
    me.doLayout(self, self:getContentSize())
    if user.Cross_Sever_Status ~= mCross_Sever then
        self:showManor()
    end
end
function mapFortObj:onExit()
    self:clearGiveupTimeBar()
    superfunc(self, "onExit")
end
function mapFortObj:setPos(sp)
    superfunc(self, "setPos", sp)
    local y = self:getPositionY()
    self:setPositionY(y+60)
end


