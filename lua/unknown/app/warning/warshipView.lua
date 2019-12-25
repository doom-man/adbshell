warshipView = class("warshipView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end )

function warshipView:create(...)
    local layer = warshipView.new(...)
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

function warshipView:ctor()
    -- 所有类型一级战舰
    self.inactivatedShip = { }
    for k, v in pairs(cfg[CfgType.SHIP_DATA]) do
        if v.lv == 1 then
            self.inactivatedShip[v.type] = v
        end
    end
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
    -- 默认弹药恢复是使用碎片
    self.shipRestoreRes = false
end

function warshipView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function warshipView:onExit()
    UserModel:removeLisener(self.netListener)
end

function warshipView:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.MSG_WARSHIP_UPDATE) then
        if user.warshipData[user.curSelectShipType].isNew == true then
            self:removeFromParentAndCleanup(true)
        else
            self:updateShipView()
        end
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_UPGRADE) then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific("texiao_zhi_dengji.png")
        pCityCommon:getAnimation():setSpeedScale(0.6)
        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)

        if msg.c.skillId and msg.c.skillId ~= 0 then
            local order = cfg[CfgType.SHIP_SKILL][msg.c.skillId].order
            local listItem = self.shipUpgradeView.listShipCharacter:getItem(order - 1)
            local ani = createArmature("keji_jiesuo")
            ani:setPosition(listItem:getContentSize().width / 2, listItem:getContentSize().height / 2)
            listItem:addChild(ani)
            ani:getAnimation():setMovementEventCallFunc( function(armature, movementType, movementID)
                if movementType == ccs.MovementEventType.loopComplete then
                    armature:removeFromParentAndCleanup()
                end
            end )
            ani:getAnimation():play("donghua")

            local items = self.shipUpgradeView.listShipCharacter:getItems()
            local percent = order / #items
            if percent < 0.5 then
                self.shipUpgradeView.listShipCharacter:jumpToLeft()
            else
                self.shipUpgradeView.listShipCharacter:jumpToRight()
            end
        end
    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_FILL_FIRE) then
        local count = msg.c.ship_revert_value
        showTips("成功恢复弹药" .. count .. "枚")
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then
        self:updateShipView()
    elseif checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) then
        self:updateShipView()
    elseif checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) then
        self:updateShipView()
    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) then
        self:updateShipView()
    elseif checkMsg(msg.t, MsgCode.SHOP_INIT) then
        disWaitLayer()
        local shopId = msg.c.shopId
        local powerShop = vipShopView:create("vipShopView.csb")
        powerShop:boatShop(shopId)
        me.runningScene():addChild(powerShop, me.MAXZORDER)
        me.showLayer(powerShop, "bg")
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY_AMOUNT) then
        local data = { }
        data.buyed = msg.c.buyed
        data.itemId = msg.c.id
        me.dispatchCustomEvent("shopBuyAmount", data)
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY) then
        local data = { }
        data.shopDefId = msg.c.defId
        data.shopAmount = msg.c.amount
        if msg.c.defId > 30 and table.indexof( { 631, 632, 633, 634 }, msg.c.defId) == false then
            -- 小于30是资源类购买
            NetMan:send(_MSG.Ship_exp_buy(user.curSelectShipType, msg.c.defId, msg.c.amount))
        end
        self:updateShipView()
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXP_BUY) then
        me.dispatchCustomEvent("shopUserExp")
    end
