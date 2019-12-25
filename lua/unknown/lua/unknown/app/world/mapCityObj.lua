-- jnmo
mapCityObj = class("mapCityObj", mapObj)
mapCityObj.__index = mapCityObj
function mapCityObj:ctor()
    super(self)
    self.pCityAttack = nil
    self.pOwner = nil
end
-- mapCellData.id
function mapCityObj:create(id)
    local layer = mapCityObj.new()
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
function mapCityObj:init()
    superfunc(self, "init")
    self:setContentSize(cc.size(494, 248))
    return true
end
function mapCityObj:setStarFire()
    if self.pCityAttack == nil then
        self.pCityAttack = { }
        for var = 1, 4 do
            self.pCityAttack[var] = allAnimation:createAnimation("fire")
            self.pCityAttack[var]:getAnimation():playWithIndex(0)            
            self:addChild(self.pCityAttack[var], me.MAXZORDER)

        end
        self.pCityAttack[1]:setPosition(cc.p(150, 115))
        self.pCityAttack[2]:setPosition(cc.p(232, 75))
        self.pCityAttack[3]:setPosition(cc.p(350, 115))
        self.pCityAttack[4]:setPosition(cc.p(202, 165))
        self.pCityAttack[4]:setLocalZOrder(-1)
    end
end
function mapCityObj:endFire()
    if self.pCityAttack ~= nil then
        for var = 1, 4 do
            self.pCityAttack[var]:removeFromParentAndCleanup(true)
        end
        self.pCityAttack = nil
    end
end

function mapCityObj:initObj()
    superfunc(self, "initObj")
    local data = self:getCellData()
    self.protectIcon:setVisible(false)
    self.captiveIcon:setVisible(false)
    if data then
        local owner = data:getOwnerData()
        self.pOwner = nil
        if owner then
            self.pOwner = owner
            local centerId = owner.centerId
            if owner.uid == user.uid then
                pWorldMap.myCityCellId = self.m_id
            end
            self.icon:setVisible(true)
            self.nameBg:setVisible(false)
            self.icon:loadTexture(self:getIconById(centerId), me.localType)
            self.icon:ignoreContentAdaptWithSize(true)
            if owner.origin == 1 then
                local name = "空城"
                self.captiveIcon:setVisible(false)
                self.protectIcon:setVisible(false)
                self.name:setString(name)
                local ptype = owner:getProtectedType()
                self.captiveIcon:loadTexture(tabImageName["3"], me.localType)
                self.captiveIcon:setVisible(owner:isCaptived())
                self.protectIcon:setVisible(owner:isProtected())
                self.protectIcon:loadTexture(tabImageName[me.toStr(ptype)], me.localType)                             
            else
                local ptype = owner:getProtectedType()
                self.captiveIcon:loadTexture(tabImageName["3"], me.localType)
                self.captiveIcon:setVisible(owner:isCaptived())
                self.protectIcon:setVisible(owner:isProtected())
                self.protectIcon:loadTexture(tabImageName[me.toStr(ptype)], me.localType)
                local name = ""
                if owner.shorName then
                    name = "[" .. owner.shorName .. "]" .. owner.name
                else
                    name = owner.name
                end
                self.name:setString(name)
                if owner.isInCross == 1 or owner:isProtected() then
                    -- 保护罩
                    self.isInCross:setVisible(true)
                    self.isInCross:setPositionX(240)
                end
            end
            if data.show and data.show == true then
                self:setStarFire()
            else
                self:endFire()
            end

            -- 调整保护图标的位置
            if self.protectIcon:isVisible() then
                self.protectIcon:setPositionX(self.name:getPositionX() - self.name:getContentSize().width/2 - self.protectIcon:getContentSize().width/2)
                self.captiveIcon:setPositionX(self.protectIcon:getPositionX() - self.protectIcon:getContentSize().width)
            else
                self.captiveIcon:setPositionX(self.name:getPositionX() - self.name:getContentSize().width/2 - self.captiveIcon:getContentSize().width/2)
            end


            self:updateSkin(centerId)
            self:updateTitle()
        end
    end
    --self:setLocalZOrder(10)
end
function mapCityObj:updateSkin(centerId)
    local data = self:getCellData()
    self.Node_MZ:removeAllChildren()
    if data.adornment then
        if data.adornment == 0 then
            self.icon:loadTexture(self:getIconById(centerId), me.localType)
        else
            local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(data.adornment)]
            self.icon:loadTexture("cityskin" .. skindata.icon .. ".png", me.localType)
            if skindata.lv > 1 then
                local ani = createArmature("flag1")
                ani:getAnimation():playWithIndex(0)
                ani:setPosition(-185, -10)
                self.Node_MZ:addChild(ani)
            end
        end
    end
    if data.totem and data.totem > 0 then
        local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(data.totem)]
        self.totem:setVisible(true)
        self.totem:loadTexture("skin" .. skindata.icon .. ".png", me.localType)
        self.totem:ignoreContentAdaptWithSize(true)
        -- 外城是否显示图腾
        if data.showTotem == 1 then
            self.totem:setVisible(true)
        else
            self.totem:setVisible(false)
        end
    else
        self.totem:setVisible(false)
    end
end
function mapCityObj:updateTitle()
    local data = self:getCellData()
    if data.title and data.title > 0 then
        local def = cfg[CfgType.ROLE_TITLE][tonumber(data.title)]
        if def.type == 2 then
            self.Image_role_title:loadTexture("role_title_" .. def.icon .. ".png", me.localType)
            self.Image_role_title:ignoreContentAdaptWithSize(true)
        end
        self.Image_role_title:setVisible(def.type == 2)
    end
end
function mapCityObj:getIconById(eid)
    local pIcon = "m1000.png"
    if self.pOwner then
        if self.pOwner.origin == 1 then
            pIcon = "wangzuo_diji_huangdi.png"
        else
            local id = math.abs(eid)
            local icon = cfg[CfgType.BUILDING][id].icon
            print("icon = " .. "m" .. icon .. ".png")
            pIcon = "m" .. icon .. ".png"
        end
    end
    return pIcon
end
function mapCityObj:onEnter()

    superfunc(self, "onEnter")
    me.doLayout(self, self:getContentSize())
end
function mapCityObj:onExit()

    superfunc(self, "onExit")
end
function mapCityObj:setPos(sp)
    superfunc(self, "setPos", sp)
    local y = self:getPositionY()
    --  self.Image_Occupy:setPositionY( self.Image_Occupy:getPositionY() - cellSize.height/2)
    self:setPositionY(y + cellSize.height / 2)
end


