shipSkillView = class("shipSkillView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)

function shipSkillView:create(...)
    local layer = shipSkillView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function shipSkillView:ctor()
end

function shipSkillView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function shipSkillView:onExit()
    UserModel:removeLisener(self.netListener)
end

function shipSkillView:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.MSG_SHIP_SKILL_UPGRADE) then
        self:showEffectUpdateSuccess ()
        self:updateSkillScrollView ()
    elseif checkMsg(msg.t, MsgCode.NSG_SHIP_EXPEDITION_REWARD) then
        self:updateSkillScrollView ()
    end
    disWaitLayer ()
end

function shipSkillView:init()
    print("shipSkillView init")

    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    self.scrollSkill = me.assignWidget (self, "scroll_skill")
    self.scrollSkill:setScrollBarEnabled (false)

    return true
end

function shipSkillView:setSkillListData (shipType, arrayShipSkill, order)
    self.curSelectOrder = order
    self.curShipType = shipType
    self.arrayShipSkill = arrayShipSkill
    self:updateSkillScrollView ()
end

function shipSkillView:showEffectUpdateSuccess()
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    pCityCommon:CommonSpecific("texiao_zhi_jinjie.png")
    pCityCommon:getAnimation():setSpeedScale(0.6)
    pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    me.runningScene():addChild(pCityCommon, me.ANIMATION)
end