end
function warshipView:init()
    print("warshipView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    self.nodeNextAtt = me.assignWidget(self, "node_next_att")
    self.spAttBg = me.assignWidget(self, "sp_att_bg")
    self.nodeNextAtt:setVisible(false)
    -- 战舰大图
    local function clickShipEventCallback(sender, event)
        if event == TOUCH_EVENT_BEGAN then
        elseif event == TOUCH_EVENT_MOVED then
        elseif event == TOUCH_EVENT_ENDED then
            if self.clickShipImage == nil then self.clickShipImage = true end
            if self.clickShipImage == true then
                self.clickShipImage = false
                self.nodeNextAtt:setVisible(true)
                self.spAttBg:setVisible(false)
            else
                self.clickShipImage = true
                self.nodeNextAtt:setVisible(false)
                self.spAttBg:setVisible(true)
            end
        end
    end
    self.spriteShip = me.assignWidget(self, "image_ship")
    self.spriteShip:addTouchEventListener(clickShipEventCallback)
    -- 战舰名称等级
    self.textShipName = me.assignWidget(self, "title")

    function changeShipCallback(sender)
        if sender.btnType == 1 then
            if user.curSelectShipType > 1 then
                user.curSelectShipType = user.curSelectShipType - 1
            else
                user.curSelectShipType = #self.inactivatedShip
            end
        else
            if user.curSelectShipType < #self.inactivatedShip then
                user.curSelectShipType = user.curSelectShipType + 1
            else
                user.curSelectShipType = 1
            end
        end
        self:updateShipView()
    end
    -- 上一支战舰
    self.btnPrevShip = me.assignWidget(self, "btn_prev")
    self.btnPrevShip.btnType = 1
    -- 下一支战舰
    self.btnNextShip = me.assignWidget(self, "btn_next")
    self.btnNextShip.btnType = 2
    self.btnPrevShip:addClickEventListener(changeShipCallback)
    self.btnNextShip:addClickEventListener(changeShipCallback)

    self.textAttVal = me.assignWidget(self, "text_att_val")
    self.textDefVal = me.assignWidget(self, "text_def_val")
    self.textCapVal = me.assignWidget(self, "text_cap_val")
    self.textSpeedVal = me.assignWidget(self, "text_speed_val")

    self.textNextAttVal = me.assignWidget(self, "text_next_att_val")
    self.textNextDefVal = me.assignWidget(self, "text_next_def_val")
    self.textNextCapVal = me.assignWidget(self, "text_next_cap_val")
    self.textNextSpeedVal = me.assignWidget(self, "text_next_speed_val")

    self.spNextAttVal = me.assignWidget(self, "sp_next_point1")
    self.spNextDefVal = me.assignWidget(self, "sp_next_point2")
    self.spNextCapVal = me.assignWidget(self, "sp_next_point3")
    self.spNextSpeedVal = me.assignWidget(self, "sp_next_point4")

    self.shipActiveView = { }
    -- 打造战舰界面
    self.nodeShipBuild = me.assignWidget(self, "node_shipbuild")
    self.shipActiveView.spIconShip = me.assignWidget(self, "image_ship_icon")
    local function buyDebrisCallback(sender)
        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
        mainCity:addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView, "bg")
        local baseShipCfg = self.inactivatedShip[user.curSelectShipType]
        -- 碎片
        local strItemTb = string.split(baseShipCfg.needItem, ":")
        getWayView:setData(strItemTb[1])
    end
    self.shipActiveView.spIconShip:addClickEventListener(buyDebrisCallback)

    local imageFrameTop = me.assignWidget(self, "im_frame_top")
    imageFrameTop:addClickEventListener(buyDebrisCallback)

    self.shipActiveView.textShipName = me.assignWidget(self, "text_ship_name")
    self.shipActiveView.textDebrisNum = me.assignWidget(self, "text_debris_num")
    self.shipActiveView.loadBarShip = me.assignWidget(self, "load_bar_debris")

    self.shipActiveView.textFood = me.assignWidget(self, "text_food_num")
    self.shipActiveView.textWood = me.assignWidget(self, "text_wood_num")
    self.shipActiveView.textIron = me.assignWidget(self, "text_iron_num")
    self.shipActiveView.textGold = me.assignWidget(self, "text_gold_num")

    self.shipActiveView.spFoodEnough = me.assignWidget(self, "sp_food_enough")
    self.shipActiveView.spWoodEnough = me.assignWidget(self, "sp_wood_enough")
    self.shipActiveView.spIronEnough = me.assignWidget(self, "sp_iron_enough")
    self.shipActiveView.spGoldEnough = me.assignWidget(self, "sp_gold_enough")

    self.shipActiveView.btnGetFood = me.assignWidget(self, "btn_food_more")
    self.shipActiveView.btnGetFood.shopKey = "food"
    self.shipActiveView.btnGetWood = me.assignWidget(self, "btn_wood_more")
    self.shipActiveView.btnGetWood.shopKey = "wood"
    self.shipActiveView.btnGetIron = me.assignWidget(self, "btn_iron_more")
    self.shipActiveView.btnGetIron.shopKey = "stone"
    self.shipActiveView.btnGetGold = me.assignWidget(self, "btn_gold_more")
    self.shipActiveView.btnGetGold.shopKey = "gold"

    local function getMoreResourceCallback(sender)
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(sender.shopKey)
        tmpView:setRescourceNeedNums(sender.needNums)
        mainCity:addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    end
    self.shipActiveView.btnGetFood:addClickEventListener(getMoreResourceCallback)
    self.shipActiveView.btnGetWood:addClickEventListener(getMoreResourceCallback)
    self.shipActiveView.btnGetIron:addClickEventListener(getMoreResourceCallback)
    self.shipActiveView.btnGetGold:addClickEventListener(getMoreResourceCallback)
    -- 打造战舰
    local function createShipCallback(sender)
        -- if sender.debrisEnough == true then
            NetMan:send(_MSG.Ship_create(user.curSelectShipType))
            showWaitLayer()
        -- else
            -- showTips("碎片不足")
        -- end
    end
    self.shipActiveView.btnCreateShip = me.assignWidget(self, "btn_build_ship")
    self.shipActiveView.btnCreateShip:addClickEventListener(createShipCallback)

    --------------------------- 分割线 ---------------------------------

    self.shipUpgradeView = { }
    -- 战舰升级界面
    self.nodeShipUpgrade = me.assignWidget(self, "node_shipinfo")
    -- 战舰经验进度
    self.shipUpgradeView.loadbarExpProgress = me.assignWidget(self, "load_bar_exp")
    -- 战舰经验百分比
    self.shipUpgradeView.textExpProgress = me.assignWidget(self, "text_exp_progress")
    -- 战舰当前状态
    self.shipUpgradeView.btnShipStatus = me.assignWidget(self, "btn_ship_status")
    -- 战舰等级
    self.shipUpgradeView.textShipLv = me.assignWidget(self, "text_shipLv")

    local function sendShipFightCallback(sender)
        local shipData = user.warshipData[user.curSelectShipType]
        if shipData.status == 4 then
            -- 航行中
            local shipSail = shipSailView:create("warning/shipSailView.csb")
            mainCity:addChild(shipSail, me.MAXZORDER)
            me.showLayer(shipSail, "bg")
            self:removeFromParentAndCleanup(true)
            return
        end
        NetMan:send(_MSG.Ship_status(user.curSelectShipType, shipData.status))
        showWaitLayer()
    end
    self.shipUpgradeView.btnShipStatus:addClickEventListener(sendShipFightCallback)
    -- 战舰战斗力
    self.shipUpgradeView.textShipFight = me.assignWidget(self, "text_num")
    -- 舰队
    me.registGuiClickEventByName(self, "btn_fleet", function(sender)
        local warship_tech = warship_tech:create("warship_science.csb")
        warship_tech:setDataTidy(user.curSelectShipType)
        mainCity:addChild(warship_tech, me.MAXZORDER)
    end )

    -- 航海按钮
    me.registGuiClickEventByName(self, "btn_hanghai", function(sender)
        local shipSail = shipSailView:create("warning/shipSailView.csb")
        mainCity:addChild(shipSail, me.MAXZORDER)
        me.showLayer(shipSail, "bg")
    end )

    -- 战舰突破按钮
    me.registGuiClickEventByName(self, "btn_breakthrough", function(sender)
        local shipSail = warship_breakthrough:create("warship/warship_breakthrough.csb")
        shipSail:initUIData(user.curSelectShipType)
        me.runningScene():addChild(shipSail, me.MAXZORDER)
        me.showLayer(shipSail, "bg")
    end )
    -- 战舰突破按钮
    me.registGuiClickEventByName(self, "btn_tupo", function(sender)
        local shipSail = warship_breakthrough:create("warship/warship_breakthrough.csb")
        shipSail:initUIData(user.curSelectShipType)
        me.runningScene():addChild(shipSail, me.MAXZORDER)
        me.showLayer(shipSail, "bg")
    end )
    -- 战舰改装
    self.Button_Refit = me.registGuiClickEventByName(self, "Button_Refit", function(sender)
        local refit = warShipRefitView:create("warshipRefitView.csb")
        me.popLayer(refit)
        NetMan:send(_MSG.ship_refit())
    end )
    -- 战舰特性列表
    self.shipUpgradeView.listShipCharacter = me.assignWidget(self, "list_character")
    self.shipUpgradeView.listShipCharacter:setScrollBarEnabled(false)
    -- 战舰耐久进度
    self.shipUpgradeView.loadBarShipDurable = me.assignWidget(self, "loadbar_durable")
    self.shipUpgradeView.textFireProgress = me.assignWidget(self, "text_durable")
    self.shipUpgradeView.btnFireAdd = me.assignWidget(self, "btn_add")
    self.shipUpgradeView.btnFireReduce = me.assignWidget(self, "btn_reduce")
    local function addRestoreNumCallback(sender)
        if self.inputFireMax <= 0 then return end
        self.curSelectNum = self.curSelectNum + 1
        if self.curSelectNum > self.inputFireMax then
            self.curSelectNum = self.inputFireMax
        end
        local percent = self.curSelectNum / self.inputFireMax * 100
        self.shipUpgradeView.sliderWorker:setPercent(percent)
        self.editCurNum:setText(tostring(self.curSelectNum))

        self:updateShipRestoreRes()
    end

    local function redRestoreNumCallback(sender)
        if self.inputFireMax <= 0 then return end
        self.curSelectNum = self.curSelectNum - 1
        if self.curSelectNum <= 0 then
            self.curSelectNum = 1
        end
        self.editCurNum:setText(tostring(self.curSelectNum))

        self:updateShipRestoreRes()
    end
    self.shipUpgradeView.btnFireAdd:addClickEventListener(addRestoreNumCallback)
    self.shipUpgradeView.btnFireReduce:addClickEventListener(redRestoreNumCallback)

    local nodeEdit = me.assignWidget(self, "editBoxNum")
    local function editBoxTextEventHandle(eventName, sender)
        if eventName == "ended" then
            if self.inputFireMax <= 0 then
                self.editCurNum:setText("0")
                return
            end
            local text = sender:getText()
            local inputNumber = tonumber(text)

            if inputNumber ~= nil and inputNumber >= 0 then
                if inputNumber <= self.inputFireMax then
                    self.curSelectNum = inputNumber
                else
                    self.curSelectNum = self.inputFireMax
                end
            end
            if self.curSelectNum == 0 then
                self.curSelectNum = 1
            end
            self:updateShipRestoreRes()
        end
    end
    self.editCurNum = ccui.EditBox:create(cc.size(50, 40), "default.png")
    self.editCurNum:setAnchorPoint(cc.p(0, 0.5))
    self.editCurNum:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editCurNum:setFontSize(22)
    self.editCurNum:setFontColor(cc.c3b(212, 205, 185))
    self.editCurNum:setPlaceholderFontSize(24)
    nodeEdit:addChild(self.editCurNum)
    self.editCurNum:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self.shipUpgradeView.sliderWorker = me.assignWidget(self, "slider_worker")
    local function sliderEvent(sender, eventType)
        if eventType == 2 then
            if self.inputFireMax <= 0 then
                sender:setPercent(0)
                return
            end
            local percent = sender:getPercent()
            local curNum = math.ceil(self.inputFireMax * percent / 100)
            if curNum <= 0 then
                curNum = 1
            end
            if self.curSelectNum ~= curNum then
                self.curSelectNum = curNum
                self:updateShipRestoreRes()
            end
        end
    end
    self.shipUpgradeView.sliderWorker:addEventListener(sliderEvent)

    self.shipUpgradeView.textMaxDurable = me.assignWidget(self, "max_label")
    self.shipUpgradeView.imageResBg = me.assignWidget(self, "im_resource_bg")
    self.shipUpgradeView.imageResBg:addClickEventListener( function(sender)
        if sender.strIntroduce == nil then return end
        local str = sender.strIntroduce
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>" .. str .. "&", wd)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end )
    self.shipUpgradeView.spResourceIcon = me.assignWidget(self, "sp_resource_icon")
    -- 弹药恢复消耗资源数量
    self.shipUpgradeView.textResource = me.assignWidget(self, "text_resource_num")
    -- 弹药恢复资源当前拥有数量
    self.shipUpgradeView.textResNum = me.assignWidget(self, "text_res_num")
    self.shipUpgradeView.btnSelect = me.assignWidget(self, "btn_select")
    self.shipUpgradeView.btnUpgrade = me.assignWidget(self, "btn_upgrade")
    self.shipUpgradeView.btnTupo = me.assignWidget(self, "btn_tupo")
    local function gotoUpgradeCallback(sender)
        if sender.tipStr then
            showTips("战舰等级不能超过码头等级")
            return
        end
        if sender.isUpgrade == true then
            NetMan:send(_MSG.Ship_upgrade(user.curSelectShipType))
            showWaitLayer()
        else
            NetMan:send(_MSG.initShop(SHIPEXPERICESHOP))
        end
    end
    self.shipUpgradeView.btnUpgrade:addClickEventListener(gotoUpgradeCallback)
    local function restoreFireCallback(sender)
        if sender.tipStr then
            showTips(sender.tipStr)
            return
        end
        NetMan:send(_MSG.Ship_restore(user.curSelectShipType, self.curSelectNum, not self.shipRestoreRes))
        showWaitLayer()
    end
    self.shipUpgradeView.btnSelect:addClickEventListener(restoreFireCallback)
    me.registGuiClickEventByName(self, "btn_reset", function(node)
        if self.shipRestoreRes == true then
            self.shipRestoreRes = false
        else
            self.shipRestoreRes = true
        end
        self:updateShipRestoreRes()
    end )

    self:updateShipView()

    return true
end
function warshipView:setCurShipType(shipType)
    user.curSelectShipType = shipType
    if shipType < 1 or shipType > #self.inactivatedShip then
        print("shipType error")
        return
    end
    if user.curSelectShipType ~= shipType then
        user.curSelectShipType = shipType
    end
    self:updateShipView()
end

function warshipView:updateShipView()
    -- 舰船大图
    -- self.spriteShip:loadTexture (getWarshipImageTexture(user.curSelectShipType))
    self.spriteShip:loadTexture("defalut.png")
    self.spriteShip:removeAllChildren()
    me.resizeImage(self.spriteShip, 566, 475)
    local sk = sp.SkeletonAnimation:create("animation/anim_zhanjian_0" .. user.curSelectShipType .. ".json", "animation/anim_zhanjian_0" .. user.curSelectShipType .. ".atlas", 1)
    self.spriteShip:addChild(sk)
    sk:setPosition(50, -90)
    sk:setAnimation(0, "animation1", true)
    if user.warshipData[user.curSelectShipType] then
        self.nodeShipBuild:setVisible(false)
        self.nodeShipUpgrade:setVisible(true)
        self:updateShipInfoView()
        self.Button_Refit:setVisible(true)
    else
        self.nodeShipBuild:setVisible(true)
        self.nodeShipUpgrade:setVisible(false)
        self:updateShipActiveView()
        self.Button_Refit:setVisible(false)
    end
    self.Button_Refit:setVisible(false)
end
-- 更新激活界面
function warshipView:updateShipActiveView()
    local baseShipCfg = self.inactivatedShip[user.curSelectShipType]

    self.textShipName:setString(baseShipCfg.name)

    self.shipActiveView.textShipName:setString(baseShipCfg.name)
    -- 碎片
    local strItemTb = string.split(baseShipCfg.needItem, ":")

    local debrisCount = 0
    for k, v in pairs(user.pkg) do
        if v.defid == tonumber(strItemTb[1]) then
            debrisCount = debrisCount + v.count
        end
    end
    local spriteFrame = getItemIcon(tonumber(strItemTb[1]))
    self.shipActiveView.spIconShip:loadTexture(spriteFrame)
    self.shipActiveView.textDebrisNum:setString(debrisCount .. "/" .. strItemTb[2])

    local size = self.shipActiveView.spIconShip:getContentSize()
    local scaleX = 109 / size.width
    local scaleY = 109 / size.height
    self.shipActiveView.spIconShip:setScale(scaleX, scaleY)

    local debrisPercent = debrisCount / tonumber(strItemTb[2]) * 100
    -- 如大于100则bar不会超过100
    self.shipActiveView.loadBarShip:setPercent(debrisPercent)

    self.shipActiveView.textFood:setString(tostring(baseShipCfg.food))
    self.shipActiveView.textWood:setString(tostring(baseShipCfg.wood))
    self.shipActiveView.textIron:setString(tostring(baseShipCfg.stone))
    self.shipActiveView.textGold:setString(tostring(baseShipCfg.gold))

    local color4BShort = cc.c4b(255, 0, 0, 255)
    local color4BEnough = cc.c4b(105, 201, 53, 255)
    local iconFileShort = "shengji_tubiao_buzu.png"
    local iconFileEnough = "shengji_tubiao_manzhu.png"

    local enableCreate = true
    if user.food < baseShipCfg.food then
        self.shipActiveView.textFood:setTextColor(color4BShort)
        self.shipActiveView.spFoodEnough:setTexture(iconFileShort)
        self.shipActiveView.btnGetFood:setVisible(true)
        self.shipActiveView.btnGetFood.needNums = baseShipCfg.food
        enableCreate = false
    else
        self.shipActiveView.textFood:setTextColor(color4BEnough)
        self.shipActiveView.spFoodEnough:setTexture(iconFileEnough)
        self.shipActiveView.btnGetFood:setVisible(false)
    end
    if user.wood < baseShipCfg.wood then
        self.shipActiveView.textWood:setTextColor(color4BShort)
        self.shipActiveView.spWoodEnough:setTexture(iconFileShort)
        self.shipActiveView.btnGetWood:setVisible(true)
        self.shipActiveView.btnGetWood.needNums = baseShipCfg.wood
        enableCreate = false
    else
        self.shipActiveView.textWood:setTextColor(color4BEnough)
        self.shipActiveView.spWoodEnough:setTexture(iconFileEnough)
        self.shipActiveView.btnGetWood:setVisible(false)
    end
    if user.stone < baseShipCfg.stone then
        self.shipActiveView.textIron:setTextColor(color4BShort)
        self.shipActiveView.spIronEnough:setTexture(iconFileShort)
        self.shipActiveView.btnGetIron:setVisible(true)
        self.shipActiveView.btnGetIron.needNums = baseShipCfg.stone
        enableCreate = false
    else
        self.shipActiveView.textIron:setTextColor(color4BEnough)
        self.shipActiveView.spIronEnough:setTexture(iconFileEnough)
        self.shipActiveView.btnGetIron:setVisible(false)
    end
    if user.gold < baseShipCfg.gold then
        self.shipActiveView.textGold:setTextColor(color4BShort)
        self.shipActiveView.spGoldEnough:setTexture(iconFileShort)
        self.shipActiveView.btnGetGold:setVisible(true)
        self.shipActiveView.btnGetGold.needNums = baseShipCfg.gold
        enableCreate = false
    else
        self.shipActiveView.textGold:setTextColor(color4BEnough)
        self.shipActiveView.spGoldEnough:setTexture(iconFileEnough)
        self.shipActiveView.btnGetGold:setVisible(false)
    end

    local debrisEnough = true
    if debrisCount < tonumber(strItemTb[2]) then
        debrisEnough = false
    end
    self.shipActiveView.btnCreateShip.debrisEnough = debrisEnough

    if enableCreate == true then
        self.shipActiveView.btnCreateShip:setBright(true)
        self.shipActiveView.btnCreateShip:setEnabled(true)
    else
        self.shipActiveView.btnCreateShip:setBright(false)
        self.shipActiveView.btnCreateShip:setEnabled(false)
    end
    self.textAttVal:setString(baseShipCfg.atk)
    self.textDefVal:setString(baseShipCfg.def)
    self.textCapVal:setString(baseShipCfg.hp)
    self.textSpeedVal:setString(baseShipCfg.atkRange)

    if baseShipCfg.nextid and baseShipCfg.nextid ~= 0 then
        local contentSize1 = self.textAttVal:getContentSize()
        local x1, y1 = self.textAttVal:getPosition()
        local contentSize2 = self.textDefVal:getContentSize()
        local x2, y2 = self.textDefVal:getPosition()
        local contentSize3 = self.textCapVal:getContentSize()
        local x3, y3 = self.textCapVal:getPosition()
        local contentSize4 = self.textSpeedVal:getContentSize()
        local x4, y4 = self.textSpeedVal:getPosition()

        self.spNextAttVal:setPositionX(x1 + contentSize1.width + 6)
        self.spNextDefVal:setPositionX(x2 + contentSize2.width + 6)
        self.spNextCapVal:setPositionX(x3 + contentSize3.width + 6)
        self.spNextSpeedVal:setPositionX(x4 + contentSize4.width + 6)

        local nextShipCfg = cfg[CfgType.SHIP_DATA][baseShipCfg.nextid]
        self.textNextAttVal:setString(nextShipCfg.atk)
        self.textNextDefVal:setString(nextShipCfg.def)
        self.textNextCapVal:setString(nextShipCfg.hp)
        self.textNextSpeedVal:setString(nextShipCfg.atkRange)

        self.textNextAttVal:setPositionX(x1 + contentSize1.width + 35)
        self.textNextDefVal:setPositionX(x2 + contentSize2.width + 35)
        self.textNextCapVal:setPositionX(x3 + contentSize3.width + 35)
        self.textNextSpeedVal:setPositionX(x4 + contentSize4.width + 35)
    end
end
-- 更新弹药恢复资源图标
function warshipView:updateShipRestoreRes()
    self.shipUpgradeView.btnSelect.tipStr = nil

    local shipData = user.warshipData[user.curSelectShipType]
    if self.inputFireMax <= 0 then
        -- 不可编辑
        self.curSelectNum = 0
        self.editCurNum:setText("0")
        self.shipUpgradeView.sliderWorker:setPercent(0)
        self.shipUpgradeView.btnSelect.tipStr = "数量选择有误"
    else
        self.editCurNum:setText(tostring(self.curSelectNum))
        self.shipUpgradeView.sliderWorker:setEnabled(true)

        local percent = self.shipUpgradeView.sliderWorker:getPercent()
        local curNum = math.ceil(self.inputFireMax * percent / 100)
        if curNum <= 0 then
            curNum = 1
        end
        if self.curSelectNum ~= curNum then
            local percent = self.curSelectNum / self.inputFireMax * 100
            self.shipUpgradeView.sliderWorker:setPercent(percent)
        end
    end

    local fireCostNum = 0
    local enableRestore = true
    local textColor = cc.c4b(199, 197, 183, 255)
    if self.shipRestoreRes == true then
        local inactivedShipCfg = self.inactivatedShip[user.curSelectShipType]
        local strItemTb = string.split(inactivedShipCfg.needItem, ":")
        local itemIcon = getItemIcon(tonumber(strItemTb[1]))
        local path = cc.FileUtils:getInstance():fullPathForFilename(itemIcon)
        me.addImageAsync(path)
        self.shipUpgradeView.spResourceIcon:setTexture(itemIcon)
        fireCostNum = self.curSelectNum

        local etc = cfg[CfgType.ETC][tonumber(strItemTb[1])]
        self.shipUpgradeView.imageResBg.strIntroduce = etc.describe

        local size = self.shipUpgradeView.spResourceIcon:getContentSize()
        local scaleX = 50 / size.width
        local scaleY = 50 / size.height
        self.shipUpgradeView.spResourceIcon:setScale(scaleX, scaleY)

        local debrisCount = 0
        for k, v in pairs(user.pkg) do
            if v.defid == tonumber(strItemTb[1]) then
                debrisCount = debrisCount + v.count
            end
        end
        self.shipUpgradeView.textResNum:setVisible(true)
        self.shipUpgradeView.textResNum:setString(tostring(debrisCount))
        if fireCostNum > debrisCount then
            self.shipUpgradeView.btnSelect.tipStr = "碎片不足，无法恢复"
            textColor = cc.c4b(255, 0, 0, 255)
        end
    else
        local itemIcon = getWarshipRestoreRes(user.restoreResType)
        self.shipUpgradeView.spResourceIcon:setTexture(itemIcon)
        fireCostNum = shipData.baseShipCfg.endurecost * self.curSelectNum
        self.shipUpgradeView.imageResBg.strIntroduce = nil

        local size = self.shipUpgradeView.spResourceIcon:getContentSize()
        local scaleX = 35 / size.width
        local scaleY = 35 / size.height
        self.shipUpgradeView.spResourceIcon:setScale(scaleX, scaleY)

        local userResourecNum = 0
        if user.restoreResType == 9001 then
            userResourecNum = user.food
        elseif user.restoreResType == 9002 then
            userResourecNum = user.wood
        elseif user.restoreResType == 9003 then
            userResourecNum = user.stone
        elseif user.restoreResType == 9004 then
            userResourecNum = user.gold
        end
        self.shipUpgradeView.textResNum:setVisible(false)
        if fireCostNum > userResourecNum then
            self.shipUpgradeView.btnSelect.tipStr = "资源不足，无法恢复"
            textColor = cc.c4b(255, 0, 0, 255)
        end
    end
    local strFireProgress = shipData.nowFire .. "/" .. shipData.baseShipCfg.endure
    local persentFireProgress = shipData.nowFire / shipData.baseShipCfg.endure * 100
    self.shipUpgradeView.loadBarShipDurable:setPercent(persentFireProgress)
    self.shipUpgradeView.textFireProgress:setString(strFireProgress)
    if shipData.nowFire >= shipData.baseShipCfg.endure then
        self.shipUpgradeView.btnSelect.tipStr = "弹药已满，无需恢复"
    end
    self.shipUpgradeView.textResource:setTextColor(textColor)
    self.shipUpgradeView.textResource:setString(tostring(fireCostNum))
    self.shipUpgradeView.textMaxDurable:setString("/" .. self.inputFireMax)
end
-- 更新升级界面
function warshipView:updateShipInfoView()
    self.shipUpgradeView.listShipCharacter:removeAllItems()

    local shipData = user.warshipData[user.curSelectShipType]
    local strTitle = shipData.baseShipCfg.name
    self.textShipName:setString(strTitle)
    self.shipUpgradeView.textShipLv:setString("Lv." .. shipData.baseShipCfg.lv)

    self.shipUpgradeView.btnUpgrade:setVisible(true)
    self.shipUpgradeView.btnUpgrade:setBright(true)
    self.shipUpgradeView.btnUpgrade:setEnabled(true)
    self.shipUpgradeView.btnTupo:setVisible(false)

    local shipFight = shipData.baseShipCfg.fight
    for k, v in pairs(shipData.skills) do
        shipFight = shipFight + v.fight
    end
    local shipTech = user.Warship_Tech[user.curSelectShipType]
    for k, v in pairs(shipTech) do
        shipFight = shipFight + v.Config.fight
    end
    self.shipUpgradeView.textShipFight:setString(tostring(shipFight))

    if shipData.maxExp then
        local strExpProgress = shipData.nowExp .. "/" .. shipData.maxExp
        local persentExpProgress = shipData.nowExp / shipData.maxExp * 100
        self.shipUpgradeView.loadbarExpProgress:setPercent(persentExpProgress)
        self.shipUpgradeView.textExpProgress:setString(strExpProgress)
        self.shipUpgradeView.textExpProgress:setVisible(true)
    else
        self.shipUpgradeView.loadbarExpProgress:setPercent(100)
        self.shipUpgradeView.textExpProgress:setVisible(false)
    end
    self.shipUpgradeView.btnUpgrade:stopAllActions()
    if shipData.maxExp and shipData.nowExp >= shipData.maxExp and
        bLessLevelBuilding(cfg.BUILDING_TYPE_BOAT, shipData.baseShipCfg.lv) then
        me.clickAni(self.shipUpgradeView.btnUpgrade)
    else
        self.shipUpgradeView.btnUpgrade:setBright(false)
        self.shipUpgradeView.btnUpgrade:setEnabled(false)
    end

    self.shipUpgradeView.btnUpgrade:setTitleText("升 级")
    self.shipUpgradeView.btnUpgrade.isUpgrade = true
    self.shipUpgradeView.btnUpgrade.tipStr = nil


    local tupoFlag = true
    if shipData.maxExp then
        self.shipUpgradeView.btnUpgrade:setBright(true)
        self.shipUpgradeView.btnUpgrade:setEnabled(true)
        if shipData.nowExp < shipData.maxExp then
            -- 可进入商店
            -- self.shipUpgradeView.btnUpgrade:loadTextures ("gongyong_anniu_hongse_zhengchang_2.png", "gongyong_anniu_hongse_zhengchang_2.png")
            self.shipUpgradeView.btnUpgrade:setTitleText("获 取")
            self.shipUpgradeView.btnUpgrade.isUpgrade = false
            tupoFlag = false
        else
            if bLessLevelBuilding(cfg.BUILDING_TYPE_BOAT, shipData.baseShipCfg.lv) then
                me.clickAni(self.shipUpgradeView.btnUpgrade)
            else
                self.shipUpgradeView.btnUpgrade.tipStr = "战舰等级不能超过码头等级"
            end
        end
    else
        self.shipUpgradeView.btnUpgrade:setBright(false)
        self.shipUpgradeView.btnUpgrade:setEnabled(false)
    end

    -- 判断是否显示突破按钮
    if tupoFlag == true then
        local shipCfg = cfg[CfgType.SHIP_DATA][shipData.defId]
        shipCfg = cfg[CfgType.SHIP_DATA][shipCfg.nextid]
        if shipCfg and shipCfg.needItem and shipData.overfull < shipCfg.lv - 1 then
            self.shipUpgradeView.btnUpgrade:setVisible(false)
            self.shipUpgradeView.btnTupo:setVisible(true)
        else
            self.shipUpgradeView.btnUpgrade:setVisible(true)
            self.shipUpgradeView.btnTupo:setVisible(false)
        end
    end


    -- status enum
    -- IN_ARMY(1), 在军队中
    -- IN_CITY(2), 在城市中
    -- FREE(3), 空闲状态
    local titleText = ""
    if shipData.status == 1 then
        self.shipUpgradeView.btnShipStatus:setEnabled(false)
        titleText = "出征中"
        self.shipUpgradeView.btnSelect.tipStr = "出征中，无法恢复弹药"
    elseif shipData.status == 2 then
        self.shipUpgradeView.btnShipStatus:setEnabled(true)
        titleText = "取消守城"
    elseif shipData.status == 3 then
        self.shipUpgradeView.btnShipStatus:setEnabled(true)
        titleText = "指派守城"
    elseif shipData.status == 4 then
        self.shipUpgradeView.btnShipStatus:setEnabled(true)
        titleText = "航海中"
    end
    me.assignWidget(self.shipUpgradeView.btnShipStatus, "ship_status_txt"):setString(titleText)

    local function enterShipSkillCallback(sender)
        local order = sender.order
        local shipSkillView = shipSkillView:create("shipSkillView.csb")
        shipSkillView:setSkillListData(user.curSelectShipType,
        self.inactiveShipSkill[user.curSelectShipType], order)
        mainCity:addChild(shipSkillView, me.MAXZORDER)
        me.showLayer(shipSkillView, "bg")
    end
    -- 战舰特性列表
    local arrayShipSkill = self.inactiveShipSkill[user.curSelectShipType]
    for k, v in pairs(arrayShipSkill) do
        local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
        shipSkillCell:setVisible(true)
        local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
        imageSkillIcon:setTouchEnabled(true)
        imageSkillIcon:setEnabled(true)
        local skillCfg = v
        if shipData.skills[v.order] then
            local skillCfg = shipData.skills[v.order]
            local textrueIcon = getItemIcon(skillCfg.icon)
            imageSkillIcon:loadTexture(textrueIcon)

            local skillIconSize = imageSkillIcon:getContentSize()
            me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.lv .. "阶")
        else
            local textrueIcon = getItemIcon(v.icon)
            imageSkillIcon:loadTexture(textrueIcon)

            me.assignWidget(shipSkillCell, "lock"):setVisible(true)

            me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.lv .. "阶")
            imageSkillIcon:getVirtualRenderer():setState(1)
        end
        imageSkillIcon.order = v.order
        imageSkillIcon:addClickEventListener(enterShipSkillCallback)

        self.shipUpgradeView.listShipCharacter:pushBackCustomItem(shipSkillCell)
    end
    -- 攻防血速
    self.textAttVal:setString(shipData.baseShipCfg.atk)
    self.textDefVal:setString(shipData.baseShipCfg.def)
    self.textCapVal:setString(shipData.baseShipCfg.hp)
    self.textSpeedVal:setString(shipData.baseShipCfg.atkRange)

    self.textNextAttVal = me.assignWidget(self, "text_next_att_val")
    self.textNextDefVal = me.assignWidget(self, "text_next_def_val")
    self.textNextCapVal = me.assignWidget(self, "text_next_cap_val")
    self.textNextSpeedVal = me.assignWidget(self, "text_next_speed_val")

    if shipData.baseShipCfg.nextid and shipData.baseShipCfg.nextid ~= 0 then
        local contentSize1 = self.textAttVal:getContentSize()
        local x1, y1 = self.textAttVal:getPosition()
        local contentSize2 = self.textDefVal:getContentSize()
        local x2, y2 = self.textDefVal:getPosition()
        local contentSize3 = self.textCapVal:getContentSize()
        local x3, y3 = self.textCapVal:getPosition()
        local contentSize4 = self.textSpeedVal:getContentSize()
        local x4, y4 = self.textSpeedVal:getPosition()


        local nextShipCfg = cfg[CfgType.SHIP_DATA][shipData.baseShipCfg.nextid]
        self.textNextAttVal:setString(nextShipCfg.atk)
        self.textNextDefVal:setString(nextShipCfg.def)
        self.textNextCapVal:setString(nextShipCfg.hp)
        self.textNextSpeedVal:setString(nextShipCfg.atkRange)

        self.textNextAttVal:setPositionX(x1)
        self.textNextDefVal:setPositionX(x2)
        self.textNextCapVal:setPositionX(x3)
        self.textNextSpeedVal:setPositionX(x4)
        self.spNextAttVal:setPositionX(self.textNextAttVal:getPositionX() + self.textNextAttVal:getContentSize().width + 6)
        self.spNextDefVal:setPositionX(self.textNextDefVal:getPositionX() + self.textNextDefVal:getContentSize().width + 6)
        self.spNextCapVal:setPositionX(self.textNextCapVal:getPositionX() + self.textNextCapVal:getContentSize().width + 6)
        self.spNextSpeedVal:setPositionX(self.textNextSpeedVal:getPositionX() + self.textNextSpeedVal:getContentSize().width + 6)

    end

    self.curSelectNum = 1
    self.inputFireMax = shipData.baseShipCfg.endure - shipData.nowFire
    self:updateShipRestoreRes()
end