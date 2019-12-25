-- [Comment]
-- jnmo
warshipPVPPlayerInfo = class("warshipPVPPlayerInfo", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipPVPPlayerInfo.__index = warshipPVPPlayerInfo
function warshipPVPPlayerInfo:create(...)
    local layer = warshipPVPPlayerInfo.new(...)
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
function warshipPVPPlayerInfo:ctor()
    print("warshipPVPPlayerInfo ctor")
end
function warshipPVPPlayerInfo:init()
    print("warshipPVPPlayerInfo init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Image_icon = me.assignWidget(self, "Image_icon")
    self.Text_Fight = me.assignWidget(self, "Text_Fight")
    self.Text_Rank = me.assignWidget(self, "Text_Rank")
    self.list_mid = me.assignWidget(self, "list_mid")
    self.list_bootom = me.assignWidget(self, "list_bootom")
    -- 所有类型战舰一级技能
    self.inactiveShipSkill = { }
    for k, v in pairs(cfg[CfgType.SHIP_SKILL]) do
        if v.lv == 1 then
            if self.inactiveShipSkill[v.type] == nil then self.inactiveShipSkill[v.type] = { } end
            table.insert(self.inactiveShipSkill[v.type], v)
        end
    end
    for k, v in pairs(self.inactiveShipSkill) do
        table.sort(v, function(a, b)
            return a.order < b.order
        end )
    end
    self.list_bootom = me.assignWidget(self, "list_bootom")
    self.list_mid = me.assignWidget(self, "list_mid")
    return true
end
function warshipPVPPlayerInfo:initWithData(data)
    dump(data)
    local myshipDef = cfg[CfgType.SHIP_DATA][data.defid]
    self.Text_Name:setString(myshipDef.name)
    self.Text_Rank:setString(data.rank)
    self.Text_Fight:setString(data.ftPower)
    self.Image_icon:loadTexture(getWarshipImageTexture(data.type), me.localType)
    me.resizeImage(self.Image_icon, 200, 120)
    local function enterShipSkillCallback(sender)
        local strItemDescribe = sender.data.desc
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>" .. strItemDescribe .. "&", wd)
        me.popLayer(stips)
    end
    for var = 1, 6 do
        local v = data.skills[var]
        if v then
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setTouchEnabled(true)
            imageSkillIcon:setEnabled(true)
            local skillCfg = cfg[CfgType.SHIP_SKILL][tonumber(v)]
            if skillCfg then
                local textrueIcon = getItemIcon(skillCfg.icon)
                imageSkillIcon:loadTexture(textrueIcon)
                local skillIconSize = imageSkillIcon:getContentSize()
                me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.lv .. "阶")
            end
            imageSkillIcon.data = skillCfg
            imageSkillIcon:addClickEventListener(enterShipSkillCallback)
            self.list_bootom:pushBackCustomItem(shipSkillCell)
        else
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            self.list_bootom:pushBackCustomItem(shipSkillCell)

            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setVisible(false)
            me.assignWidget(shipSkillCell, "Image_49"):setVisible(false)
            me.assignWidget(shipSkillCell, "skillLvTxt"):setVisible(false)
        end

    end
    local function enterShipRefitSkillCallback(sender)
        local strItemDescribe = sender.data.desc
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>" .. strItemDescribe .. "&", wd)
        me.popLayer(stips)
    end
    for var = 1, 6 do
        local v = data.comboSkills[var]
        if v then
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setTouchEnabled(true)
            imageSkillIcon:setEnabled(true)
            imageSkillIcon:setVisible(true)
            local skillCfg = cfg[CfgType.SHIP_REFIX_SKILL][tonumber(v)]
            if skillCfg then
                imageSkillIcon:loadTexture(getRefitIcon(tonumber(v)), me.localType)
                me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.name)
            end
            imageSkillIcon.data = skillCfg
            imageSkillIcon:addClickEventListener(enterShipRefitSkillCallback)
            self.list_mid:pushBackCustomItem(shipSkillCell)
        else
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            self.list_mid:pushBackCustomItem(shipSkillCell)
            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setVisible(false)
            me.assignWidget(shipSkillCell, "Image_49"):setVisible(false)
            me.assignWidget(shipSkillCell, "skillLvTxt"):setVisible(false)
        end
    end
end
function warshipPVPPlayerInfo:onEnter()
    print("warshipPVPPlayerInfo onEnter")
    me.doLayout(self, me.winSize)
end
function warshipPVPPlayerInfo:onEnterTransitionDidFinish()
    print("warshipPVPPlayerInfo onEnterTransitionDidFinish")
end
function warshipPVPPlayerInfo:onExit()
    print("warshipPVPPlayerInfo onExit")
end
function warshipPVPPlayerInfo:close()
    self:removeFromParent()
end