function shipSkillView:updateSkillScrollView()
    self.shipData = user.warshipData [self.curShipType]

    self.scrollSkill:removeAllChildren ()

    local skillCellRoot = cc.CSLoader:createNode ("shipSkillCell.csb")
    local skillCell = me.assignWidget (skillCellRoot, "panel_bg")

    local itemSize = skillCell:getContentSize ()

    local offsetX = 10
    local offsetY = 10

    local containerHeight =   (itemSize.height + offsetY) * math.ceil(#self.arrayShipSkill/2)  
    self.scrollSkill:setInnerContainerSize(cc.size (itemSize.width, containerHeight))

    local function skillUpgradeCallback (sender)
        local allChild = self.scrollSkill:getChildren ()
        for k, v in pairs (allChild) do
            v.imageSelect:setVisible (false)
        end
        sender.imageSelect:setVisible (true)

        if sender.getWayData then
            local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
            mainCity:addChild(getWayView, me.MAXZORDER)
            me.showLayer(getWayView,"bg")
            getWayView:setData(sender.getWayData.itemIcon)
            return
        end
        if sender.tipStr then
            showTips (sender.tipStr)
            return
        end
        local skillCfg = sender.skillCfg
        NetMan:send(_MSG.Ship_skill_update(skillCfg.type, skillCfg.id))
        showWaitLayer ()
    end

    local function describeShipSkillCallback(sender)
        local allChild = self.scrollSkill:getChildren ()
        for k, v in pairs (allChild) do
            v.imageSelect:setVisible (false)
        end
        sender.imageSelect:setVisible (true)

        local strItemDescribe = cfg[CfgType.SHIP_SKILL] [sender.itemId].desc
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>"..strItemDescribe.."&", wd, 320, 40)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end

    local function selectImageItemCallback(sender)
        print ("selectImageItemCallback")
        local allChild = self.scrollSkill:getChildren ()
        for k, v in pairs (allChild) do
            v.imageSelect:setVisible (false)
        end
        sender.imageSelect:setVisible (true)
    end

    local index = 0
    for k, v in pairs (self.arrayShipSkill) do
        -- TODO:clone的cell添加到scrollView上，在区域检测时存在bug（3.8版本）
        -- local skillItem = skillCell:clone ()
        local skillItem = cc.CSLoader:createNode ("shipSkillCell.csb")
        self.scrollSkill:addChild (skillItem)

        local posX = (2 * (index%2) + 1) * (offsetX/2 + itemSize.width/2) 
        local posY = containerHeight - (2 * math.floor(index/2) + 1)  * (offsetY/2 + itemSize.height/2)  +85
        skillItem:setPosition (cc.p (posX, posY))
        index = index + 1

        local imageIcon       = me.assignWidget (skillItem, "im_ship_icon")
        local textShipName    = me.assignWidget (skillItem, "text_ship_lv")
        local textDesc        = me.assignWidget (skillItem, "text_ship_disc")
        local btnUpgrade      = me.assignWidget (skillItem, "btn_upgrade")
        local loadbarBg       = me.assignWidget (skillItem, "im_loadbar_bg")
        local loadbarProgress = me.assignWidget (skillItem, "loadbar_progress")
        local textProgress    = me.assignWidget (skillItem, "text_progress")
        local textConditionbg = me.assignWidget (skillItem, "lock_bg")
        local textCondition   = me.assignWidget (skillItem, "text_open_condition")
        local imageFrame      = me.assignWidget (skillItem, "image_frame")
        local imageNumBg      = me.assignWidget (skillItem, "image_num_bg")
        local textItemNum     = me.assignWidget (skillItem, "text_item_num")
        local imageSelect = me.assignWidget (skillItem, "image_select")
        -- TODO:战舰技能表中的icon字段作道具表中道具id（老戴）
        local itemCount_ = 0
        for _k, _v in pairs (user.pkg) do
            if _v.defid == tonumber (v.icon) then
                itemCount_ = itemCount_ + _v.count
            end
        end
        if itemCount_ <= 0 then
            imageNumBg:setVisible (false)
        else
            imageNumBg:setVisible (true)
            textItemNum:setString (tostring (itemCount_))
        end
        local skillCfg = v
        if self.shipData.skills [v.order] then
            skillCfg = self.shipData.skills [v.order]
            -- 技能等级不能超过战舰等级
            if skillCfg.lv >= self.shipData.baseShipCfg.lv then
                btnUpgrade.tipStr = skillCfg.name .. "等级不能超过战舰等级"
            end
            if skillCfg.nextlvid and skillCfg.nextlvid ~= 0 then
                local strNeed = cfg[CfgType.SHIP_SKILL][skillCfg.nextlvid].needItem
                local strItem = string.split (strNeed, ":")
                local itemCount = 0
                for _k, _v in pairs (user.pkg) do
                    if _v.defid == tonumber (strItem[1]) then
                        itemCount = itemCount + _v.count
                    end
                end
                local percent = itemCount / tonumber (strItem [2]) * 100
                loadbarProgress:setPercent (percent)
                textProgress:setString (itemCount .. "/" .. strItem [2])
                -- 道具不足
                if itemCount < tonumber (strItem [2]) then                   
                    btnUpgrade:loadTextureNormal ("ui_ty_button_hong_154x56.png",me.localType)
                    me.assignWidget(btnUpgrade,"title"):setString("获取")
                    local function gotoGetWayCallback(getWayType)
                        if getWayType == 1 then
                            local shipSail = shipSailView:create("warning/shipSailView.csb")
                            mainCity:addChild(shipSail, me.MAXZORDER)
                            me.showLayer(shipSail,"bg")
                        elseif getWayType == 2 then
                            -- TODO:cityView 1224行有cityView.promotionView == nil的判断！！
                            -- mainCity.promotionView = promotionView:create("paymentView.csb")
                            -- mainCity.promotionView:setViewTypeID(2)
                            -- mainCity.promotionView:setTaskGuideIndex(ACTIVITY_SHIP_PACKAGE)
                            -- mainCity:addChild(mainCity.promotionView, me.MAXZORDER);
                            -- me.showLayer(mainCity.promotionView, "bg_frame")
                        end
                    end
                    local getWayData = {}
                    local getWayData = {}
                    getWayData.itemIcon = skillCfg.icon
                    getWayData.itemName = skillCfg.name
                    getWayData.itemNum = itemCount_
                    getWayData.showTextGetWay = true
                    getWayData.selectGetWayCallback = gotoGetWayCallback
                    getWayData.arrGetWay = {
                      {textDesc = "战舰航海"},
                      -- {textDesc = "商城购买"},
                    }
                    btnUpgrade.getWayData = getWayData
                end
            else
                -- 升到最高等级
                loadbarProgress:setPercent (100)
                textProgress:setVisible (false)
                btnUpgrade.tipStr = "达到最大等级，无法升级"
            end
            textConditionbg:setVisible(false)
            textCondition:setVisible (false)
        else
            imageFrame:getVirtualRenderer():setState (1)
            imageIcon:getVirtualRenderer():setState (1)
            textConditionbg:setVisible(true)
            textCondition:setString ("战舰" .. v.needLv .. "级开启")

            btnUpgrade:setVisible (false)
            loadbarBg:setVisible (false)
            loadbarProgress:setVisible (false)
            textProgress:setVisible (false)
        end
        btnUpgrade.skillCfg = skillCfg
        btnUpgrade:addClickEventListener (skillUpgradeCallback)

        local textrueIcon = getItemIcon (skillCfg.icon)
        imageIcon:loadTexture (textrueIcon)
        imageIcon.itemId = skillCfg.id
        imageIcon:addClickEventListener (describeShipSkillCallback)

        textShipName:setString (skillCfg.name .. " " .. skillCfg.lv .. "阶")
        textDesc:setString (skillCfg.desc)

        imageFrame:addClickEventListener (selectImageItemCallback)

        imageFrame.imageSelect = imageSelect
        skillItem.imageSelect = imageSelect
        imageIcon.imageSelect = imageSelect
        btnUpgrade.imageSelect = imageSelect
        if v.order == self.curSelectOrder then
            imageSelect:setVisible (true)
        else
            imageSelect:setVisible (false)
        end
    end
    self.scrollSkill:jumpToTop()
   
end