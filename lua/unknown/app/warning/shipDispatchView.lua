shipDispatchView = class("shipDispatchView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)

function shipDispatchView:create(...)
    local layer = shipDispatchView.new(...)
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

function shipDispatchView:ctor()
end

function shipDispatchView:onEnter()
end

function shipDispatchView:onExit()
end


function shipDispatchView:init()
    print("shipDispatchView init")

    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    self.listShipView = me.assignWidget(self,"list_ship")
    self.listShipView:setScrollBarEnabled (false)

    return true
end

function shipDispatchView:setCurSailTaskId(taskId)
    self:updateDispatchShipList (taskId)
end

function shipDispatchView:updateDispatchShipList(taskId)
    local itemNode = cc.CSLoader:createNode ("shipDispatchItem.csb")
    local panelItem = me.assignWidget(itemNode, "panel_item")

    local shipExpeditionCfg = cfg[CfgType.SHIP_EXPEDITION] [taskId]

    local function getProperty(shipData)
        local shipFight = shipData.baseShipCfg.fight
        for _k, _v in pairs (shipData.skills) do
            shipFight = shipFight + _v.fight
        end
        local shipTech = user.Warship_Tech[shipData.baseShipCfg.type]
        for _k, _v in pairs (shipTech) do
            shipFight = shipFight + _v.Config.fight
        end

        local probability = shipExpeditionCfg.probability / 100
        if shipData.baseShipCfg.type == shipExpeditionCfg.type then
            probability = probability + shipExpeditionCfg.extprobability / 100
        end
        local probabilityEx = (shipFight / shipExpeditionCfg.fight / 2) * 100
        if probabilityEx < 0 then
            probabilityEx = 0
        end
        local totalProbality = probability + probabilityEx
        if totalProbality > 100 then
            totalProbality = 100
        end

        return shipFight, totalProbality
    end

    local arrShipData = table.values (user.warshipData)
    table.sort (arrShipData, function (a, b)
        local fightA, probabilityA = getProperty (a)
        local fightB, probabilityB = getProperty (b)

        return probabilityA > probabilityB
    end)

    for k, v in pairs (arrShipData) do
        if v.status == 3 then -- 在空闲中
            local listItem = panelItem:clone ()
            local imageShipIcon = me.assignWidget(listItem, "image_ship_icon")
            local textShipName  = me.assignWidget(listItem, "text_ship_name")
            local textShipFight = me.assignWidget(listItem, "text_ship_fight")
            local textLeftGun = me.assignWidget(listItem, "text_left_gun")
            local textTipReward = me.assignWidget(listItem, "text_expend_reward")
            local textItemNum = me.assignWidget(listItem, "text_item_num")
            local imageTipIcon  = me.assignWidget(listItem, "image_icon")
            local imageItem  = me.assignWidget(listItem, "image_item")

            local shipImage = getWarshipImageTexture (v.baseShipCfg.type)
            imageShipIcon:loadTexture (shipImage)
            textShipName:setString (v.baseShipCfg.name)

            local fight, probability = getProperty (v)
            textShipFight:setString ( fight)

            if v.baseShipCfg.type == shipExpeditionCfg.type then
                textTipReward:setTextColor (cc.c3b(154, 236, 81))
                textItemNum:setTextColor (cc.c3b(154, 236, 81))
                imageTipIcon:setVisible (true)
            else
                textTipReward:setTextColor (cc.c3b(255, 255, 255))
                textItemNum:setTextColor (cc.c3b(255, 255, 255))
                imageTipIcon:setVisible (false)
            end
            textTipReward:setString ("有" .. math.floor (probability) .. "%" .. "的概率获得：")
            textItemNum:setString ("X1")
            textLeftGun:setString ( v.nowFire)
            if v.nowFire < shipExpeditionCfg.ammo then
                textLeftGun:setTextColor (cc.c3b(255, 0, 0))
            else
                textLeftGun:setTextColor (cc.c3b(255, 255, 255))
            end
            local extraReward = string.split (shipExpeditionCfg.extreward, ":")
            -- 额外奖励
            local rewardIcon = getItemIcon (tonumber (extraReward[1]))
            imageItem:loadTexture (rewardIcon)
            imageItem:ignoreContentAdaptWithSize (true)
            imageItem:setScale (0.3)
            local function showItemDetailCallback(sender)
                showPromotion (tonumber (extraReward[1]), tonumber (extraReward [2]))
            end
            imageItem:addClickEventListener (showItemDetailCallback)
            function selectShipCallback (sender)
                if v.nowFire < shipExpeditionCfg.ammo then
                    showTips ("弹药不足，无法派遣")
                    return
                end
                -- 派遣战舰
                NetMan:send(_MSG.ship_expedition(taskId, v.baseShipCfg.type))
                showWaitLayer ()
                self:removeFromParentAndCleanup(true)
            end
            listItem:addClickEventListener (selectShipCallback)

            self.listShipView:pushBackCustomItem (listItem)
        end
    end
end